# to remap caps lock to ctrl https://docs.microsoft.com/en-us/sysinternals/downloads/ctrl2cap
.\ctrl2cap.exe /install


# https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
# Confirm the Firewall rule is configured. It should be created automatically by setup. 
Get-NetFirewallRule -Name *ssh*
# There should be a firewall rule named "OpenSSH-Server-In-TCP", which should be enabled 
Install-Module -Force OpenSSHUtils -Scope AllUsers
Repair-AuthorizedKeyPermission authorized_keys
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force

# https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_overview

# Save all the process' environment variables in CLIXML format.
Get-ChildItem env: | Export-CliXml ./env-vars.clixml
# Restore the previously saved env. variables.
Import-CliXml ./env-vars.clixml | % { Set-Item "env:$($_.Name)" $_.Value }


# https://github.com/PowerShell/PSReadLine
Import-Module PSReadLine
Set-PSReadLineOption -EditMode Emacs


iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Set-ExecutionPolicy RemoteSigned


cat $profile.CurrentUserAllHosts
$env:Path += ";C:\Program Files (x86)\Vim\vim81"                                                                                                                                  

cat \ProgramData\ssh\sshd_config
SyslogFacility LOCAL0
LogLevel  DEBUG

RefreshEnv.cmd
# doesn't seem to actually work
[System.Environment]::GetEnvironmentVariable("Path","Machine")
[System.Environment]::GetEnvironmentVariable("Path","User")
[System.Environment]::SetEnvironmentVariable("Path",value, "Machine")

$n = [Environment]::GetEnvironmentVariable("Path") + ";C:\Program Files\CMake\bin\"                                                                          
[Environment]::SetEnvironmentVariable("Path", $n)                                                                                                            

cmake -G Ninja `
        "-DPYTHON_HOME=C:\Program Files (x86)\Microsoft Visual Studio\Shared\Python37_64" `
        "-DLLVM_ENABLE_PROJECTS=clang;lldb;libcxx;libcxxabi" `
        "-DSWIG_EXECUTABLE=C:\Program Files (x86)\swigwin-3.0.12\swig.exe" `
        "C:\Users\temp\llvm-project\llvm"

cd 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\' 
cmd
vcvars64.bat
powershell
Get-ChildItem env: | Export-CliXml ~/vcvars.clixml
Import-CliXml ~/vcvars.clixml | % { Set-Item "env:$($_.Name)" $_.Value }



New-Item -ItemType SymbolicLink -Path "Link" -Tarf "Target"

choco install cmder 


###### new host setup
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'


###### winrm fuckery
Set-Item wsman:\localhost\Client\TrustedHosts -value "*"
Enable-PSRemoting -Force
winrm quickconfig
Set-NetConnectionProfile -NetworkCategory Private
winrm get winrm/config/service
Enter-PSSession -ComputerName win7.foo.com  -Credential user

$s = New-PSSession -ComputerName win7.foo.com -Credential user
Enter-PSSession -Session $s
Exit-PSSession


 New-PSDrive -PSProvider FileSystem  -Root \\win7.foo.com\c -Credential user


Copy-Item .\local\file  -ToSession $s -Destination "c:\file"
New-PSDrive -Credential Administrator -PSProvider FileSystem -Root \\host\c  -Name x


Invoke-Command -Session $s -ScriptBlock { ls }