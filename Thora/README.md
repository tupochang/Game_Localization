# Thora（托拉的勇者）繁體中文翻譯資料

本資料夾保存從遊戲安裝目錄 `D:\SteamLibrary\steamapps\common\Thora\translation` 複製的翻譯工作資料。原目錄保留，遊戲安裝檔沒有因本次整理而變動。

## 內容

- `translation/*.xlsx`：劇情翻譯、對照表與校對前備份。
- `translation/*.py`、`translation/*.mjs`：翻譯套用、資料庫與介面文字處理、校對腳本。
- `translation/*.json`、`translation/*.png`：開場測試文字與標題圖素材。
- `translation/backup_*`：各階段套用翻譯前的檔案備份，供追溯與還原。
- `translation/*.inspect.ndjson`：試算表檢視資料。

未複製原目錄中的 `node_modules` 目錄連結。腳本多以其上層資料夾作為遊戲根目錄，並直接修改 `www` 內容；此處僅供保存與檢視。若需重新執行，應先確認路徑與依賴，並在遊戲副本上操作。
