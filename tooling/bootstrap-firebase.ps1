param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ProjectId
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repositoryRoot

try {
    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        throw 'Flutter was not found on PATH.'
    }
    if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
        throw 'Dart was not found on PATH. Install Flutter, which includes Dart.'
    }
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        throw 'npm was not found on PATH. Install Node.js LTS first.'
    }

    if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
        Write-Host 'Installing Firebase CLI...' -ForegroundColor Cyan
        npm install --global firebase-tools
        if ($LASTEXITCODE -ne 0) {
            throw 'Firebase CLI installation failed.'
        }
    }

    Write-Host 'Checking Firebase account access...' -ForegroundColor Cyan
    $loginOutput = firebase login:list 2>&1
    $loginText = $loginOutput -join "`n"
    if ($LASTEXITCODE -ne 0 -or $loginText -match 'No authorized accounts') {
        Write-Host 'No Firebase CLI account is signed in. Starting Firebase login...' -ForegroundColor Yellow
        firebase login
        if ($LASTEXITCODE -ne 0) {
            throw 'Firebase login did not complete successfully.'
        }
        firebase login:list
        if ($LASTEXITCODE -ne 0) {
            throw 'Firebase CLI could not verify the signed-in account.'
        }
    }

    # Use explicit --project arguments throughout so the script does not
    # depend on a local .firebaserc alias or change the user's active project.
    Write-Host 'Configuring FlutterFire for Android...' -ForegroundColor Cyan
    dart pub global activate flutterfire_cli
    if ($LASTEXITCODE -ne 0) {
        throw 'FlutterFire CLI installation failed.'
    }

    $flutterfireCommand = Get-Command flutterfire -ErrorAction SilentlyContinue
    if ($flutterfireCommand) {
        flutterfire configure --project $ProjectId --platforms=android
    }
    else {
        dart pub global run flutterfire_cli:flutterfire configure --project $ProjectId --platforms=android
    }
    if ($LASTEXITCODE -ne 0) {
        throw 'FlutterFire configuration failed. Confirm that the Android application is registered in this Firebase project.'
    }

    $optionsFile = Join-Path $repositoryRoot 'lib/firebase_options.dart'
    if (-not (Test-Path $optionsFile)) {
        throw 'lib/firebase_options.dart was not generated.'
    }
    $optionsContent = Get-Content $optionsFile -Raw
    if ($optionsContent -match 'throw UnsupportedError') {
        throw 'The Firebase options file is still the setup placeholder. Rerun FlutterFire and select the Android app.'
    }

    Write-Host 'Firebase options generated.' -ForegroundColor Green
    Write-Host 'Ensure Email/Password Authentication, Cloud Firestore and Cloud Storage are enabled in Firebase Console.'
    Write-Host ''
    Write-Host 'The selected CLI project must be the same project used by FlutterFire.'
    Write-Host 'Rules and indexes are not deployed yet.'

    $deploy = Read-Host "Deploy Firestore rules/indexes and Storage rules to '$ProjectId'? Type YES to continue"
    if ($deploy -ceq 'YES') {
        firebase deploy --project $ProjectId --only firestore:rules,firestore:indexes,storage
        if ($LASTEXITCODE -ne 0) {
            throw 'Firebase deployment failed. Review the CLI output above.'
        }
        Write-Host 'Firebase rules and indexes deployed.' -ForegroundColor Green
    }
    else {
        Write-Host 'Deployment skipped. Review the rules, then deploy explicitly when ready.'
    }

    Write-Host ''
    Write-Host 'Next: run flutter pub get, flutter analyze, flutter test, and flutter run.'
}
finally {
    Pop-Location
}
