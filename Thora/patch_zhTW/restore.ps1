param([string]$GameDir = 'D:\SteamLibrary\steamapps\common\Thora', [string]$BackupDir)
$ErrorActionPreference = 'Stop'
$GameDir = [IO.Path]::GetFullPath($GameDir)
if (-not $BackupDir) {
    $BackupDir = Get-ChildItem -LiteralPath (Join-Path $GameDir 'translation') -Directory -Filter 'patch_backup_*' | Sort-Object Name -Descending | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $BackupDir) { throw 'No patch backup found.' }
$BackupDir = [IO.Path]::GetFullPath($BackupDir)
$expected = [IO.Path]::GetFullPath((Join-Path $GameDir 'translation')) + [IO.Path]::DirectorySeparatorChar
if (-not $BackupDir.StartsWith($expected, [StringComparison]::OrdinalIgnoreCase)) { throw "Backup outside game translation folder: $BackupDir" }
$manifest = Get-Content -LiteralPath (Join-Path $BackupDir 'manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
foreach ($item in $manifest) {
    if ($item.path -notmatch '^www/' -or $item.path.Contains('..')) { throw "Unsafe path: $($item.path)" }
    $saved = Join-Path $BackupDir $item.path
    if (-not (Test-Path -LiteralPath $saved -PathType Leaf)) { throw "Missing backup file: $saved" }
}
foreach ($item in $manifest) { Copy-Item -LiteralPath (Join-Path $BackupDir $item.path) -Destination (Join-Path $GameDir $item.path) -Force }
Write-Host "Restored $($manifest.Count) files from $BackupDir"
