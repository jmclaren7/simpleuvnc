@ECHO OFF
:BEGIN
CLS
cd /d %0\..

set EXECUTABLE=winvnc_autoit.exe
set HOSTA=192.168.0.1:5500

set OP1=-run
set OP2=-connect %HOSTA%
set OP3=-id:1234 -connect %HOSTA% -run
set OP4=-autoreconnect -connect %HOSTA% -run
set OP5=-sc -autoreconnect -connect %HOSTA% -run
set OP6=-kill
set OP7=-install
set OP8=-uninstall


ECHO Please Select An Option
ECHO  1. %OP1%
ECHO  2. %OP2%
ECHO  3. %OP3%
ECHO  4. %OP4%
ECHO  5. %OP5%
ECHO  6. %OP6%
ECHO  7. %OP7%
ECHO  8. %OP8%
ECHO  9. Exit
set /p userinp=Choose A Number (1-9):
set userinp=%userinp:~0,1%

IF "%userinp%" =="8" GOTO EIGHT
IF "%userinp%" =="7" GOTO SEVEN
IF "%userinp%" =="6" GOTO SIX
IF "%userinp%" =="5" GOTO FIVE
IF "%userinp%" =="4" GOTO FOUR
IF "%userinp%" =="3" GOTO THREE
IF "%userinp%" =="2" GOTO TWO
IF "%userinp%" =="1" GOTO ONE
IF "%userinp%" =="9" GOTO END
echo invalid choice
goto start

:ONE
Start %EXECUTABLE% %OP1%
GOTO BEGIN

:TWO
Start %EXECUTABLE% %OP2%
GOTO BEGIN

:THREE
Start %EXECUTABLE% %OP3%
GOTO BEGIN

:FOUR
Start %EXECUTABLE% %OP4%
GOTO BEGIN

:FIVE
Start %EXECUTABLE% %OP5%
GOTO BEGIN

:SIX
Start %EXECUTABLE% %OP6%
GOTO BEGIN

:SEVEN
Start %EXECUTABLE% %OP7%
GOTO BEGIN

:EIGHT
Start %EXECUTABLE% %OP8%
GOTO BEGIN

:END
Start %EXECUTABLE% %OP6%
Exit
