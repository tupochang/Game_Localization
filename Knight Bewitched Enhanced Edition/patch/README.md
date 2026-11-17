# Knight Bewitched Enhanced Edition 繁體中文補丁

適用於 Windows Steam 強化版 v2.00。請先關閉遊戲，完整解壓縮補丁，再從解壓縮目錄執行。

```powershell
powershell -ExecutionPolicy Bypass -File .\patch.ps1 -GameDir 'D:\SteamLibrary\steamapps\common\Knight Bewitched\Knight Bewitched Enhanced Edition'
```

補丁先核對遊戲檔案，再備份與替換已漢化的資料。安裝後從強化版目錄開啟 `Game.exe`。存檔位於 `save`。

還原時使用相同命令並加上 `-Restore`。腳本會使用最近一次補丁安裝建立的備份，也可以用 `-BackupDir` 指定備份目錄。若遊戲更新後檔案與清單不符，腳本會在寫入前停止。
