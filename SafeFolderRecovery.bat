@echo off
setlocal EnableDelayedExpansion

:: ------------------------------------------------------------
:: SafeFolderRecovery - Advanced Batch Tool
:: Created by Software Architect Darwin Orlando Ruiz Mateo
:: Version: 1.2.1
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

:: Parse named arguments (supports quotes and spaces)
:parse_args
if "%~1"=="" goto end_args

set "arg=%~1"

if /i "!arg:~0,9!"=="--source=" (
    set "SOURCE=!arg:~9!"
    set "SOURCE=!SOURCE:"=!""  :: remove quotes
)

if /i "!arg:~0,7!"=="--dest=" (
    set "DEST=!arg:~7!"
    set "DEST=!DEST:"=!""  :: remove quotes
)

if /i "!arg!"=="--zip=true" (
    set "ZIP=true"
)

if /i "!arg!"=="--loglevel=verbose" (
    set "VERBOSE=true"
)

shift
goto parse_args

:end_args

:: Prompt for missing required parameters
if "!SOURCE!"=="" (
    echo Enter FULL PATH of the folder you want to back up:
    set /p SOURCE=Source: 
)

if "!DEST!"=="" (
    echo Enter FULL PATH of the destination folder:
    set /p DEST=Destination: 
)

:: Prompt for optional flags if not passed
if /i "!ZIP!"=="false" (
    echo Do you want to create a ZIP archive after the backup? (yes/no)
    set /p ZIP_INPUT=ZIP: 
    if /i "!ZIP_INPUT!"=="yes" set "ZIP=true"
)

if /i "!VERBOSE!"=="false" (
    echo Do you want to enable verbose output to console? (yes/no)
    set /p VERBOSE_INPUT=VERBOSE: 
    if /i "!VERBOSE_INPUT!"=="yes" set "VERBOSE=true"
)

:: Validate source path
if not exist "!SOURCE!\" (
    echo ❌ ERROR: Source folder does not exist: !SOURCE!
    pause
    exit /b
)

:: Extract folder name from source
for %%X in ("!SOURCE!") do set "FOLDERNAME=%%~nxX"

:: Get timestamp using PowerShell
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set "DATESTAMP=%%i"
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format HH-mm-ss"') do set "TIMESTAMP=%%i"

:: Define paths
set "DESTFOLDER=!DEST!\!FOLDERNAME!"
set "LOG=!DEST!\backup_log_!DATESTAMP!_!TIMESTAMP!.txt"

:: Display summary
echo.
echo ============================================================
echo         SAFE FOLDER RECOVERY
echo         Author: Darwin Orlando Ruiz Mateo
echo         Date:   !DATESTAMP! !TIMESTAMP!
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

:: Start backup
echo Starting backup...
if /i "!VERBOSE!"=="true" (
    robocopy "!SOURCE!" "!DESTFOLDER!" /E /Z /COPY:DAT /R:1 /W:1
) else (
    robocopy "!SOURCE!" "!DESTFOLDER!" /E /Z /COPY:DAT /R:1 /W:1 >> "!LOG!" 2>&1
)

:: ✅ Clean up hidden/special attributes recursively after copy
attrib -s -h -r "!DESTFOLDER!" >nul 2>&1
for /d /r "!DESTFOLDER!" %%i in (*) do attrib -s -h -r "%%i" >nul 2>&1
del /f /q /s "!DESTFOLDER!\desktop.ini" >nul 2>&1

:: Create ZIP archive if requested
if /i "!ZIP!"=="true" (
    echo Creating ZIP archive...
    set "ZIPFILE=!DEST!\!FOLDERNAME!_backup_!DATESTAMP!_!TIMESTAMP!.zip"
    powershell -NoProfile -Command "Compress-Archive -Path '!DESTFOLDER!\*' -DestinationPath '!ZIPFILE!' -Force"
    echo ✅ ZIP archive created: !ZIPFILE!
)

:: ✅ Create README only in root of copied folder
(
    echo Folder backed up using SafeFolderRecovery by Darwin Orlando Ruiz Mateo
    echo Backup date: !DATESTAMP! !TIMESTAMP!
    echo Source: !SOURCE!
    echo Destination: !DESTFOLDER!
) > "!DESTFOLDER!\README.txt"

:: Final message
echo.
echo ✅ Backup completed successfully.
if not "!VERBOSE!"=="true" (
    echo See log file: !LOG!
)
pause
endlocal
