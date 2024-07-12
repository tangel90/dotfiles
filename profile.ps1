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
Set-Alias -Name "vim" -Value nvim

Set-PSReadLineKeyHandler -Key Ctrl+n -Function NextHistory
Set-PSReadLineKeyHandler -Key Ctrl+p -Function PreviousHistory
Set-PSReadLineKeyHandler -Key Ctrl+j -Function AcceptLine
Set-PSReadLineKeyHandler -Key Ctrl+f -Function ForwardChar
#Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
#Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
#Set-PSReadLineOption -EditMode Emacs

Remove-PSReadlineKeyHandler 'Ctrl+r'
Remove-PSReadlineKeyHandler 'Ctrl+t'

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

$env:FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
$env:FZF_DEFAULT_OPTS="--layout=reverse --inline-info --ansi --bind ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle"

$dotfilesPath = Join-Path $HOME "dotfiles"
$configPath = Join-Path $dotfilesPath ".config"
$PSConfigPath = Join-Path $configPath "PowerShell"
$env:Path += ";" + $PSConfigPath
#
oh-my-posh init pwsh --config (Join-Path $PSConfigPath "posh.json") | Invoke-Expression
#
#$MyPaths = Join-Path $PSConfigPath "MyPaths.ps1"
#if (-Not (Test-Path $MyPaths)) {
#    ni $MyPaths
#}
#. $MyPaths

$env:LC_MESSAGES="en-US" #said to fix german language within neovim

#Import-Module ZLocation
#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "C:\Users\TSchulz\AppData\Local\anaconda3\Scripts\conda.exe") {
    (& "C:\Users\TSchulz\AppData\Local\anaconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
  conda activate integrations
}
#endregion
