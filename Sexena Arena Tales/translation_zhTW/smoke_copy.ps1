$ErrorActionPreference = 'Stop'
$stageRoot = Join-Path (Resolve-Path $PSScriptRoot).Path ('smoke_stage_' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stageRoot | Out-Null

Get-ChildItem -File (Split-Path $PSScriptRoot -Parent) | ForEach-Object {
    New-Item -ItemType HardLink -Path (Join-Path $stageRoot $_.Name) -Target $_.FullName | Out-Null
}
foreach ($dirName in @('locales', 'swiftshader')) {
    $sourceRoot = (Resolve-Path (Join-Path (Split-Path $PSScriptRoot -Parent) $dirName)).Path
    New-Item -ItemType Directory -Force -Path (Join-Path $stageRoot $dirName) | Out-Null
    Get-ChildItem -LiteralPath $sourceRoot -Directory -Recurse | ForEach-Object {
        $relative = $_.FullName.Substring($sourceRoot.Length).TrimStart('\')
        New-Item -ItemType Directory -Force -Path (Join-Path (Join-Path $stageRoot $dirName) $relative) | Out-Null
    }
    Get-ChildItem -LiteralPath $sourceRoot -File -Recurse | ForEach-Object {
        $relative = $_.FullName.Substring($sourceRoot.Length).TrimStart('\')
        New-Item -ItemType HardLink -Path (Join-Path (Join-Path $stageRoot $dirName) $relative) -Target $_.FullName | Out-Null
    }
}
Copy-Item -LiteralPath (Join-Path (Split-Path $PSScriptRoot -Parent) 'sqlite') -Destination (Join-Path $stageRoot 'sqlite') -Recurse
New-Item -ItemType Directory -Path (Join-Path $stageRoot 'resources') | Out-Null
New-Item -ItemType HardLink -Path (Join-Path $stageRoot 'resources\electron.asar') -Target (Resolve-Path (Join-Path (Split-Path $PSScriptRoot -Parent) 'resources\electron.asar')).Path | Out-Null
Copy-Item -LiteralPath (Join-Path (Split-Path $PSScriptRoot -Parent) 'resources\app.zhTW.tmp') -Destination (Join-Path $stageRoot 'resources\app.asar')

$game = Start-Process -FilePath (Join-Path $stageRoot 'Sexena.exe') -WorkingDirectory $stageRoot -WindowStyle Hidden -PassThru
Start-Sleep -Seconds 10
$game.Refresh()
if ($game.HasExited) {
    Write-Output "Smoke launch exited with code $($game.ExitCode). Stage: $stageRoot"
} else {
    Write-Output "Smoke launch stayed open for 10 seconds. Stage: $stageRoot"
    Stop-Process -Id $game.Id -Force
}
