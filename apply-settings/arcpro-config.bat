@echo off
setlocal enabledelayedexpansion

REM Set log file path
set LOGFILE=C:\AppStreamScripts\logging\pro-config.log

REM Function to log messages
:log
echo %date% %time% - %~1 >> %LOGFILE%
echo %~1
exit /b

REM calls a shortcut to this batch file that has admin privs using a param "elevated" to prevent recursion
if "%~1" == "" (
    call :log "Running pro config script via admin shortcut"
    start "" "C:\AppStreamScripts\apply-settings\arcpro-config.bat-asadmin.lnk" "elevated"
    GOTO :EOF
)

REM Create the ArcGIS-projects directory
set PROJECTS_DIR=%USERPROFILE%\My Files\Home Folder
if not exist "%PROJECTS_DIR%" (
    mkdir "%PROJECTS_DIR%"
    call :log "Created directory: %PROJECTS_DIR%"
) else (
    call :log "Directory already exists: %PROJECTS_DIR%"
)

REM create a directory where pro settings are stored
set SETTINGS_DIR=C:\AppStreamScripts\pro-config
if not exist "%SETTINGS_DIR%" (
    mkdir "%SETTINGS_DIR%"
    call :log "Created directory: %SETTINGS_DIR%"
) else (
    call :log "Directory already exists: %SETTINGS_DIR%"
)

REM Set the path for the Pro.settingsConfig file
set SETTINGS_FILE=%SETTINGS_DIR%\Pro.settingsConfig

REM Create the Pro.settingsConfig file with the specified content
(
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<ArcGISProSettings xmlns="http://schemas.esri.com/ProSettings"
echo         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
echo         xsi:schemaLocation="http://schemas.esri.com/ProSettings %SETTINGS_DIR%\ProSettings.xsd"^>
echo.
echo   ^<Application^>
echo     ^<UseDarkTheme isLocked="false"^>false^</UseDarkTheme^>
echo   ^</Application^>
echo.
echo   ^<Projects^>
echo     ^<LocalProject^>
echo       ^<CustomDefaultLocation isLocked="false"^>%PROJECTS_DIR%^</CustomDefaultLocation^>
echo       ^<CreateProjectInNewFolder isLocked="false"^>true^</CreateProjectInNewFolder^>
echo     ^</LocalProject^>
echo   ^</Projects^>
echo.
echo   ^<Versioning^>   
echo   ^</Versioning^>
echo.
echo   ^<MapAndScene^>
echo   ^</MapAndScene^>
echo.
echo   ^<Catalog^>
echo   ^</Catalog^>
echo.
echo   ^<Navigation^>
echo   ^</Navigation^>
echo.
echo   ^<Selection^>
echo   ^</Selection^> 
echo.
echo   ^<Editing^>
echo   ^</Editing^>
echo.
echo   ^<Geoprocessing^>
echo   ^</Geoprocessing^>
echo.
echo   ^<Display^>
echo   ^</Display^>
echo.
echo   ^<TextAndGraphics^>
echo   ^</TextAndGraphics^>
echo.
echo   ^<ColorManagement^>
echo   ^</ColorManagement^>
echo.
echo   ^<Table^>
echo   ^</Table^> 
echo.
echo   ^<Report^>
echo   ^</Report^> 
echo.
echo   ^<Layout^>
echo   ^</Layout^>
echo.
echo   ^<ShareDownload^>
echo   ^</ShareDownload^> 
echo.
echo   ^<Authentication^>
echo     ^<!-- ^<AuthConnection isLocked="true"^>
echo       ^<Name^>Connection1Name^</Name^>
echo       ^<Type^>MicrosoftEntraID^</Type^>
echo       ^<Environment^>AzureGlobal^</Environment^>
echo       ^<TenantID^>example.domain.com^</TenantID^>
echo       ^<ClientID^>123456789^</ClientID^>
echo     ^</AuthConnection^>   --^>
echo   ^</Authentication^> 
echo.
echo   ^<GeodatabaseReplication^>
echo   ^</GeodatabaseReplication^> 
echo.
echo ^</ArcGISProSettings^>
) > "%SETTINGS_FILE%"

call :log "Settings file created: %SETTINGS_FILE%"

REM Create the registry entry for AdminSettingsPath
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\ESRI\ArcGISPro\Settings" /v AdminSettingsPath /t REG_SZ /d "%SETTINGS_DIR%" /f
if %ERRORLEVEL% equ 0 (
    call :log "Registry entry created: HKEY_LOCAL_MACHINE\SOFTWARE\ESRI\ArcGISPro\Settings\AdminSettingsPath"
) else (
    call :log "Error: Failed to create registry entry"
)

call :log "Script execution completed"

endlocal