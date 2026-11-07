param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$FirebaseProjectId,
    [switch]$SkipEmulatorTests
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repositoryRoot

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Command
    )

    Write-Host "`n== $Name ==" -ForegroundColor Cyan
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "$Name failed with exit code $LASTEXITCODE."
    }
}

try {
    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        throw 'Flutter was not found on PATH. Install Flutter and reopen PowerShell.'
    }
    if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
        throw 'Dart was not found on PATH. Install Flutter, which includes Dart.'
    }

    Write-Host 'Campus Incident Reporter — Android/Firebase preparation' -ForegroundColor Green
    Write-Host "Repository: $repositoryRoot"
    Write-Host "Firebase project: $FirebaseProjectId"

    Write-Host "`n== Android platform generation ==" -ForegroundColor Cyan
    & (Join-Path $PSScriptRoot 'bootstrap-android.ps1')
    if ($LASTEXITCODE -ne 0) {
        throw 'Android bootstrap failed.'
    }

    Write-Host "`n== Firebase project configuration ==" -ForegroundColor Cyan
    & (Join-Path $PSScriptRoot 'bootstrap-firebase.ps1') -ProjectId $FirebaseProjectId -RequireDeployment
    if ($LASTEXITCODE -ne 0) {
        throw 'Firebase bootstrap failed.'
    }

    $optionsFile = Join-Path $repositoryRoot 'lib/firebase_options.dart'
    if (-not (Test-Path $optionsFile)) {
        throw 'Firebase options are missing. Re-run the Firebase bootstrap.'
    }
    if ((Get-Content $optionsFile -Raw) -match 'throw UnsupportedError') {
        throw 'Firebase options are still the placeholder. Configure the real project before building.'
    }

    Invoke-CheckedCommand 'Install Flutter packages' { flutter pub get }
    Invoke-CheckedCommand 'Format Dart code' { dart format lib test integration_test }
    Invoke-CheckedCommand 'Run Flutter static analysis' { flutter analyze }
    Invoke-CheckedCommand 'Run Flutter unit and widget tests' { flutter test --coverage }

    if (-not $SkipEmulatorTests) {
        if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
            throw 'npm was not found. Install Node.js 22 or later, or rerun with -SkipEmulatorTests.'
        }
        if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
            throw 'Java was not found. Install Java 17 or later, or rerun with -SkipEmulatorTests.'
        }
        Invoke-CheckedCommand 'Install Firebase rule-test dependencies' {
            npm install --prefix firebase/rules-tests --no-audit --no-fund
        }
        Invoke-CheckedCommand 'Run Firestore and Storage emulator security tests' {
            firebase emulators:exec --project demo-campus-incident-reporter --only firestore,storage "npm --prefix firebase/rules-tests test"
        }
    }
    else {
        Write-Warning 'Firebase Emulator Suite tests were skipped by request.'
    }

    Invoke-CheckedCommand 'Build Android debug APK' { flutter build apk --debug }

    $apk = Join-Path $repositoryRoot 'build/app/outputs/flutter-apk/app-debug.apk'
    if (-not (Test-Path $apk)) {
        throw 'Flutter reported a successful build, but the debug APK was not found.'
    }

    Write-Host "`nPreparation completed successfully." -ForegroundColor Green
    Write-Host "Debug APK: $apk" -ForegroundColor Yellow
    Write-Host 'Next: connect an Android emulator/device and run flutter run.'
}
catch {
    Write-Error -ErrorAction Continue $_
    throw
}
finally {
    Pop-Location
}