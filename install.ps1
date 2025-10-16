# Image Compressor Installer
# This script sets up the Image Compressor application on your system

param(
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

# Configuration
$AppName = "Image Compressor"
$AppDir = "$env:LOCALAPPDATA\ImageCompressor"
$ScriptPath = Join-Path $AppDir "image_compressor_gui.py"
$LauncherPath = Join-Path $AppDir "launch.bat"
$DesktopShortcut = Join-Path ([Environment]::GetFolderPath("Desktop")) "$AppName.lnk"
$StartMenuFolder = Join-Path ([Environment]::GetFolderPath("StartMenu")) "Programs\Image Compressor"
$StartMenuShortcut = Join-Path $StartMenuFolder "$AppName.lnk"

function Write-ColorMessage {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-PythonInstalled {
    try {
        $pythonVersion = & python --version 2>&1
        if ($pythonVersion -match "Python (\d+)\.(\d+)") {
            return $true
        }
        return $false
    } catch {
        return $false
    }
}

function Install-Python {
    Write-ColorMessage "`n🔍 Python not detected on this system." Yellow
    Write-ColorMessage "Python is required to run Image Compressor.`n" Yellow
    
    $response = Read-Host "Would you like to download and install Python 3.11? (Y/N)"
    
    if ($response -eq "Y" -or $response -eq "y") {
        Write-ColorMessage "`n📥 Downloading Python installer..." Cyan
        
        $pythonInstaller = Join-Path $env:TEMP "python-installer.exe"
        $pythonUrl = "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe"
        
        try {
            Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller
            
            Write-ColorMessage "🚀 Installing Python (this may take a few minutes)..." Cyan
            Write-ColorMessage "    Please select 'Add Python to PATH' during installation!" Yellow
            
            Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet", "InstallAllUsers=0", "PrependPath=1", "Include_pip=1" -Wait
            
            Remove-Item $pythonInstaller -ErrorAction SilentlyContinue
            
            Write-ColorMessage "✅ Python installed successfully!" Green
            Write-ColorMessage "`n⚠️  Please restart this installer to complete setup.`n" Yellow
            
            pause
            exit
        } catch {
            Write-ColorMessage "❌ Failed to install Python: $_" Red
            Write-ColorMessage "`nPlease download and install Python manually from:" Yellow
            Write-ColorMessage "https://www.python.org/downloads/" Cyan
            pause
            exit 1
        }
    } else {
        Write-ColorMessage "`n❌ Installation canceled. Python is required." Red
        pause
        exit 1
    }
}

function Install-Dependencies {
    Write-ColorMessage "`n📦 Installing required Python packages..." Cyan
    
    try {
        & python -m pip install --upgrade pip --quiet
        & python -m pip install Pillow --quiet
        
        Write-ColorMessage "✅ Dependencies installed successfully!" Green
    } catch {
        Write-ColorMessage "⚠️  Warning: Failed to install dependencies automatically." Yellow
        Write-ColorMessage "   You may need to run: pip install Pillow" Yellow
    }
}

function Install-Application {
    Write-ColorMessage "`n╔════════════════════════════════════════╗" Cyan
    Write-ColorMessage "║   Image Compressor - Installer        ║" Cyan
    Write-ColorMessage "╚════════════════════════════════════════╝`n" Cyan
    
    # Check Python
    if (-not (Test-PythonInstalled)) {
        Install-Python
    } else {
        Write-ColorMessage "✅ Python detected" Green
    }
    
    # Install dependencies
    Install-Dependencies
    
    # Create application directory
    Write-ColorMessage "`n📁 Creating application directory..." Cyan
    if (-not (Test-Path $AppDir)) {
        New-Item -ItemType Directory -Path $AppDir -Force | Out-Null
    }
    
    # Copy application files
    Write-ColorMessage "📋 Copying application files..." Cyan
    $sourceDir = $PSScriptRoot
    
    Copy-Item (Join-Path $sourceDir "image_compressor_gui.py") -Destination $ScriptPath -Force
    
    # Create launcher batch file
    Write-ColorMessage "🔧 Creating launcher..." Cyan
    $launcherContent = @"
@echo off
python "$ScriptPath"
if errorlevel 1 (
    echo.
    echo Error running Image Compressor.
    echo Please ensure Python is installed correctly.
    pause
)
"@
    
    Set-Content -Path $LauncherPath -Value $launcherContent
    
    # Create desktop shortcut
    Write-ColorMessage "🔗 Creating desktop shortcut..." Cyan
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($DesktopShortcut)
    $Shortcut.TargetPath = $LauncherPath
    $Shortcut.WorkingDirectory = [Environment]::GetFolderPath("MyDocuments")
    $Shortcut.Description = "Compress images to web-optimized sizes"
    $Shortcut.IconLocation = "imageres.dll,72"
    $Shortcut.Save()
    
    # Create Start Menu shortcut
    Write-ColorMessage "📍 Creating Start Menu shortcut..." Cyan
    if (-not (Test-Path $StartMenuFolder)) {
        New-Item -ItemType Directory -Path $StartMenuFolder -Force | Out-Null
    }
    
    $Shortcut = $WScriptShell.CreateShortcut($StartMenuShortcut)
    $Shortcut.TargetPath = $LauncherPath
    $Shortcut.WorkingDirectory = [Environment]::GetFolderPath("MyDocuments")
    $Shortcut.Description = "Compress images to web-optimized sizes"
    $Shortcut.IconLocation = "imageres.dll,72"
    $Shortcut.Save()
    
    # Create uninstaller
    $uninstallerPath = Join-Path $AppDir "uninstall.bat"
    $uninstallerContent = @"
@echo off
echo Uninstalling Image Compressor...
powershell -ExecutionPolicy Bypass -File "$PSCommandPath" -Uninstall
pause
"@
    Set-Content -Path $uninstallerPath -Value $uninstallerContent
    
    Write-ColorMessage "`n╔════════════════════════════════════════╗" Green
    Write-ColorMessage "║   ✅ Installation Complete!           ║" Green
    Write-ColorMessage "╚════════════════════════════════════════╝`n" Green
    
    Write-ColorMessage "📍 Application installed to:" White
    Write-ColorMessage "   $AppDir`n" Cyan
    
    Write-ColorMessage "🚀 You can now launch Image Compressor from:" White
    Write-ColorMessage "   • Desktop shortcut" Cyan
    Write-ColorMessage "   • Start Menu" Cyan
    
    Write-ColorMessage "`n💡 To uninstall, run:" White
    Write-ColorMessage "   $uninstallerPath`n" Cyan
    
    $launch = Read-Host "Would you like to launch Image Compressor now? (Y/N)"
    if ($launch -eq "Y" -or $launch -eq "y") {
        Start-Process $LauncherPath
    }
}

function Uninstall-Application {
    Write-ColorMessage "`n╔════════════════════════════════════════╗" Yellow
    Write-ColorMessage "║   Image Compressor - Uninstaller      ║" Yellow
    Write-ColorMessage "╚════════════════════════════════════════╝`n" Yellow
    
    $confirm = Read-Host "Are you sure you want to uninstall Image Compressor? (Y/N)"
    
    if ($confirm -ne "Y" -and $confirm -ne "y") {
        Write-ColorMessage "`n❌ Uninstall canceled.`n" Yellow
        return
    }
    
    Write-ColorMessage "`n🗑️  Removing application files..." Cyan
    
    # Remove shortcuts
    if (Test-Path $DesktopShortcut) {
        Remove-Item $DesktopShortcut -Force
        Write-ColorMessage "   Removed desktop shortcut" Gray
    }
    
    if (Test-Path $StartMenuFolder) {
        Remove-Item $StartMenuFolder -Recurse -Force
        Write-ColorMessage "   Removed Start Menu shortcut" Gray
    }
    
    # Remove application directory
    if (Test-Path $AppDir) {
        Remove-Item $AppDir -Recurse -Force
        Write-ColorMessage "   Removed application files" Gray
    }
    
    Write-ColorMessage "`n✅ Image Compressor has been uninstalled.`n" Green
}

# Main execution
try {
    if ($Uninstall) {
        Uninstall-Application
    } else {
        Install-Application
    }
} catch {
    Write-ColorMessage "`n❌ An error occurred: $_`n" Red
    pause
    exit 1
}

pause
