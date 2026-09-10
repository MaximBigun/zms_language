param(
    [ValidateSet("en", "ru", "uk")][string]$language,
    [int]$processid
)

$ErrorActionPreference = "Stop"
$localizationdir = Split-Path -Parent $MyInvocation.MyCommand.Path
$gameroot = Split-Path -Parent $localizationdir
$sourcefbs = Join-Path $localizationdir $language
$sourcepak = Join-Path $localizationdir "pak\$language.pak"
if ($language -eq "uk" -and !(Test-Path -LiteralPath $sourcepak -PathType Leaf)) { $sourcepak = Join-Path $localizationdir "pak\ru.pak" }
$datadir = Join-Path $gameroot "data"
$backupfbs = Join-Path $localizationdir "steam_en"
$targetpak = Join-Path $gameroot "resources\data_0.pak"
$launcher = Join-Path $gameroot "system\zanthp.exe"
$logfile = Join-Path $localizationdir "zms_language.log"
$audioSource = Join-Path $localizationdir "$language\audio\SFX\VOICES\AMY"
$audioTarget = Join-Path $gameroot "resources\audio\SFX\VOICES\AMY"
$audioBackup = Join-Path $localizationdir "audio_original\SFX\VOICES\AMY"
$videoSource = Join-Path $localizationdir "$language\video"
$videoTarget = Join-Path $gameroot "resources\Videos"
$videoBackup = Join-Path $localizationdir "video_original"

try {
    Set-Content -LiteralPath (Join-Path $localizationdir "zms_language.ini") -Encoding ascii -Value "[zms]`r`nlanguage=$language"
    $p = Get-Process -Id $processid -ErrorAction SilentlyContinue
    if ($p) { Stop-Process -Id $processid -Force -ErrorAction SilentlyContinue }
    Wait-Process -Id $processid -Timeout 30 -ErrorAction SilentlyContinue
    for ($n = 0; $n -lt 240 -and (Get-Process -Name "zanthp" -ErrorAction SilentlyContinue); $n++) { Start-Sleep -Milliseconds 250 }
    if (Get-Process -Name "zanthp" -ErrorAction SilentlyContinue) { throw "zanthp.exe did not exit before restart" }
    if (!(Test-Path -LiteralPath $sourcepak -PathType Leaf)) { throw "pak not found: $sourcepak" }
    if (!(Test-Path -LiteralPath $sourcefbs -PathType Container)) { throw "fbs folder not found: $sourcefbs" }
    if (!(Test-Path -LiteralPath $backupfbs -PathType Container)) { New-Item -ItemType Directory -Path $backupfbs -Force | Out-Null }
    foreach ($f in Get-ChildItem -LiteralPath $datadir -Filter "*.fbs" -File) {
        $b = Join-Path $backupfbs $f.Name
        if (!(Test-Path -LiteralPath $b)) { Copy-Item -LiteralPath $f.FullName -Destination $b -Force }
    }
    if ($language -eq "en") { Copy-Item -Path (Join-Path $backupfbs "*.fbs") -Destination $datadir -Force }
    else { Copy-Item -Path (Join-Path $sourcefbs "*.fbs") -Destination $datadir -Force }
    if (!(Test-Path -LiteralPath $audioBackup)) { New-Item -ItemType Directory -Path $audioBackup -Force | Out-Null }
    if (!(Test-Path -LiteralPath $audioTarget)) { New-Item -ItemType Directory -Path $audioTarget -Force | Out-Null }
    if (Test-Path -LiteralPath $audioTarget) {
        foreach ($wav in Get-ChildItem -LiteralPath $audioTarget -File -Include *.wav,*.WAV) {
            $original = Join-Path $audioBackup $wav.Name
            if (!(Test-Path -LiteralPath $original)) { Copy-Item -LiteralPath $wav.FullName -Destination $original -Force }
        }
    }
    if (Test-Path -LiteralPath $audioSource) {
        Remove-Item -LiteralPath (Join-Path $audioTarget '*') -Force -ErrorAction SilentlyContinue
        Copy-Item -Path (Join-Path $audioSource "*") -Destination $audioTarget -Force
    } elseif (Test-Path -LiteralPath $audioBackup) {
        Remove-Item -LiteralPath (Join-Path $audioTarget '*') -Force -ErrorAction SilentlyContinue
        Copy-Item -Path (Join-Path $audioBackup "*") -Destination $audioTarget -Force
    }
    if (!(Test-Path -LiteralPath $videoBackup)) { New-Item -ItemType Directory -Path $videoBackup -Force | Out-Null }
    if (!(Test-Path -LiteralPath $videoTarget)) { New-Item -ItemType Directory -Path $videoTarget -Force | Out-Null }
    foreach ($vid in Get-ChildItem -LiteralPath $videoTarget -File -ErrorAction SilentlyContinue) {
        $original = Join-Path $videoBackup $vid.Name
        if (!(Test-Path -LiteralPath $original)) { Copy-Item -LiteralPath $vid.FullName -Destination $original -Force }
    }
    if (Test-Path -LiteralPath $videoSource) {
        Remove-Item -LiteralPath (Join-Path $videoTarget '*') -Force -ErrorAction SilentlyContinue
        Copy-Item -Path (Join-Path $videoSource "*") -Destination $videoTarget -Recurse -Force
    } elseif (Test-Path -LiteralPath $videoBackup) {
        Remove-Item -LiteralPath (Join-Path $videoTarget '*') -Force -ErrorAction SilentlyContinue
        Copy-Item -Path (Join-Path $videoBackup "*") -Destination $videoTarget -Force
    }
    $copied = $false
    for ($n = 0; $n -lt 30 -and !$copied; $n++) {
        try { Copy-Item -LiteralPath $sourcepak -Destination $targetpak -Force; $copied = $true }
        catch { Start-Sleep -Milliseconds 500 }
    }
    if (!$copied) { throw "could not replace data_0.pak after waiting" }
    Set-Content -LiteralPath (Join-Path $localizationdir "zms_language.ini") -Encoding ascii -Value "[zms]`r`nlanguage=$language"
    Add-Content -LiteralPath $logfile -Encoding utf8 -Value "$(Get-Date -Format s) applied $language"
    Start-Sleep -Milliseconds 700
    Start-Sleep -Milliseconds 500
    Start-Process -FilePath "steam://rungameid/384570"
}
catch {
    Add-Content -LiteralPath $logfile -Encoding utf8 -Value "$(Get-Date -Format s) error: $($_.Exception.Message)"
}
