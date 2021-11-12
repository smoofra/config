REM https://docs.microsoft.com/en-us/cpp/build/building-on-the-command-line?view=msvc-170
@call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
powershell -Command "Get-ChildItem env: | Export-CliXml ~/vcvars.clixml"
