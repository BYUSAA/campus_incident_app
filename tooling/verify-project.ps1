$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$skippedChecks = @()
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
    # Keep Flutter checks independent from optional Firebase Emulator tools.
    foreach ($tool in @('flutter', 'dart')) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            throw "$tool was not found on PATH. Install Flutter (which includes Dart) and reopen PowerShell."
        }
    }

    Write-Host ''
    Write-Host '========== Toolchain versions ==========' -ForegroundColor Cyan
    flutter --version
    dart --version

    $doctorOutput = flutter doctor -v 2>&1 | Out-String
    $javaVersionMatch = [regex]::Match(
        $doctorOutput,
        '(?im)Java version[^\r\n]*?\b(\d+)\.'
    )
    if ($javaVersionMatch.Success) {
        $androidJavaMajor = [int]$javaVersionMatch.Groups[1].Value
        if ($androidJavaMajor -notin @(17, 21)) {
            Write-Warning "Flutter reports JDK $androidJavaMajor. This project is configured for JDK 17 or 21. The Android build will still be attempted so Gradle can report the exact compatibility issue."
        }
        else {
            Write-Host "Flutter Android toolchain reports supported JDK $androidJavaMajor." -ForegroundColor Green
        }
    }
    else {
        Write-Warning 'Could not identify the Android JDK from flutter doctor -v. The Android build will still be attempted.'
    }

    $androidManifest = Join-Path $repositoryRoot 'android/app/src/main/AndroidManifest.xml'
    if (-not (Test-Path $androidManifest)) {
        throw 'Android runner is missing. Run .\tooling\bootstrap-android.ps1 first.'
    }

    # Firebase client options are required for live app execution and the
    # Firebase-connected device smoke test, but not for analyzer/unit tests,
    # local Firebase Rules emulators, or compiling a debug APK.
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
        Write-Host 'Firebase client options detected.' -ForegroundColor Green
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

    # Run the security rules suite when its independent Node/Java toolchain
    # is available. Missing optional tools must not prevent Flutter checks.
    $ruleTools = @('node', 'npm', 'npx', 'java')
    $missingRuleTools = @(
        $ruleTools | Where-Object {
            -not (Get-Command $_ -ErrorAction SilentlyContinue)
        }
    )

    if ($missingRuleTools.Count -eq 0) {
        Write-Host ''
        Write-Host '========== Firebase Emulator toolchain ==========' -ForegroundColor Cyan
        node --version
        npm --version
        java -version

        Push-Location (Join-Path $repositoryRoot 'firebase/rules-tests')
        try {
            Invoke-CheckedCommand -Name 'Firebase rules test dependencies' -Command {
                npm install --no-audit --no-fund
            }
        }
        finally {
            Pop-Location
        }

        Invoke-CheckedCommand -Name 'Firestore and Storage Emulator security tests' -Command {
            npx --yes firebase-tools emulators:exec --project demo-campus-incident-reporter --only firestore,storage "npm --prefix firebase/rules-tests test"
        }
    }
    else {
        $missingList = $missingRuleTools -join ', '
        Write-Warning "Skipped Firebase Emulator security tests because these tools are missing: $missingList."
        $skippedChecks += "Firebase Emulator security tests (missing: $missingList)"
    }

    Invoke-CheckedCommand -Name 'Android debug APK build' -Command {
        flutter build apk --debug
    }

    Write-Host ''
    Write-Host '========== Android integration smoke test ==========' -ForegroundColor Cyan
    if (-not $firebaseOptionsConfigured) {
        Write-Warning 'Skipped the Android integration smoke test because Firebase client options have not been generated. Run .\tooling\bootstrap-firebase.ps1 after signing in to Firebase, then rerun this script.'
        $skippedChecks += 'Firebase-connected Android integration smoke test (Firebase options not configured)'
    }
    else {
        $deviceOutput = flutter devices --machine
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not query Flutter devices.'
        }
        $devices = @($deviceOutput | ConvertFrom-Json)
        $androidDevice = $devices |
            Where-Object { $_.targetPlatform -like 'android-*' } |
            Select-Object -First 1

        if ($null -ne $androidDevice) {
            Invoke-CheckedCommand -Name 'Android signed-out navigation smoke test' -Command {
                flutter test integration_test/app_workflow_test.dart -d $androidDevice.id
            }
        }
        else {
            Write-Warning 'No Android emulator or device is connected. Connect an Android target and rerun this script.'
            $skippedChecks += 'Android integration smoke test (no Android device connected)'
        }
    }

    Write-Host ''
    Write-Host 'LOCAL VERIFICATION FINISHED.' -ForegroundColor Green
    Write-Host 'APK: build/app/outputs/flutter-apk/app-debug.apk'
    Write-Host 'Coverage: coverage/lcov.info'

    if ($skippedChecks.Count -gt 0) {
        Write-Host ''
        Write-Host 'The following checks were skipped:' -ForegroundColor Yellow
        foreach ($check in $skippedChecks) {
            Write-Host " - $check" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host 'All configured local checks completed.' -ForegroundColor Green
    }

    if (-not $firebaseOptionsConfigured) {
        Write-Warning 'The APK is compile-verified only. Live Firebase sign-in, Firestore operations, Storage uploads, and complete on-device behavior are not verified until Firebase is configured.'
    }

    Write-Host 'Review and commit pubspec.lock and firebase/rules-tests/package-lock.json after dependency resolution.'
}
finally {
    Pop-Location
}
