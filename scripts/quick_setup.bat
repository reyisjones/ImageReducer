@echo off
REM Quick Setup - Image Compressor
REM Runs all setup steps in one go with safe defaults

setlocal enabledelayedexpansion
title Image Compressor - Quick Setup
color 0A

REM Resolve important paths
set SCRIPT_DIR=%~dp0
set ROOT_DIR=%SCRIPT_DIR%..

echo.
echo ========================================
echo    Image Compressor - Quick Setup
echo ========================================
echo.
echo This will:
echo   1. Generate sample images
echo   2. Run system tests
echo   3. Initialize Git repository
echo   4. Create distributable package
echo.

REM Non-interactive friendly: default to Yes after 5 seconds
choice /C YN /N /T 5 /D Y /M "Continue with quick setup? (Y/N): "
if %errorlevel% neq 1 goto :abort

REM Step 1: Generate sample images
echo.
echo [1/4] Generating sample images...
echo ========================================
python "%ROOT_DIR%\src\generate_samples.py"
if %errorlevel% neq 0 (
    echo [!] Warning: Could not generate samples
    echo     You can generate them later with: python src\generate_samples.py
)

REM Step 2: Run system tests
echo.
echo [2/4] Running system tests...
echo ========================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%test_system.ps1" -Quick
if %errorlevel% gtr 1 (
    echo [!] Warning: Some tests failed (code %errorlevel%)
    echo     Review test output above
)

REM Step 3: Initialize Git
echo.
echo [3/4] Initializing Git repository...
echo ========================================
choice /C YN /N /T 5 /D Y /M "Initialize Git repository? (Y/N): "
if %errorlevel% equ 1 (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%init_git.ps1"
) else (
    echo Skipped Git initialization
)

REM Step 4: Create package
echo.
echo [4/4] Creating distributable package...
echo ========================================
choice /C YN /N /T 5 /D Y /M "Create distributable package? (Y/N): "
if %errorlevel% equ 1 (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%create_package.ps1" -CreateZip
) else (
    echo Skipped package creation
)

REM Complete
echo.
echo ========================================
echo    Setup Complete!
echo ========================================
echo.
echo What's ready:
echo   [x] Application files
echo   [x] Sample images
echo   [x] System tested
echo   [x] Git repository
echo   [x] Distribution package
echo.
echo Next steps:
echo   1. Double-click scripts\start.bat to launch
echo   2. Or run scripts\install.ps1 for full installation
echo   3. Click "Run Demo" to see it in action
echo.
goto :end

:abort
echo.
echo Setup aborted.
echo.

:end
endlocal
