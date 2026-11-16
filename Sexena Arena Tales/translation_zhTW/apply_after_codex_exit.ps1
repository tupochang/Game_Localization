$ErrorActionPreference = 'Stop'
$root = 'D:\SteamLibrary\steamapps\common\Sexena Arena Tales'
$target = Join-Path $root 'resources\app.asar'
$pending = Join-Path $root 'resources\app.zhTW.tmp'
$previous = Join-Path $root 'resources\app.preceding.zhTW.asar'
$ownerPid = 20228
$ownerPath = 'C:\Program Files\WindowsApps\OpenAI.Codex_26.1002.7124.0_x64__2p2nqsd0c76g0\app\ChatGPT.exe'

while ($true) {
    $owner = Get-CimInstance Win32_Process -Filter "ProcessId=$ownerPid" -ErrorAction SilentlyContinue
    if (-not $owner -or $owner.ExecutablePath -ne $ownerPath) { break }
    Start-Sleep -Seconds 5
}

if (-not (Test-Path -LiteralPath $pending)) { throw "Pending archive not found: $pending" }
if (Test-Path -LiteralPath $previous) { throw "Refusing to overwrite the prior patch backup: $previous" }
Move-Item -LiteralPath $target -Destination $previous
try {
    Move-Item -LiteralPath $pending -Destination $target
} catch {
    Move-Item -LiteralPath $previous -Destination $target
    throw
}
