@echo off
REM Image Compressor - Smart Launcher
REM Automatically detects Python or falls back to PowerShell

title Image Compressor
color 0B

echo.
echo ========================================
echo    Image Compressor - Smart Launcher
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [*] Python detected - Launching full application...
    echo.
    
    REM Check if Pillow is installed
    python -c "import PIL" >nul 2>&1
    if %errorlevel% neq 0 (
        echo [!] Installing required dependency: Pillow
        echo     This will only happen once...
        echo.
        python -m pip install Pillow --quiet
    )
    
    REM Launch Python GUI
    python "%~dp0image_compressor_gui.py"
    goto :end
)

REM Python not found - offer options
echo [!] Python not detected on this system
echo.
echo You have three options:
echo.
echo   1. Install Python and dependencies (Recommended)
echo      - Full features, faster processing
echo      - Creates desktop shortcut
echo.
echo   2. Use PowerShell mode (Limited features)
echo      - Works without Python
echo      - Slower, basic functionality
echo.
echo   3. Exit and install manually
echo.

choice /C 123 /N /M "Select option (1, 2, or 3): "

if %errorlevel% equ 1 (
    echo.
    echo [*] Launching installer...
    powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1"
    goto :end
)

if %errorlevel% equ 2 (
    echo.
    echo [*] Launching PowerShell mode...
    powershell -ExecutionPolicy Bypass -File "%~dp0compress_fallback.ps1"
    goto :end
)

if %errorlevel% equ 3 (
    echo.
    echo Visit https://www.python.org/downloads/ to install Python
    echo Then run this launcher again.
    goto :end
)

:end
echo.
if %errorlevel% neq 0 (
    echo [!] An error occurred
    pause
)
