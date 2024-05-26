function GoUp {
  Set-Location ..
}

function lt {
  param (
      [string]$path = "."
  )
  eza -T --icons $path
}

function ll {
  param (
      [string]$path = "."
  )
  eza --long --icons --all $path
}

Set-Alias -Name ".." -Value GoUp
Set-Alias -Name "ls" -Value eza
Set-Alias -Name "cat" -Value bat
Set-Alias -Name "ss" -Value Select-String
Set-Alias -Name vim -Value nvim

Set-PSReadLineKeyHandler -Key Ctrl+n -Function NextHistory
Set-PSReadLineKeyHandler -Key Ctrl+p -Function PreviousHistory
Set-PSReadLineKeyHandler -Key Ctrl+j -Function AcceptLine
Set-PSReadLineKeyHandler -Key Ctrl+f -Function ForwardChar
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
#Set-PSReadLineOption -EditMode Vi

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

Import-Module ZLocation

$dotfilesPath = [System.IO.DirectoryInfo] (Join-Path $HOME "dotfiles")
$configPath = [System.IO.DirectoryInfo] (Join-Path $dotfilesPath ".config")
$PSConfigPath = [System.IO.DirectoryInfo] (Join-Path $configPath "PowerShell")

oh-my-posh init pwsh --config (Join-Path $PSConfigPath "posh.json") | Invoke-Expression

$MyPaths = Join-Path $PSConfigPath "MyPaths.ps1"
if (-Not (Test-Path $MyPaths)) {
    ni $MyPaths
}
. $MyPaths

$env:LC_MESSAGES="en-US" #said to fix german language within neovim
