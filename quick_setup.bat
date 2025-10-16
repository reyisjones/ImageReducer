@echo off
REM Quick Setup - Image Compressor
REM Runs all setup steps in one go

title Image Compressor - Quick Setup
color 0A

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

choice /C YN /N /M "Continue with quick setup? (Y/N): "
if %errorlevel% neq 1 goto :abort

REM Step 1: Generate sample images
echo.
echo [1/4] Generating sample images...
echo ========================================
python generate_samples.py
if %errorlevel% neq 0 (
    echo [!] Warning: Could not generate samples
    echo     You can generate them later with: python generate_samples.py
)

REM Step 2: Run system tests
echo.
echo [2/4] Running system tests...
echo ========================================
powershell -ExecutionPolicy Bypass -File test_system.ps1
if %errorlevel% neq 0 (
    echo [!] Warning: Some tests failed
    echo     Review test output above
    pause
)

REM Step 3: Initialize Git
echo.
echo [3/4] Initializing Git repository...
echo ========================================
choice /C YN /N /M "Initialize Git repository? (Y/N): "
if %errorlevel% equ 1 (
    powershell -ExecutionPolicy Bypass -File init_git.ps1
) else (
    echo Skipped Git initialization
)

REM Step 4: Create package
echo.
echo [4/4] Creating distributable package...
echo ========================================
choice /C YN /N /M "Create distributable package? (Y/N): "
if %errorlevel% equ 1 (
    powershell -ExecutionPolicy Bypass -File create_package.ps1 -CreateZip
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
echo   1. Double-click start.bat to launch
echo   2. Or run install.ps1 for full installation
echo   3. Click "Run Demo" to see it in action
echo.
goto :end

:abort
echo.
echo Setup aborted.
echo.

:end
pause
