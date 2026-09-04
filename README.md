# ТЕКУЩАЯ ВЕРСИЯ ЕЩЕ В ПРОЦЕССЕ ТЕСТИРОВАНИЯ. КАК БУДЕТ ПРОЙДЕНА ПРОВЕРКА, ЭТА НАДПИСЬ БУДЕТ УДАЛЕНА


# zanzarah language patch

Патч для Steam-версии ZanZarah с переключением английского и русского языка.
Полный русский PAK не включён в репозиторий: установщик собирает его локально
из чистого Steam `resources\data_0.pak` и компактного overlay-набора.

## установка

1. В Steam выполните проверку целостности файлов ZanZarah.
2. Скачайте репозиторий и распакуйте/откройте его в отдельной папке.
3. Запустите `install.bat` от имени администратора.
4. Выберите папку Steam-игры ZanZarah.
5. Дождитесь завершения локальной сборки русского PAK.
6. Запустите игру через Steam.
7. Выберите язык в стартовом меню и нажмите `Apply`.

Сборка PAK выполняется один раз при установке и может занять несколько минут.

<img width="473" height="425" alt="image" src="https://github.com/user-attachments/assets/9857913e-cdac-4e22-93e1-08ee1416726d" />




## публикация изменений

```powershell
cd "H:\work\zms_language"; git add -A; git commit -m "update localization patch"; git push origin main
```

## восстановление

Запустите `restore.bat` из папки патча.


--------------------------------------------------------------------------------------------------------
# ZanZarah language patch

A patch for the Steam version of ZanZarah that allows you to switch between English and Russian.
The full Russian PAK is not included in the repository: the installer builds it locally
from the clean Steam `resources\data_0.pak` file and a compact overlay set.

## Installation

1. In Steam, verify the integrity of the ZanZarah files.
2. Download the repository and extract/open it in a separate folder.
3. Run `install.bat` as an administrator.
4. Select the Steam game folder for ZanZarah.
5. Wait for the local build of the Russian PAK to complete.
6. Launch the game via Steam.
7. Select the language in the start menu and click `Apply`.

The PAK build runs once during installation and may take several minutes.

## Publishing Changes

```powershell
cd “H:\work\zms_language”; git add -A; git commit -m “update localization patch”; git push origin main
```

## Restoring

Run `restore.bat` from the patch folder.

