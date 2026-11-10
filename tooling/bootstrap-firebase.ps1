param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ProjectId = 'inzira-498621'
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

        # Refresh this PowerShell process PATH. A global npm install can place
        # firebase.cmd in the npm prefix, which may not be on the current PATH.
        $npmGlobalPrefix = (& npm config get prefix 2>$null | Out-String).Trim()
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($npmGlobalPrefix)) {
            throw 'Firebase CLI was installed, but npm did not return its global command directory. Open a new PowerShell window and retry.'
        }
        if (($env:Path -split ';') -notcontains $npmGlobalPrefix) {
            $env:Path = "$npmGlobalPrefix;$env:Path"
        }
    }

    if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
        throw 'Firebase CLI is not available in this PowerShell session. Open a new PowerShell window and retry.'
    }

    Write-Host "Checking access to Firebase project '$ProjectId'..." -ForegroundColor Cyan
    $projectListOutput = firebase projects:list --json 2>&1
    $projectListExitCode = $LASTEXITCODE

    if ($projectListExitCode -ne 0) {
        Write-Host 'Firebase authentication is required. Complete the Google sign-in window.' -ForegroundColor Yellow
        firebase login
        if ($LASTEXITCODE -ne 0) {
            throw 'Firebase login did not complete successfully.'
        }

        $projectListOutput = firebase projects:list --json 2>&1
        $projectListExitCode = $LASTEXITCODE
    }

    if ($projectListExitCode -ne 0) {
        throw 'The Firebase CLI could not list projects. Confirm that the signed-in Google account has access to INZIRA (inzira-498621).'
    }

    $projectListText = $projectListOutput | Out-String
    if ($projectListText -notmatch [regex]::Escape($ProjectId)) {
        throw "The signed-in Google account cannot see Firebase project '$ProjectId'. Grant this account access to the project, then rerun the script."
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
    Write-Host 'Ensure Email/Password Authentication is enabled and Cloud Firestore is created in Firebase Console.'
    Write-Host 'Cloud Storage is optional and requires Blaze billing plus a provisioned bucket; it is not required to start the app or submit reports without photos.'
    Write-Host ''
    Write-Host 'The selected CLI project must be the same project used by FlutterFire.'
    Write-Host 'Rules and indexes are not deployed yet.'

    $deployFirestore = Read-Host "Deploy Firestore rules and indexes to '$ProjectId'? Type YES to continue"
    if ($deployFirestore -ceq 'YES') {
        firebase deploy --project $ProjectId --only firestore:rules,firestore:indexes
        if ($LASTEXITCODE -ne 0) {
            throw 'Firestore rules/index deployment failed. Review the CLI output above.'
        }
        Write-Host 'Firestore rules and indexes deployed.' -ForegroundColor Green
    }
    else {
        Write-Host 'Firestore deployment skipped. You can deploy it after reviewing the rules.'
    }

    Write-Host ''
    Write-Host 'Cloud Storage billing requirement:' -ForegroundColor Yellow
    Write-Host 'Firebase Storage requires the Blaze pay-as-you-go plan and a provisioned bucket.'
    Write-Host 'The INZIRA project was shown on the Spark plan. Skip Storage deployment unless you deliberately upgraded and created its bucket.'
    $deployStorage = Read-Host "Deploy Storage rules to '$ProjectId'? Type YES only when Blaze billing and the bucket are ready"
    if ($deployStorage -ceq 'YES') {
        firebase deploy --project $ProjectId --only storage
        if ($LASTEXITCODE -ne 0) {
            throw 'Storage rules deployment failed. Confirm Blaze billing and that the default Storage bucket exists.'
        }
        Write-Host 'Storage rules deployed.' -ForegroundColor Green
    }
    else {
        Write-Host 'Storage deployment skipped. Photo uploads remain unavailable until Storage is enabled on a supported billing plan.'
    }

    Write-Host ''
    Write-Host 'Next: run flutter pub get, flutter analyze, flutter test, and flutter run.'
}
finally {
    Pop-Location
}
