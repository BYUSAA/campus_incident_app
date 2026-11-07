$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repositoryRoot

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][scriptblock]$Command
    )

    Write-Host "`n========== $Name ==========" -ForegroundColor Cyan
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

    $androidManifest = Join-Path $repositoryRoot 'android/app/src/main/AndroidManifest.xml'
    if (-not (Test-Path $androidManifest)) {
        throw 'Android runner is missing. Run .\tooling\bootstrap-android.ps1 first.'
    }

    $firebaseOptions = Join-Path $repositoryRoot 'lib/firebase_options.dart'
    if (-not (Test-Path $firebaseOptions) -or
        (Select-String -Path $firebaseOptions -SimpleMatch 'throw UnsupportedError' -Quiet)) {
        throw 'Firebase options are not configured. Run .\tooling\bootstrap-firebase.ps1 -ProjectId YOUR_FIREBASE_PROJECT_ID first.'
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

    Write-Host "`n========== Android integration smoke test ==========" -ForegroundColor Cyan
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

    Write-Host "`nALL AVAILABLE CHECKS PASSED." -ForegroundColor Green
    Write-Host 'APK: build/app/outputs/flutter-apk/app-debug.apk'
    Write-Host 'Coverage: coverage/lcov.info'
    Write-Host 'Commit pubspec.lock after reviewing the dependency resolution.'
}
finally {
    Pop-Location
}
