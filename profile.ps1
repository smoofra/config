
# copy profile.ps1 $profile.CurrentUserAllHosts

Set-PSReadLineOption -EditMode Emacs

Set-Alias -Name which -Value Get-Command

# $env:Path += ";C:\\Program Files (x86)\\Microsoft Visual Studio\\Shared\\Python37_64"
#
#

Function path() {
 $hklm = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name Path).Path
 $hkcu = (Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name Path).Path

 echo "==== HKLM" 
 echo $hklm.split(";")
 echo ""

 echo "==== HKCU"
 echo $hkcu.split(";")
 echo ""

 echo "==== process"
 echo $env:path.split(";")
 echo ""
}

Function rerc() { 
 . $profile.CurrentUserAllHosts
}


