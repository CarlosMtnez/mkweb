@echo off
set scriptdir=%~dp0

if "%1"=="" (
    powershell -ExecutionPolicy Bypass -File "%scriptdir%mkweb.ps1"
) else (
    powershell -ExecutionPolicy Bypass -File "%scriptdir%mkweb.ps1" -projectName "%1"
)
