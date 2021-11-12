@echo off
clang-cl --target=x86_64-pc-windows-msvc %*
exit %ERRORLEVEL%