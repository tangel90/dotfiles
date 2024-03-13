$dev = "D:\dev\"
$projects = "D:\dev\projects"
$env:PYTHONPATH = "D:\dev\projects\;D:\dev\github\;D:\dev\"
$env:HOME = "C:\Users\Thoma"
$jstest = "D:\dev\playground\js\test.js"
$pytest = "D:\dev\playground\python\test.py"

oh-my-posh init pwsh | Invoke-Expression
oh-my-posh init pwsh --config 'C:\Users\Thoma\AppData\Local\Programs\oh-my-posh\themes\froczh.omp.json' | Invoke-Expression

function GoUp { Set-Location .. }
New-Alias .. GoUp

#conda config --set auto_activate_base false
