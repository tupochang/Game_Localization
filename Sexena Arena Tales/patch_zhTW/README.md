# Sexena Arena Tales 繁體中文補丁

適用於原始 `resources/app.asar` SHA-256 為 `20CD7C3722B26891C25655DEE67E1B0C9DEBF7188F13DD278C766CB0674CAD9E` 的 Windows 版本。補丁不包含遊戲封包或存檔；安裝時從本機原始封包重建。

先關閉遊戲。在 PowerShell 中執行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -GameRoot 'D:\SteamLibrary\steamapps\common\Sexena Arena Tales'
```

還原原版：

```powershell
powershell -ExecutionPolicy Bypass -File .\restore.ps1 -GameRoot 'D:\SteamLibrary\steamapps\common\Sexena Arena Tales'
```

需要 Windows 的 `py -3`、Python 3 與 `C:\Windows\Fonts\NotoSansTC-VF.ttf`。安裝腳本會確認原版 SHA-256，並保留 `resources/app.original.asar` 作還原用。若遊戲更新導致原版雜湊不同，腳本會停止。存檔不會修改。

這是尚未完成全遊戲逐畫面校對的繁中補丁；詳情見歸檔中的 `translation_zhTW/README.md` 與 `pending_string_audit.md`。
