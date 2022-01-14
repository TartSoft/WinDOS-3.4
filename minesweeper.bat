cls
setlocal enabledelayedexpansion
title WinDOS Minesweeper

call :userInterface
if "!exit!"=="true" exit /b

echo.
echo Loading grid...
call :setupGrid

echo Loading display variables...
call :setupDisplayVariables

echo Laying mines...
call :setupMines

call :gameLoop
goto main
exit /b


:userInterface
::A function to provide the main menu for the player.

::Clears the screen and gives the player the options.
cls
echo 1. Play a game with begginer difficulty
echo 2. Play a game with intermediate difficulty
echo 3. Play a game with advanced difficulty
echo 4. Play a game with custom difficulty
echo 5. Exit
echo.
echo.

::Clears the menuChoice and requests the player's input.
set menuChoice=
set /p menuChoice="Enter the number of your choice - "

::The following IF statements check the player's input, setting the appropriate difficultly level and the
::right amount of space between the edge of the screen and the start of the board.

if "!menuChoice!"=="1" (
set difficulty=begginer
set displaySpacer=
exit /b
)

if "!menuChoice!"=="2" (
set difficulty=intermediate
set displaySpacer=
exit /b
)

if "!menuChoice!"=="3" (
set difficulty=advanced
set displaySpacer=
echo.
echo To view the advanced game properly the window must be resized. Right click the
echo CMD icon at the top left of the window, click properties and on the LAYOUT tab,
echo change the width to a minimum of 95.
echo Press enter once changed to refresh the display.
echo.
pause
exit /b
)

if "!menuChoice!"=="4" (
cls
call :getCustomDimensions
exit /b
)
if "!menuChoice!"=="5" (
set exit=true
exit /b
)
goto userInterface


:getCustomDimensions
::A function to recieve custom dimensions from the user and check they are within sensible limits.

set /p xDimension="Enter the width [1-30] - "
if !xDimension! gtr 30 (
echo The maximum width is 30.
goto getCustomDimensions
)
if !xDimension! lss 1 (
echo The minimum width is 1.
goto getCustomDimensions

)
echo.
set /p yDimension="Enter the height [1-30] - "

if !yDimension! gtr 30 (
echo The maximum height is 30.
goto getCustomDimensions
)
if !yDimension! lss 1 (
echo The minimum height is 1.
goto getCustomDimensions

)

::The maximum number of mines is 80% of the squares on the grid.
::The practical maximum number of mines (before causing stack overflow) is 499.
echo.
set /a maxMines= !xDimension! * !yDimension! - !xDimension! * !yDimension! / 5
if /i %maxMines% geq 500 (
set maxMines=499
)

::The practical minimum number of mines is 1. The minimum for a given board is 1/12th of the
::total number of squares on the grid. This prevents stack overflow on the largest grids.
set /a minMines= 1 + !xDimension! * !yDimension! / 12
if /i maxMines geq 500 (
set maxMines=499
)

set /p mineCount="Enter the number of mines [%minMines%-%maxMines%] - "

if !mineCount! lss %minMines% (
echo The minimum number of mines is %minMines%.
goto getCustomDimensions

)
if !mineCount! gtr %maxMines% (
echo The maximum number of mines for this board size is %maxMines%.
goto getCustomDimensions

)

::The space between the edge of the screen and the start of the board is adjusted depending on the size of the board.
::This just makes it look more central.
if !xDimension! leq 10 (
set displaySpacer=
) else (
if !xDimension! leq 17 (
set displaySpacer=
) else (
if !xDimension! leq 22 (
set displaySpacer=
) else (
set displaySpacer=
if !xDimension! gtr 24 (
echo To view large games properly the window must be resized. Right click the
echo CMD icon at the top left of the window, click properties and on the LAYOUT tab,
echo change the width. A width of 95 will encorporate all possible game sizes.
echo Press enter once changed to refresh the display.
echo.
pause
)
)
)
)

::Sets the difficulty variable.
set difficulty=custom

exit /b

:setupGrid

::Sets up the display grid to the correct dimensions, each position on the grid initally containing just a space.
::Variables in the 'D_Grid' (display grid) have the format DX_Y where X and Y are coordinates along the X and Y axes respectively.

::Sets the appropriate dimensions and number of mines to lay based on the difficulty.

if "%difficulty%"=="begginer" (
set xDimension=9
set yDimension=9
set mineCount=10
)

if "%difficulty%"=="intermediate" (
set xDimension=16
set yDimension=16
set mineCount=40
)

if "%difficulty%"=="advanced" (
set xDimension=30
set yDimension=16
set mineCount=99
)

::The number of mine 'flags' placed by the player is zero at the start of the game.
set flaggedCount=0

::Ensures the list of flagged coordinates is empty.
set flaggedCoordinateList=

::Ensures the finalOutcome variable is undefined, it is defined only when a player wins or loses.
set finalOutcome=

::Creates two grids of the appropriate dimensions. The D_grid is the grid displayed to the user, the G_grid is the grid containing all the mines and numbers.

for /l %%I in (1,1,%xDimension%) do (
for /l %%J in (1,1,%yDimension%) do (
set D%%I_%%J= 
set G%%I_%%J=0
)
)
exit /b


:setupDisplayVariables

::Creates a number of variables corresponding to the number of rows in the grid.
::Each variable contains the variable names of all the display grid locations on that row, each surround by percentage signs.
::This allows easy display of the grid, because 'CALL ECHO'ing these variables displays the value of all the display grid loactions on that row.
::Doing it this way means each line of display doesn't have to be generated every time the board is displayed.

::Sets pipe to the pipe character, this is just to draw the grid around the numbers.
set pipe=^^^|

::First section of this for command is just placing the y coordinate and a couple of spaces at the start of each display line, forming the 'y axis label'.
::If the number is single digit (i.e. less than 10) one extra space is put in so everything lines up.
::The second bit builds the rest of the line by simply adding each grid entry one by one, surrounded by pipe characters to give a grid-look.

for /l %%I in (1, 1, %yDimension%) do (
if %%I lss 10 (
set displayLine%%I=%%I  
) else (
set displayLine%%I=%%I 
)
for /l %%J in (1, 1, %xDimension%) do (
set displayLine%%I=!displayLine%%I!%%pipe%%%%D%%J_%%I%%%%pipe%%
)
)

::This for look is devoted to setting up the x axis label line.
::It starts off with an x and a couple of spaces, then just writes each number underneath the corresponding line on the grid.
::No need for the fancy delayed-expansion of the variables using %% or CALL ECHO, this line is fixed and won't change.
::Once again the number of spaces after each number is dictated by whether the number is one- or two-digit to keep it all in line.

set displayLineBottom=  x 
set rowDivider=    
for /l %%J in (1, 1, %xDimension%) do (
if %%J lss 10 (
set displayLineBottom=!displayLineBottom!%%J  
) else (
set displayLineBottom=!displayLineBottom!%%J 
)
set rowDivider=!rowDivider!-  
)
exit /b



:setupMines

::Lays the number of mines appropriate for this difficulty level.

set minesToPlant=%mineCount%
set mineCoOrdinateList=

::Calculates a random position on the G_grid (game grid, containing all the mines and numbers),
::Sets Gcurrent to the value of the G_grid at these coordinates.
::Checks a mine has not already been planted here (it will have value 'MINE' if a mine has already been planted at this location).
::If the location has already been planted, add 1 to the failedMineCount.
::If the space has not already been planted, set that G_grid value to 'MINE' and call the updateG_grid function

:layMines
set failedMineCount=0
for /l %%I in (1,1,%minesToPlant%) do (

set /a xMine= 1 + !random! %% %xDimension%
set /a yMine= 1 + !random! %% %yDimension%

call set Gcurrent=%%G!xMine!_!yMine!%%

if NOT "!Gcurrent!" == "MINE" (
set G!xMine!_!yMine!=MINE
set F!xMine!_!yMine!=*

set mineCoOrdinateList=!mineCoOrdinateList!!xMine!_!yMine!,

call :updateG_grid !xMine! !yMine!
) else (
set /a failedMineCount= !failedMineCount! + 1
)
)

::Calls layMines again if any mines failed to plant, specifying that minesToPlant is the number of failed mines.

if NOT %failedMineCount%==0 (
set minesToPlant=%failedMineCount%
goto layMines
)
exit /b



:updateG_grid

::A function to update the values of the G_grid when a mine is planted, so all the sqaures around it show the correct number.
::Each time a mine is planted, this function is called. All the sqaures adjacent to the mine, assuming they are not mines, have their G-grid value increased by 1.
::When all the mines are laid, the value of the G_grid for each square contains the number of adjacent mines, which is how minesweeper works.

::These 8 pairs x and y values correspond to the 8 ADJacent squares.

set /a adj1X=%1 + 1
set /a adj1y=%2 + 1

set /a adj2X=%1
set /a adj2y=%2 + 1

set /a adj3X=%1 - 1
set /a adj3y=%2 + 1

set /a adj4X=%1 + 1
set /a adj4y=%2 - 1

set /a adj5X=%1
set /a adj5y=%2 - 1

set /a adj6X=%1 - 1
set /a adj6y=%2 - 1

set /a adj7X=%1 + 1
set /a adj7y=%2

set /a adj8X=%1 - 1
set /a adj8y=%2

::This FOR command cycles through the eight ADJacent squares, and, if they are not mines, increases their G_grid value by 1.

for /l %%I in (1,1,8) do (
call set squareValue=%%G!adj%%IX!_!adj%%Iy!%%
if NOT "!squareValue!"=="MINE" (
set /a G!adj%%IX!_!adj%%Iy!= !squareValue! + 1
)
)
exit /b


:gameLoop
::A function to recieve user input, evaluate it, adjust the necessary grids. Repreats until game is won or lost.

::Displays the board.

call :displayBoard

::ECHOs the infoMessage. This is only defined if the user's input was invalid. Otherwise this is just an empty line.
echo.%infoMessage%
echo Flagged %flaggedCount%/%mineCount%
echo.

set infoMessage=

::Clears the input variable, then requests the user's input.
set input=
set /p input="Enter your move or type HELP for help [x y [*]] - "

::Gives help if the user typed help.

if /i "!input!"=="help" (
echo To reveal a square with coordinates x,y type: x y 
echo To flag a sqaure with coordinates x,y as a mine, type: x y *
echo To unflag a square that has already been flagged with coordinates x,y just type: x y *
echo Type EXIT to end the game immediately.
pause
goto gameLoop
)

if /i "!input!"=="exit" (
exit /b
)

::Checks the input is valid, in the format "x y".
::The FOR command splits up the user's input into three parts, the x, the y and the *. The * may or may not have been entered.
::Checks that each x and y coordinate is within the bounds of the grid size.
::Checks if the * is present. If so, calls flagSquare, else calls revealSquare.

for /f "tokens=1,2,3 delims=-, " %%I in ("!input!") do (

if NOT %%I leq %xDimension% (
set infoMessage=Input must be in the form "x y" where x is a number from 1 to %xDimension%.
goto gameLoop
)
if NOT %%I gtr 0 (
set infoMessage=Input must be in the form "x y" where x is a number from 1 to %xDimension%.
goto gameLoop
)
if NOT %%J gtr 0 (
set infoMessage=Input must be in the form "x y" where y is a number from 1 to %yDimension%.
goto gameLoop
)
if NOT %%J leq %yDimension% (
set infoMessage=Input must be in the form "x y" where y is a number from 1 to %yDimension%.
goto gameLoop
)
if NOT "%%K"=="" (
if NOT "%%K"=="*" (
set infoMessage=Input must be in the form "x y" or "x y *".
goto gameLoop
) else (
call :flagSquare %%I %%J
)
) else (
call :revealSquare %%I %%J
)
)

::If the flagging of the or the revealing of the square resulted in a win or lose, exit this function.

if defined finalOutcome (
exit /b
)

::Otherwise, loop round again for another turn.
goto gameLoop


:displayBoard
::A function to clear the screen then display the updated board. 'CALL ECHO's the variables set up in the setupDisplayVariables function.

cls
for /l %%I in (%yDimension%, -1, 1) do (
echo.%displaySpacer%%rowDivider%
call echo.%displaySpacer%!displayLine%%I!
)
echo.%displaySpacer%y
echo.%displaySpacer%%displayLineBottom%
echo.
exit /b


:revealSquare
::Recieves the arguments %1=x and %2=y
::A function to reveal a square.

::Checks if the mine is flagged as a mine, if so, does not reveal it.
::Otherwise checks if the square is a mine, if so asserts LOSE.
::Else just sets the D_grid display variable to the previously hidden G_grid value.
::If the square was a zero, calls the revealZeros function.

if NOT "!D%1_%2!"=="*" (
if "!G%1_%2!"=="MINE" (
set finalOutcome=LOSE
call :generateLoseGrid
) else (
if "!G%1_%2!"=="0" (
set adjacentZeroList=%1_%2,
call :revealZeros %1 %2
) else (
set D%1_%2=!G%1_%2!
)
)
) else (
set infoMessage=That square is flagged as a mine! To reveal it, unflag it first.
)
exit /b


:revealZeros
::A function to reveal the G_grid values of all the squares around a zero. If another zero is found, repeat this funtion for that square.

::Sets the display grid value of the zero-value square to zero.
set D%1_%2=0

::These 8 pairs x and y values correspond to the 8 ADJacent squares.

set /a adj1X=%1 + 1
set /a adj1y=%2 + 1

set /a adj2X=%1
set /a adj2y=%2 + 1

set /a adj3X=%1 - 1
set /a adj3y=%2 + 1

set /a adj4X=%1 + 1
set /a adj4y=%2 - 1

set /a adj5X=%1
set /a adj5y=%2 - 1

set /a adj6X=%1 - 1
set /a adj6y=%2 - 1

set /a adj7X=%1 + 1
set /a adj7y=%2

set /a adj8X=%1 - 1
set /a adj8y=%2


::This FOR loop retrieves the G_grid and D_grid values of each of the adjacent squares.
::If the D_grid is *, the square has been flagged by the player and is not altered
::If the G_grid is zero, that square is added to the adjacentZeroList so that this function is repeated for that square.
::Otherwise the G_grid value for the square is revealed in the D_grid.

for /l %%I in (1,1,8) do (
call set Gadj=%%G!adj%%Ix!_!adj%%Iy!%%
call set Dadj=%%D!adj%%Ix!_!adj%%Iy!%%
if NOT "!Dadj!"=="*" (
if "!Gadj!"=="0" (
if NOT "!Dadj!"=="0" (
set adjacentZeroList=!adjacentZeroList!!adj%%Ix!_!adj%%Iy!,
)
) else (
set D!adj%%Ix!_!adj%%Iy!=!Gadj!
)
)
)

::Remove the square that has just been processed from the list of squares due for processing.

set adjacentZeroList=!adjacentZeroList:%1_%2,=!

::Call the revealZeros function on the next adjacent zero in the list. If the list is empty this FOR command will do nothing.

for /f "tokens=1,2 delims=,_" %%I in ("!adjacentZeroList!") do (
call :revealZeros %%I %%J
)

exit /b


:flagSquare
::A function to flag or unflag a square.
::Recieves the arguments %1=x and %2=y

::If the square is unmarked and unrevealed, simply mark the square as a mine, increment the flaggedCount and add its coordinates
::to the flaggedCoordinateList.
::If the mine is already flagged with a *, unflag the mine and decrement the flaggedCount.
::Otherwise the square has already been revealed and cannot be flagged.

if "!D%1_%2!"==" " (
set D%1_%2=*
set /a flaggedCount+=1
set flaggedCoordinateList=!flaggedCoordinateList!%1_%2,
) else (
if "!D%1_%2!"=="*" (
set D%1_%2= 
set /a flaggedCount-=1

REM :: Remove the square being unflagged from the flaggedCoOrdinateList variable.
set flaggedCoOrdinateList=!flaggedCoOrdinateList:%1_%2,=!
) else (
set infoMessage=That square can't be flagged, it is already revealed.
)
)

::The player is notified if too many mines have been flagged.
if %flaggedCount% gtr %mineCount% (
set infoMessage=You have flagged too many mines; not all are correct. To remove a flag, type "x y *" for an already flagged square.
)

::If the flaggedCount is equal to the number of mines planted, the solution must be checked to see if it is correct.

if %flaggedCount%==%mineCount% (
call :checkSolution !flaggedCoordinateList!
)
exit /b






:checkSolution
::A function to check if all the mines flagged by the player are correct.
::This function is only called when exactly the right number of mines are flagged.
::Receives argument %* containing flaggedCoOrdinateList

::Sets the number of flags verified to be correct to 0 and calls the checkSolutionLoop, passing the flaggedCoOrdinateList (%*)
set correctFlags=0

call :checkSolutionLoop %*

::If the player has flagged all mines correctly, the number of correct flags is equal to the number of mines originally planted.
if "%correctFlags%"=="%mineCount%" (
set finalOutCome=WIN
echo Congratulations you've identified all the mines^^^!
pause
)
exit /b


:checkSolutionLoop
::A function to increment the correctFlags variable every time a flag turns out to be correct. Execution stops if an incorrect mine is found.
::Receives argument %* containing a list of flagged coordinates that haven't been checked yet.
::Only called by checkSolution.

::This FOR /F command takes the first element of the list of flagged coordinates passed as an argument
::and checks that the flagging is correct i.e. the G-grid value is MINE.
::If the flag was correct, the correctFlags variable is incremented and the loop is called again with the remaining elements of the list.
::If the flag was incorrect, the loop sets the infoMessage and exits.

for /f "tokens=1* delims=," %%I in ("%*") do (
if "!G%%I!"=="MINE" (
set /a correctFlags= !correctFlags! + 1
call :checkSolutionLoop %%J
) else (
set infoMessage=All flagged squares aren't correct! To remove a flag, type "x y *" for an already flagged square.
)
)
exit /b






:generateLoseGrid
::A function to set up the final grid shown to the player. This function is only called after the player has lost.
::The lose grid is just a moified D_grid (display grid).
::The only changes made are that unflagged mines are marked with ! and incorrectly flagged are marked as X.

::Sets excl to the exclamation mark character, for use in marking the unflaggedMines.
set excl=^^^!

call :markIncorrectFlagLoop !flaggedCoordinateList!
call :markUnflaggedMinesLoop !mineCoordinateList!
call :displayBoard

echo.
echo Sorry you lost the game!excl! The board above shows unidentified mines as !excl! and incorrectly flagged mines as X.
pause
exit /b

:markIncorrectFlagLoop
::A function to change incorrect flags with a ! correct flags are left as *.
::Argument %* contains the list of flagged coordinates.
::Only called by generateLoseGrid.

for /f "tokens=1* delims=," %%I in ("%*") do (
if NOT "!G%%I!"=="MINE" (
set D%%I=X
)
call :markIncorrectFlagLoop %%J
)
exit /b

:markUnflaggedMinesLoop
::A function to change incorrect flags with a ! correct flags are left as *.
::Argument %* contains the list of flagged coordinates
::Only called by generateLoseGrid.

for /f "tokens=1* delims=," %%I in ("%*") do (
if NOT "!D%%I!"=="*" (
set D%%I=!excl!
)
call :markUnflaggedMinesLoop %%J
)
exit /b