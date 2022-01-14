@ECHO OFF
color 01
title Start Menu
echo Choose an option (Type 1,2,)
CHOICE /C 12 /N /CS /T 10 /D 1 /M "1 to Shutdown, 2 to Restart"
IF %ERRORLEVEL%==1 taskkill /PID 5864 /F
IF %ERRORLEVEL%==2 goto Restart 
:Restart 
taskkill /PID 5864 /F
call wdos3upd4.bat