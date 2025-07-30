@echo off
setlocal EnableDelayedExpansion

:: ------------------------------------------------------------
:: SafeFolderRecovery - Advanced Batch Tool
:: Created by Software Architect Darwin Orlando Ruiz Mateo
:: Version: 1.0.0
:: ------------------------------------------------------------

:: Check for admin rights
fltmc >nul 2>&1
if %errorlevel% NEQ 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

:: Initialize variables
set "SOURCE="
set "DEST="
set "ZIP=false"
set "VERBOSE=false"

:: Parse named arguments
for %%A in (%*) do (
    set "arg=%%~A"
    if /i "!arg:~0,9!"=="--source=" ( set "SOURCE=!arg:~9!" )
    if /i "!arg:~0,7!"=="--dest="   ( set "DEST=!arg:~7!" )
    if /i "!arg!"=="--zip=true"     ( set "ZIP=true" )
    if /i "!arg!"=="--loglevel=verbose" ( set "VERBOSE=true" )
)

:: Prompt for source if not provided
if "!SOURCE!"=="" (
    echo Enter FULL PATH of the folder you want to back up:
    set /p SOURCE=Source: 
)

:: Prompt for destination if not provided
if "!DEST!"=="" (
    echo Enter FULL PATH of the destination folder:
    set /p DEST=Destination: 
)

:: Validate source
if not exist "!SOURCE!\" (
    echo ❌ ERROR: Source folder does not exist: !SOURCE!
    pause
    exit /b
)

:: Extract folder name from source path
for %%X in ("!SOURCE!") do set "FOLDERNAME=%%~nxX"

:: Timestamp for logs
for /f "tokens=2 delims==" %%i in ('"wmic os get LocalDateTime /value | find /i "LocalDateTime""') do set ts=%%i
set "DATESTAMP=!ts:~0,4!-!ts:~4,2!-!ts:~6,2!"
set "LOG=%DEST%\backup_log_%DATESTAMP%.txt"
set "DESTFOLDER=!DEST!\!FOLDERNAME!"

:: Display info
echo.
echo ============================================================
echo        SAFE FOLDER RECOVERY - ADVANCED VERSION
echo        Author: Darwin Orlando Ruiz Mateo
echo        Date:   %DATESTAMP%
echo ============================================================
echo Source folder:      !SOURCE!
echo Destination base:   !DEST!
echo Final folder path:  !DESTFOLDER!
echo Log file:           !LOG!
echo ZIP enabled:        !ZIP!
echo Verbose mode:       !VERBOSE!
echo ------------------------------------------------------------
echo.

:: Create destination folder if needed
mkdir "!DESTFOLDER!" 2>nul

:: Create README file
echo Folder backed up using SafeFolderRecovery by Darwin Orlando Ruiz Mateo > "!DESTFOLDER!\README.txt"
echo Backup date: %DATE% %TIME% >> "!DESTFOLDER!\README.txt"
echo Source: !SOURCE! >> "!DESTFOLDER!\README.txt"
echo Destination: !DESTFOLDER! >> "!DESTFOLDER!\README.txt"

:: Start backup with robocopy
echo Starting backup...
if /i "!VERBOSE!"=="true" (
    robocopy "!SOURCE!" "!DESTFOLDER!" /E /Z /COPYALL /R:1 /W:1 /V
) else (
    robocopy "!SOURCE!" "!DESTFOLDER!" /E /Z /COPYALL /R:1 /W:1 >> "!LOG!" 2>&1
)

:: Optional ZIP compression
if /i "!ZIP!"=="true" (
    echo Creating ZIP archive...
    set "ZIPFILE=!DEST!\!FOLDERNAME!_backup_!DATESTAMP!.zip"
    powershell -Command "Compress-Archive -Path '!DESTFOLDER!\*' -DestinationPath '!ZIPFILE!' -Force"
    echo ✅ ZIP archive created: !ZIPFILE!
)

:: Done
echo.
echo ✅ Backup completed successfully.
if not "!VERBOSE!"=="true" (
    echo See log file: !LOG!
)
pause
endlocal
