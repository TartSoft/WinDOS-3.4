@ECHO OFF
cls
color 0a
set name=United
title %name% - Win/DOS Notepad
:options
cls
echo ________________________________________
echo.
echo             Win/DOS Notepad
echo ________________________________________
echo - %name%
echo.
echo Press 0 to edit a document that already exists.
echo Press 1 to edit the name of your document.
echo Press 2 to edit the contents of your document.
echo Press 3 for help.
echo Press 4 to exit.

set /p you=">"
if %you%==1 goto 1
if %you%==2 goto 2
if %you%==3 goto help
if %you%==4 goto 4
if %you%==0 goto 0

cls
echo *********************************
echo Sorry, invalid number!
echo *********************************
ping localhost -n 2 >nul
goto options

:1
cls
echo ________________________________________
echo.
echo             Win/DOS Notepad
echo ________________________________________
echo - %name%
echo. 
echo Name Your Document .. eg. 'anyname.txt' or 'anyname.bat'
set /p name=">"
title %name% - Win/DOS Notepad

goto options

:2
cls
echo ________________________________________
echo.
echo             Win/DOS Notepad
echo ________________________________________
echo - %name%
echo. 
echo To add another line to your text press enter .. To stop editing press the big 
echo red X in the corner of this screen.
echo.
echo Cannot use symbols:"   > < |   " If you use any of them 3 symbols it closes!
echo.
set /p content=">"
echo %content%>>%name%
cls
echo Save Successful!
ping localhost -n 2 >nul
goto 2

:help
cls
echo ________________________________________
echo.
echo             Win/DOS Notepad
echo ________________________________________
echo - %name%
echo. 
echo.
pause
goto options

:4
cls
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo __Win/DOS Notepad_________________________
echo.
echo             Win/DOS Notepad
echo ________________________________________
ping localhost -n 5 >nul
exit

:0
cls
echo ________________________________________
echo.
echo             Win/DOS Notepad
echo ________________________________________
echo - %name%
echo. 
echo Type in the name eg. 'anyname.txt' or 'anyname.bat'
echo The file has to be in the same directory as the Win/DOS Notepad Folder!
set /p edit=">"
edit %edit%
goto options