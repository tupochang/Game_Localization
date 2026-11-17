
param(
    [string]$GameDir = 'D:\SteamLibrary\steamapps\common\Knight Bewitched\Knight Bewitched Enhanced Edition',
    [switch]$Restore,
    [string]$BackupDir
)
$ErrorActionPreference = 'Stop'
$GameDir = (Resolve-Path -LiteralPath $GameDir).ProviderPath
$package = Get-Content -LiteralPath (Join-Path $GameDir 'package.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if ($package.window.title -ne 'Knight Bewitched Enhanced Edition') {
    throw "Select the Enhanced Edition game folder: $GameDir"
}
if (Get-Process -Name 'Game' -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq (Join-Path $GameDir 'Game.exe') }) {
    throw 'Close the game before applying or restoring the patch.'
}
if ($Restore) {
    if (-not $BackupDir) {
        $BackupDir = Get-ChildItem -LiteralPath $GameDir -Directory -Filter 'zhTW_patch_backup_*' |
            Sort-Object Name -Descending | Select-Object -First 1 -ExpandProperty FullName
    }
    if (-not $BackupDir) { throw 'No patch backup found. Use -BackupDir to choose one.' }
    $sourceRoot = (Resolve-Path -LiteralPath $BackupDir).ProviderPath
    $manifestPath = Join-Path $sourceRoot 'manifest.json'
} else {
    $sourceRoot = Join-Path $PSScriptRoot 'payload'
    $manifestPath = Join-Path $PSScriptRoot 'manifest.json'
}

function Get-Checksum($Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}
function Set-File($Source, $Target) {
    $pendingFile = "$Target.zhTW-$([guid]::NewGuid().ToString('N')).tmp"
    try {
        Copy-Item -LiteralPath $Source -Destination $pendingFile
        [IO.File]::Replace($pendingFile, $Target, [NullString]::Value)
    } finally {
        if (Test-Path -LiteralPath $pendingFile) { Remove-Item -LiteralPath $pendingFile }
    }
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $manifest.Count) { throw 'Empty patch manifest.' }
$pending = @(
    foreach ($entry in $manifest) {
        if ($entry.path -cnotmatch '^(data/[a-zA-Z0-9]+\.json|js/plugins\.js|js/plugins/KBR_CORE\.js)$') {
            throw "Unexpected path: $($entry.path)"
        }
        $source = Join-Path $sourceRoot $entry.path
        $target = Join-Path $GameDir $entry.path
        $before = $entry.original_sha256
        $after = $entry.localized_sha256
        if ($Restore) { $before, $after = $after, $before }
        if ((Get-Checksum $source) -ne $after) { throw "Invalid patch or backup file: $source" }
        $hash = Get-Checksum $target
        if ($hash -eq $after) { continue }
        if ($hash -ne $before) { throw "Game version or file differs from this patch: $target" }
        $entry
    }
)
if (-not $pending.Count) {
    Write-Host 'All targeted files are already in the requested state.'
    exit 0
}

$backup = Join-Path $GameDir ('zhTW_patch_backup_' + (Get-Date -Format 'yyyyMMdd_HHmmss_fff'))
if ($Restore) { $backup = Join-Path ([IO.Path]::GetTempPath()) ('KnightBewitched-' + [guid]::NewGuid().ToString('N')) }
New-Item -ItemType Directory -Path $backup | Out-Null
foreach ($entry in $pending) {
    $saved = Join-Path $backup $entry.path
    New-Item -ItemType Directory -Path (Split-Path $saved) -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $GameDir $entry.path) -Destination $saved
    $expected = $entry.original_sha256
    if ($Restore) { $expected = $entry.localized_sha256 }
    if ((Get-Checksum $saved) -ne $expected) { throw "Game file changed during backup: $($entry.path)" }
}
if (-not $Restore) {
    ConvertTo-Json -InputObject $pending -Depth 4 |
        Set-Content -LiteralPath (Join-Path $backup 'manifest.json') -Encoding UTF8
}
$written = @()
try {
    foreach ($entry in $pending) {
        $target = Join-Path $GameDir $entry.path
        if ((Get-Checksum $target) -ne (Get-Checksum (Join-Path $backup $entry.path))) {
            throw "Game file changed during patch: $target"
        }
        Set-File (Join-Path $sourceRoot $entry.path) $target
        $written += $entry
    }
} catch {
    foreach ($entry in $written) {
        Set-File (Join-Path $backup $entry.path) (Join-Path $GameDir $entry.path)
    }
    throw
}
if ($Restore) {
    Write-Host "Restored $($written.Count) files."
} else {
    Write-Host "Installed $($written.Count) files. Backup: $backup"
}
