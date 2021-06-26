rem @echo off
SETLOCAL ENABLEDELAYEDEXPANSION
for /r %%a in (*.xml) do (
	lua.exe script.lua "%%a"
)
echo --------FINISEHD--------
pause