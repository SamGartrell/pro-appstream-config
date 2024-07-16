@REM @echo off
setlocal enabledelayedexpansion
REM ref: https://docs.aws.amazon.com/appstream2/latest/developerguide/use-session-scripts.html#use-storage-connectors-with-session-scripts

REM set storage connector ref (HomeFolder, OneDrive, or GoogleDrive)
set STG_CONN=HomeFolder

REM Set log file path
set LOGFILE=C:\AppStreamScripts\logging\storage-mount.log

REM Function to log messages
:log
echo %date% %time% - %~1 >> %LOGFILE%
echo %~1
exit /b

REM function to check if storage connector has mounted
:check_mount
for /f "tokens=2*" %%A in ('reg query "HKLM\SOFTWARE\Amazon\AppStream\Storage\%USERNAME%\%STG_CONN%" /v "MountStatus" 2^>nul') do set "status=%%B"

if "%status%"=="2" (
    call :log "%STG_CONN% mounted successfully."
    goto run_script
) else if "%status%"=="0" (
    call :log "%STG_CONN% not enabled for %USERPROFILE%"
) else if "%status%"=="3" (
    call :log "%STG_CONN% mounting failed"
) else if "%status%"=="4" (
    call :log "%STG_CONN% is enabled, but not mounted yet"
) else (
    call :log "Waiting for home folder to mount. Current status: %status%"
    timeout /t 5
    goto check_mount
)

:run_script
call :log "Running main script..."
REM call the workdir config script (which will run itself as admin using the extension)
call "C:\AppStreamScripts\apply-settings\arcpro-config.bat"
if %ERRORLEVEL% neq 0 call :log "Error: Main script execution failed with error code %ERRORLEVEL%"

endlocal