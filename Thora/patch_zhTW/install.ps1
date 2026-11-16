param([string]$GameDir = 'D:\SteamLibrary\steamapps\common\Thora')
$ErrorActionPreference = 'Stop'
$GameDir = [IO.Path]::GetFullPath($GameDir)
if (-not (Test-Path -LiteralPath (Join-Path $GameDir 'Game.exe') -PathType Leaf)) { throw "Thora not found: $GameDir" }
$manifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$backup = Join-Path $GameDir ('translation\patch_backup_' + (Get-Date -Format 'yyyyMMdd_HHmmss'))
$pending = @()
foreach ($item in $manifest) {
    if ($item.path -notmatch '^www/(data/[A-Za-z0-9]+\.json|js/[A-Za-z0-9_./-]+\.js|img/titles1/Champions of Thora\.rpgmvp)$' -or $item.path.Contains('..')) { throw "Unsafe path: $($item.path)" }
    $src = Join-Path $PSScriptRoot ('payload/' + $item.path)
    $target = Join-Path $GameDir $item.path
    if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { throw "Missing game file: $target" }
    if ((Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash.ToLowerInvariant() -ne $item.sha256) { throw "Patch checksum mismatch: $src" }
    if ((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant() -ne $item.sha256) { $pending += $item }
}
if ($pending.Count -eq 0) { Write-Host 'Patch already installed.'; exit 0 }
New-Item -ItemType Directory -Path $backup -Force | Out-Null
foreach ($item in $pending) {
    $target = Join-Path $GameDir $item.path
    $saved = Join-Path $backup $item.path
    New-Item -ItemType Directory -Path (Split-Path $saved) -Force | Out-Null
    Copy-Item -LiteralPath $target -Destination $saved
}
$pending | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $backup 'manifest.json') -Encoding UTF8
foreach ($item in $pending) { Copy-Item -LiteralPath (Join-Path $PSScriptRoot ('payload/' + $item.path)) -Destination (Join-Path $GameDir $item.path) -Force }
Write-Host "Installed $($pending.Count) files. Backup: $backup"
