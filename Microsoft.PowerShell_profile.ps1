function GoUp {
  Set-Location ..
}

function lt {
  param (
      [string]$path = "."
  )
  eza -T --all --icons $path
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

oh-my-posh init pwsh --config "~\dotfiles_windows\posh.json" | Invoke-Expression

Set-PSReadLineKeyHandler -Key Ctrl+n -Function NextHistory
Set-PSReadLineKeyHandler -Key Ctrl+p -Function PreviousHistory
Set-PSReadLineKeyHandler -Key Ctrl+j -Function AcceptLine
Set-PSReadLineKeyHandler -Key Ctrl+f -Function ForwardChar
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

Import-Module ZLocation

#Set-PSReadLineOption -EditMode Vi
#Invoke-Expression (& { (zoxide init powershell | Out-String) })
$profileTarget = Join-Path $dotfilesPath (gci $profile).Name
$env:LC_MESSAGES="en-US" #said to fix german language within neovim
$ProfilePath = (gci $profile).DirectoryName
$PathsFile = Join-Path $ProfilePath "MyPaths.ps1"
if (-Not (Test-Path $PathsFile)) {
    ni $PathsFile
}

. $PathsFile
