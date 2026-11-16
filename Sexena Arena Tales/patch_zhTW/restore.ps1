param([string]$GameRoot = 'D:\SteamLibrary\steamapps\common\Sexena Arena Tales')
$ErrorActionPreference = 'Stop'
$GameRoot = (Resolve-Path -LiteralPath $GameRoot).Path
$resources = Join-Path $GameRoot 'resources'
$active = Join-Path $resources 'app.asar'
$original = Join-Path $resources 'app.original.asar'
$expected = '20CD7C3722B26891C25655DEE67E1B0C9DEBF7188F13DD278C766CB0674CAD9E'
if (-not (Test-Path -LiteralPath $original)) { throw "Original archive missing: $original" }
if ((Get-FileHash -LiteralPath $original -Algorithm SHA256).Hash -ne $expected) {
    throw 'Original game archive does not match the supported version. No changes made.'
}
Copy-Item -LiteralPath $original -Destination $active -Force
Write-Host 'Original game archive restored.'
