$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repositoryRoot

try {
    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        throw 'Flutter was not found on PATH. Install Flutter and reopen PowerShell.'
    }

    Write-Host 'Checking the Flutter toolchain...' -ForegroundColor Cyan
    flutter --version
    flutter doctor -v

    $androidDirectory = Join-Path $repositoryRoot 'android'
    $manifest = Join-Path $androidDirectory 'app/src/main/AndroidManifest.xml'
    $androidReadme = Join-Path $androidDirectory 'README.md'
    $savedReadme = $null

    if (-not (Test-Path $manifest) -and (Test-Path $androidDirectory)) {
        $existingEntries = @(Get-ChildItem -Force $androidDirectory)
        $unexpectedEntries = @(
            $existingEntries | Where-Object { $_.Name -ne 'README.md' }
        )
        if ($unexpectedEntries.Count -gt 0) {
            $names = ($unexpectedEntries | ForEach-Object Name) -join ', '
            throw "The android folder contains files other than README.md ($names). Review them before generating the native runner."
        }

        if (Test-Path $androidReadme) {
            $savedReadme = Get-Content $androidReadme -Raw
        }

        Write-Host 'Preparing the documentation-only Android folder...' -ForegroundColor Cyan
        Remove-Item -Recurse -Force $androidDirectory
    }

    if (-not (Test-Path $manifest)) {
        Write-Host 'Generating the Android runner...' -ForegroundColor Cyan
        flutter create --platforms=android --org com.byusa .
        if ($LASTEXITCODE -ne 0) {
            throw 'flutter create failed. Review the Flutter output above.'
        }
    }
    else {
        Write-Host 'Android runner already exists; leaving generated files unchanged.' -ForegroundColor Green
    }

    if (-not (Test-Path $manifest)) {
        throw 'AndroidManifest.xml was not generated. Check the Flutter installation.'
    }

    if ($null -ne $savedReadme) {
        Set-Content -Path (Join-Path $androidDirectory 'README.md') -Value $savedReadme -Encoding utf8
    }

    $applicationId = $null
    $gradleFiles = @(
        (Join-Path $repositoryRoot 'android/app/build.gradle.kts'),
        (Join-Path $repositoryRoot 'android/app/build.gradle')
    )
    foreach ($gradleFile in $gradleFiles) {
        if (Test-Path $gradleFile) {
            $gradleContent = Get-Content $gradleFile -Raw
            if ($gradleContent -match 'applicationId\s*=\s*"([^"]+)"') {
                $applicationId = $Matches[1]
                break
            }
            if ($gradleContent -match 'applicationId\s+"([^"]+)"') {
                $applicationId = $Matches[1]
                break
            }
        }
    }

    Write-Host 'Installing Flutter dependencies...' -ForegroundColor Cyan
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        throw 'flutter pub get failed. Review the dependency error above.'
    }

    Write-Host ''
    Write-Host 'Android runner is ready.' -ForegroundColor Green
    if ($applicationId) {
        Write-Host "Android application ID: $applicationId" -ForegroundColor Yellow
        Write-Host 'Register this exact application ID in Firebase Console.'
    }
    else {
        Write-Warning 'Could not read the application ID. Check android/app/build.gradle(.kts).'
    }

    Write-Host ''
    Write-Host 'Next: run the Firebase setup script with your real Firebase project ID:'
    Write-Host '.\tooling\bootstrap-firebase.ps1 -ProjectId YOUR_FIREBASE_PROJECT_ID'
}
finally {
    Pop-Location
}
