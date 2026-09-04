param([string]$gameroot = "d:\steam\steamapps\common\zanzarah")
$ErrorActionPreference = "Stop"
$backupdir = Join-Path $gameroot "zms_backup"
$cleanexe = Join-Path $backupdir "zanthp_clean.exe"
$cleanpak = Join-Path $gameroot "localization\pak\en.pak"
if (!(Test-Path -LiteralPath $cleanexe)) { throw "clean exe backup not found: $cleanexe" }
if (!(Test-Path -LiteralPath $cleanpak)) { throw "clean pak backup not found: $cleanpak" }
Copy-Item -LiteralPath $cleanexe -Destination (Join-Path $gameroot "system\zanthp.exe") -Force
Copy-Item -LiteralPath $cleanpak -Destination (Join-Path $gameroot "resources\data_0.pak") -Force
Remove-Item -LiteralPath (Join-Path $gameroot "system\zms_language_exp41.dll") -Force -ErrorAction SilentlyContinue
Write-Host "[zms] clean exe and english pak restored."

