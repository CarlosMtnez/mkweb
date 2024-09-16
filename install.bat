@echo off
setlocal

REM Get the current directory path
set "currentDir=%cd%"

REM Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -ArgumentList '%currentDir%' -Verb runAs"
    exit /b
)

REM Check if the current directory was passed as an argument (when running as admin)
if not "%1"=="" (
    cd /d "%1"
    set "currentDir=%1"
)

REM Inform the user about what the script will do
echo This script will add the current directory to the system PATH so that you can run this script from any location.

REM Retrieve the current system PATH
for /f "tokens=2*" %%A in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH') do set currentPath=%%B

REM Ask the user for confirmation
set "choice=y"
set /p "choice=Do you want to add the directory %currentDir% to the system PATH? (Y/n): "

REM Accept (y) or Deny (n)
if /i "%choice%"=="" set "choice=y"

REM Check the response, accept Y, y, Yes, yes, or default to Y
if /i "%choice%"=="y" (
    goto AddToPath
) else if /i "%choice%"=="yes" (
    goto AddToPath
) else if /i "%choice%"=="n" (
    echo Operation cancelled.
    exit /b 0
) else if /i "%choice%"=="no" (
    echo Operation cancelled.
    exit /b 0
) else (
    echo Invalid response. Operation cancelled.
    exit /b 0
)

:AddToPath
REM Check if the current directory is already in the PATH
echo %currentPath% | findstr /i "%currentDir%" >nul
if %errorlevel% EQU 0 (
    echo The directory "%currentDir%" is already in the system PATH.
    exit /b 0
)

REM Add the current directory to the system PATH using reg add
echo Adding "%currentDir%" to the system PATH...
set "newPath=%currentPath%;%currentDir%"
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH /t REG_EXPAND_SZ /d "%newPath%" /f

if %errorlevel% EQU 0 (
    echo Successfully added "%currentDir%" to the system PATH.
    
    REM Update PATH for the current session
    setx PATH "%newPath%"
    
    if %errorlevel% EQU 0 (
        echo Successfully updated PATH for the current session.
    ) else (
        echo Failed to update PATH for the current session.
    )
) else (
    echo Failed to add the directory to the system PATH.
)

pause
