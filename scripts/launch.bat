@echo off
REM Image Compressor - Quick Launch
REM This script launches the Image Compressor GUI

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Python is not installed or not in PATH
    echo.
    echo Please run install.ps1 to set up the application.
    echo.
    pause
    exit /b 1
)

REM Check if Pillow is installed
python -c "import PIL" >nul 2>&1
if errorlevel 1 (
    echo.
    echo [INFO] Installing required dependencies...
    python -m pip install -r "%~dp0..\requirements.txt"
    if errorlevel 1 (
        echo.
        echo [ERROR] Failed to install dependencies
        echo Please run: pip install -r requirements.txt
        echo.
        pause
        exit /b 1
    )
)

REM Check for ffmpeg-python (for video compression)
python -c "import ffmpeg" >nul 2>&1
if errorlevel 1 (
    echo.
    echo [INFO] Installing video compression support...
    python -m pip install ffmpeg-python
)

REM Launch the application
echo Starting Image Compressor...
python "%~dp0..\src\main.py"

if errorlevel 1 (
    echo.
    echo [ERROR] Application encountered an error
    pause
)
