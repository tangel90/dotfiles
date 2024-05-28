$nvimConfigPath = Join-Path $env:LOCALAPPDATA "nvim"
$nvimConfigTarget = Join-Path $HOME "dotfiles\.config\nvim"
$dotfiles = $dotfilesPath
$config = $configPath

$profileFileName = "profile.ps1"
$profileTarget = Join-Path $dotfilesPath $profileFileName
$profile = $profileTarget

$profileDefault = "$Home\Documents\PowerShell\$profileFileName"
