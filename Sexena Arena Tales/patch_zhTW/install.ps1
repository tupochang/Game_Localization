param([string]$GameRoot = 'D:\SteamLibrary\steamapps\common\Sexena Arena Tales')
$ErrorActionPreference = 'Stop'
$GameRoot = (Resolve-Path -LiteralPath $GameRoot).Path
$resources = Join-Path $GameRoot 'resources'
$active = Join-Path $resources 'app.asar'
$original = Join-Path $resources 'app.original.asar'
$expected = '20CD7C3722B26891C25655DEE67E1B0C9DEBF7188F13DD278C766CB0674CAD9E'
if (-not (Test-Path -LiteralPath $active)) { throw "Game archive missing: $active" }
if (-not (Test-Path -LiteralPath $original)) {
    if ((Get-FileHash -LiteralPath $active -Algorithm SHA256).Hash -ne $expected) {
        throw 'Original game archive is missing and the installed archive does not match the supported version.'
    }
    Copy-Item -LiteralPath $active -Destination $original
}
if ((Get-FileHash -LiteralPath $original -Algorithm SHA256).Hash -ne $expected) {
    throw 'Original game archive does not match the supported version. No changes made.'
}
if (-not (Test-Path -LiteralPath 'C:\Windows\Fonts\NotoSansTC-VF.ttf')) {
    throw 'Noto Sans TC font is missing: C:\Windows\Fonts\NotoSansTC-VF.ttf'
}
$env:SEXENA_GAME_ROOT = $GameRoot
try {
    py -3 (Join-Path $PSScriptRoot 'build.py')
    if ($LASTEXITCODE -ne 0) { throw "Build failed with exit code $LASTEXITCODE" }
} finally {
    Remove-Item Env:SEXENA_GAME_ROOT -ErrorAction SilentlyContinue
}
Write-Host 'Traditional Chinese patch installed.'
