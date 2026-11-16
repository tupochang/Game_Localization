# Thora 繁體中文補丁

適用於 Windows 版 Thora。補丁由目前已翻譯的遊戲安裝檔建立，包含劇情、資料庫、介面文字與標題圖。遊戲版本不同時，安裝前請自行確認相容性。

1. 將整個 `patch_zhTW` 資料夾下載或解壓縮。
2. 以 PowerShell 執行 `./install.ps1 -GameDir '遊戲安裝路徑'`。預設路徑是 `D:\SteamLibrary\steamapps\common\Thora`。
3. 安裝程式只替換清單中與補丁不同的檔案，並將原檔備份到遊戲的 `translation/patch_backup_日期時間`。
4. 需要還原時執行 `./restore.ps1 -GameDir '遊戲安裝路徑'`；預設使用最新備份。

`manifest.json` 記錄每個檔案的 SHA-256。`build.py` 用本機遊戲與翻譯階段備份重建補丁；一般使用者不需要執行。
