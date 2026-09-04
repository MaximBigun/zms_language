zanzarah zms language patch - stable en + ru base

supported clean steam files:
  zanthp.exe sha256: 1e90cb72ab83c88c74bf3488d9c9e56dd9fd18abf6e66c4fe98f375b9f6e2cdc
  data_0.pak sha256: c1ce0ab5fbaf0e4ef9e03461070865314743689531e959083f6460b938334432

install:
  1. verify zanzarah files in steam.
  2. extract this archive.
  3. run install.bat and select the Steam ZanZarah folder in the dialog.
  4. start zanzarah through steam.
  5. open settings, choose english or russian, then press apply.

default game path:
  d:\steam\steamapps\common\zanzarah

custom game path, one-line powershell command:
  powershell.exe -noprofile -executionpolicy bypass -file .\install_zms.ps1 -gameroot "e:\games\zanzarah"

restore:
  run restore.bat

the installer creates clean backups inside the game folder under zms_backup and
localization\pak\en.pak. The installer builds the Russian PAK from the clean
Steam PAK and localization\overlay_ru; no full Russian PAK is downloaded.
game language switching uses fb0x02 and fb0x06;
fb0x05 is reserved for the modding suite and fb0x01 is never replaced.
localization\localization_keys.json is the separate key catalog foundation for
future translations. diagnostic output is written to localization\zms_language.log.
