@echo off
color 01
title WinDOS 3.4 Updater
echo Checking Manufacter's version's signature...
IF EXIST "YourDisk\Path\version4.signature". msg * You are up-to-date!. ELSE goto DownUpdate.
:DownUpdate
cls
set /p Location=Type where you want the WinDOS folder to placed eg. [Drive:][path]
echo Downloading update...
powershell -Command "Invoke-WebRequest https://github.com/TartSoft/WinDOS-3.4-main.zip -OutFile WinDOS-3.4-main.zip"
timeout 5 >NUL
echo.
echo Unzip files...
unzip.exe WinDOS-3.4-main.zip 
timeout 5 >NUL
echo.
echo Move files to location...
MOVE /Y Downloads/WinDOS-3.4-main %Location%
timeout 5 >NUL
echo.
echo Finish!
echo The Updater will exit in:
timeout 10
exit 
