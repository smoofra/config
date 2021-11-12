
# copy profile.ps1 $profile.CurrentUserAllHosts

Set-PSReadLineOption -EditMode Emacs

Set-Alias -Name which -Value Get-Command

Function path() {
 $hklm = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name Path).Path
 $hkcu = (Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name Path).Path

 echo "==== HKLM"
 echo $hklm.split(";") | where{$_ -ne ""}
 echo ""

 echo "==== HKCU"
 echo $hkcu.split(";") | where{$_ -ne ""}
 echo ""

 echo "==== process"
 echo $env:path.split(";") | where{$_ -ne ""}
 echo ""
}

function env() {
    python -c   'import os; [print(f\"{k}={v}\") for k,v in os.environ.items()]'
}

function add-to-global-path($x) {
    $p = 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment'
    $r = (Get-ItemProperty -Path $p -Name Path).Path
    $r += ";" + $x
    Set-ItemProperty -Path $p -Name Path -Value $r
}

function add-to-user-path($x) {
    $p  = 'Registry::HKEY_CURRENT_USER\Environment'
    $r = (Get-ItemProperty -Path $p -Name Path).Path
    $r += ";" + $x
    Set-ItemProperty -Path $p -Name Path -Value $r
}

if ($(hostname) -eq "tengu") {
    $dotfiles = "z:\config"
} else {
    $dotfiles = "$HOME\config"
}

#remember, invoke as ". vcvars"
Function vcvars() {
    cmd /c "$dotfiles\vcvars.bat"
    Import-CliXml ~/vcvars.clixml | % { Set-Item "env:$($_.Name)" $_.Value }
}

# remember, invoke as ". rerc"
Function rerc() {
     copy $dotfiles/profile.ps1 $profile.CurrentUserAllHosts
     . $profile.CurrentUserAllHosts
}


