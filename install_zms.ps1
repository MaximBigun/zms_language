param([string]$gameroot = "")

$ErrorActionPreference = "Stop"
if ([string]::IsNullOrWhiteSpace($gameroot) -or !(Test-Path -LiteralPath $gameroot)) {
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Выберите папку Steam игры ZanZarah"
    if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { exit 1 }
    $gameroot = $dialog.SelectedPath
}
$gameroot = $gameroot.TrimEnd('\','/')
$cleanExeHash = "1e90cb72ab83c88c74bf3488d9c9e56dd9fd18abf6e66c4fe98f375b9f6e2cdc"
$languageExeHash = "079146303da352df5b83e846c8acb44e0a4f481990027c717345da3949389c0e"
$cleanPakHash = "c1ce0ab5fbaf0e4ef9e03461070865314743689531e959083f6460b938334432"
$ruPakHash = "4f348acfa91e87f99cb73945eb841b2e0040bc46340f4ccc7370d77fcb18ea44"

function hash([string]$path) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLower() }
function log([string]$text) { Write-Host "[zms] $text" }

$scriptdir = Split-Path -Parent $MyInvocation.MyCommand.Path
$systemdir = Join-Path $gameroot "system"
$datadir = Join-Path $gameroot "data"
$resourcesdir = Join-Path $gameroot "resources"
$localizationdir = Join-Path $gameroot "localization"
$pakdir = Join-Path $localizationdir "pak"
$backupdir = Join-Path $gameroot "zms_backup"
$exe = Join-Path $systemdir "zanthp.exe"
$pak = Join-Path $resourcesdir "data_0.pak"
$payloadexe = Join-Path $scriptdir "zanthp_language.exe"
$payloaddll = Join-Path $scriptdir "zms_language_exp41.dll"
$builder = Join-Path $scriptdir "build_overlay_pak.ps1"
$existingCleanExe = Join-Path $systemdir "zanthp_zms_original.exe"

Write-Host ""
Write-Host "zanzarah zms language patch - english + russian + ukrainian"
Write-Host ""

foreach ($required in @($exe, $pak, $payloadexe, $payloaddll, $builder)) {
    if (!(Test-Path -LiteralPath $required -PathType Leaf)) { throw "required file not found: $required" }
}

$exeHash = hash $exe
if ($exeHash -notin @($cleanExeHash, $languageExeHash)) { throw "unsupported zanthp.exe sha256: $exeHash" }
if ((hash $payloadexe) -ne $languageExeHash) { throw "corrupt language-enabled zanthp.exe" }

New-Item -ItemType Directory -Force -Path $localizationdir,$pakdir,$backupdir | Out-Null

$backupExe = Join-Path $backupdir "zanthp_clean.exe"
if (!(Test-Path -LiteralPath $backupExe)) {
    if ($exeHash -eq $cleanExeHash) {
        Copy-Item -LiteralPath $exe -Destination $backupExe
    } elseif ((Test-Path -LiteralPath $existingCleanExe -PathType Leaf) -and ((hash $existingCleanExe) -eq $cleanExeHash)) {
        log "using existing clean exe backup from system\zanthp_zms_original.exe"
        Copy-Item -LiteralPath $existingCleanExe -Destination $backupExe
    } else {
        throw "clean exe backup is missing; verify game files in steam first"
    }
}
if ((hash $backupExe) -ne $cleanExeHash) { throw "invalid clean exe backup: $backupExe" }

$enPak = Join-Path $pakdir "en.pak"
if (!(Test-Path -LiteralPath $enPak)) {
    $pakHash = hash $pak
    if ($pakHash -eq $cleanPakHash) {
        log "saving clean english pak (about 774 mb)..."
        Copy-Item -LiteralPath $pak -Destination $enPak
    } else {
        $cleanPakSource = $null
        $searchDirs = @($resourcesdir, "d:\steam\steamapps\common\zanzarah\resources") | Select-Object -Unique
        $candidates = @()
        foreach ($searchDir in $searchDirs) {
            if (Test-Path -LiteralPath $searchDir -PathType Container) {
                $candidates += Get-ChildItem -LiteralPath $searchDir -File -Force | Where-Object { $_.Name -like "data_0*" }
            }
        }
        foreach ($candidate in $candidates) {
            if ((Test-Path -LiteralPath $candidate.FullName -PathType Leaf) -and ((hash $candidate.FullName) -eq $cleanPakHash)) {
                $cleanPakSource = $candidate.FullName
                break
            }
        }
        if ($null -eq $cleanPakSource) { throw "clean steam data_0.pak required; actual sha256: $pakHash" }
        log "using existing clean english pak backup: $cleanPakSource"
        Copy-Item -LiteralPath $cleanPakSource -Destination $enPak
    }
}
if ((hash $enPak) -ne $cleanPakHash) { throw "invalid english pak backup: $enPak" }

log "installing language payload..."
Copy-Item -Path (Join-Path $scriptdir "localization\en\*") -Destination (New-Item -ItemType Directory -Force -Path (Join-Path $localizationdir "en")) -Force
Copy-Item -Path (Join-Path $scriptdir "localization\ru\*") -Destination (New-Item -ItemType Directory -Force -Path (Join-Path $localizationdir "ru")) -Recurse -Force
Copy-Item -Path (Join-Path $scriptdir "localization\uk\*") -Destination (New-Item -ItemType Directory -Force -Path (Join-Path $localizationdir "uk")) -Recurse -Force
$overlay = Join-Path $scriptdir "localization\overlay_ru"
if (!(Test-Path -LiteralPath $overlay -PathType Container)) { throw "russian overlay not found: $overlay" }
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $builder -basepak $enPak -overlaydir $overlay -output (Join-Path $pakdir "ru.pak")
Copy-Item -LiteralPath (Join-Path $scriptdir "localization\zms_apply_language.ps1") -Destination $localizationdir -Force
Copy-Item -LiteralPath $payloaddll -Destination (Join-Path $systemdir "zms_language_exp41.dll") -Force
Copy-Item -LiteralPath $payloadexe -Destination $exe -Force

Copy-Item -Path (Join-Path $localizationdir "en\*.fbs") -Destination $datadir -Force
Copy-Item -LiteralPath $enPak -Destination $pak -Force
Set-Content -LiteralPath (Join-Path $localizationdir "zms_language.ini") -Encoding ascii -Value "[zms]`r`nlanguage=en"

Write-Host ""
log "installed successfully; active language: english"
Write-Host "Start with Steam, open Settings, select English, Russian, or Ukrainian, and press Apply."


