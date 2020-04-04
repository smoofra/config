@call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
powershell -Command "Get-ChildItem env: | Export-CliXml ~/vcvars.clixml"
