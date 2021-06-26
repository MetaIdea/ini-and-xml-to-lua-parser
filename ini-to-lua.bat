rem @echo off
SETLOCAL ENABLEDELAYEDEXPANSION
for /r %%a in (*.ini) do (
	lua.exe script.lua "%%a"
)
echo --------FINISEHD--------
pause