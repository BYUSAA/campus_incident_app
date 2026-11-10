$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repositoryRoot

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][scriptblock]$Command
    )

    Write-Host ''
    Write-Host "========== $Name ==========" -ForegroundColor Cyan
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "$Name failed with exit code $LASTEXITCODE. Fix this step before continuing."
    }
}

try {
    foreach ($tool in @('flutter', 'dart', 'node', 'npm', 'java', 'npx')) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            throw "$tool was not found on PATH. Install the required tool and reopen PowerShell."
        }
    }

    Write-Host ''
    Write-Host '========== Android JDK selection ==========' -ForegroundColor Cyan
    $doctorOutput = flutter doctor -v 2>&1 | Out-String
    $javaVersionMatch = [regex]::Match(
        $doctorOutput,
        '(?im)Java version[^\r\n]*?\b(\d+)\.'
    )

    if ($javaVersionMatch.Success) {
        $androidJavaMajor = [int]$javaVersionMatch.Groups[1].Value
        if ($androidJavaMajor -notin @(17, 21)) {
            throw "Flutter is using JDK $androidJavaMajor for Android. This project supports JDK 17 or 21. Install one of those versions, run flutter config --jdk-dir=C:\path\to\jdk-17-or-21, restart VS Code, and confirm with flutter doctor -v."
        }
        Write-Host "Flutter Android toolchain is using supported JDK $androidJavaMajor." -ForegroundColor Green
    }
    else {
        Write-Warning 'Could not identify the Android JDK from flutter doctor -v. Review the Android toolchain section manually before building.'
    }

    $androidManifest = Join-Path $repositoryRoot 'android/app/src/main/AndroidManifest.xml'
    if (-not (Test-Path $androidManifest)) {
        throw 'Android runner is missing. Run .\tooling\bootstrap-android.ps1 first.'
    }

    # Firebase client options are needed to launch the live app and run the
    # Firebase-connected device smoke test, but not to analyze Dart code,
    # execute fake-backed unit/widget tests, run local rules emulators, or
    # compile a debug APK. Keep those no-cost checks available before setup.
    $firebaseOptions = Join-Path $repositoryRoot 'lib/firebase_options.dart'
    $firebaseOptionsConfigured = $false
    if (Test-Path $firebaseOptions) {
        $optionsContent = Get-Content $firebaseOptions -Raw
        $firebaseOptionsConfigured = (
            $optionsContent -notmatch 'throw\s+UnsupportedError'
            -and $optionsContent -match 'apiKey'
            -and $optionsContent -match 'projectId'
        )
    }

    if ($firebaseOptionsConfigured) {
        Write-Host 'Firebase client options detected. The app can be tested against its configured Firebase project.' -ForegroundColor Green
    }
    else {
        Write-Warning 'Firebase client options are still a setup placeholder. Local analysis, unit/widget tests, emulator security tests, and APK compilation will continue. The Firebase-connected device smoke test will be skipped.'
    }

    Invoke-CheckedCommand -Name 'Flutter dependency resolution' -Command { flutter pub get }
    if (-not (Test-Path (Join-Path $repositoryRoot 'pubspec.lock'))) {
        throw 'flutter pub get did not create pubspec.lock. Resolve dependency errors before continuing.'
    }

    Invoke-CheckedCommand -Name 'Dart formatting' -Command { dart format lib test integration_test }
    Invoke-CheckedCommand -Name 'Flutter static analysis' -Command { flutter analyze }
    Invoke-CheckedCommand -Name 'Flutter unit and widget tests' -Command { flutter test --coverage }

    Push-Location (Join-Path $repositoryRoot 'firebase/rules-tests')
    try {
        Invoke-CheckedCommand -Name 'Firebase rules test dependencies' -Command { npm install --no-audit --no-fund }
    }
    finally {
        Pop-Location
    }

    Invoke-CheckedCommand -Name 'Firestore and Storage Emulator security tests' -Command {
        npx --yes firebase-tools emulators:exec --project demo-campus-incident-reporter --only firestore,storage "npm --prefix firebase/rules-tests test"
    }

    Invoke-CheckedCommand -Name 'Android debug APK build' -Command { flutter build apk --debug }

    Write-Host ''
    Write-Host '========== Android integration smoke test ==========' -ForegroundColor Cyan
    if (-not $firebaseOptionsConfigured) {
        Write-Warning 'Skipped the Android integration smoke test because Firebase client options have not been generated. Run .\tooling\bootstrap-firebase.ps1 after signing in to Firebase, then rerun this script.'
    }
    else {
        $deviceOutput = flutter devices --machine
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not query Flutter devices.'
        }
        $devices = @($deviceOutput | ConvertFrom-Json)
        $androidDevice = $devices | Where-Object { $_.targetPlatform -like 'android-*' } | Select-Object -First 1
        if ($null -ne $androidDevice) {
            Invoke-CheckedCommand -Name 'Android signed-out navigation smoke test' -Command {
                flutter test integration_test/app_workflow_test.dart -d $androidDevice.id
            }
        }
        else {
            Write-Warning 'No Android emulator or device is connected. Integration smoke test was skipped; connect an Android target and run this script again.'
        }
    }

    Write-Host ''
    Write-Host 'ALL AVAILABLE LOCAL CHECKS PASSED.' -ForegroundColor Green
    Write-Host 'APK: build/app/outputs/flutter-apk/app-debug.apk'
    Write-Host 'Coverage: coverage/lcov.info'

    if (-not $firebaseOptionsConfigured) {
        Write-Warning 'The APK is compile-verified only. Live Firebase sign-in, Firestore operations, photo uploads, and on-device end-to-end behavior are not verified until Firebase is configured.'
    }

    Write-Host 'Commit pubspec.lock and firebase/rules-tests/package-lock.json after reviewing dependency resolution.'
}
finally {
    Pop-Location
}
