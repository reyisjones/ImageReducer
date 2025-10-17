# Build Executable Script for Image Compressor
# Uses PyInstaller to create standalone executable

param(
    [switch]$Clean,
    [switch]$Debug,
    [switch]$Test
)

Write-Host "`n🔨 Image Compressor - Build Executable`n" -ForegroundColor Cyan

# Import version
$versionContent = Get-Content "..\src\version.py" -Raw
if ($versionContent -match '__version__\s*=\s*"([^"]+)"') {
    $version = $matches[1]
    Write-Host "📦 Building version: $version" -ForegroundColor Green
} else {
    $version = "1.0.0"
    Write-Host "⚠️  Could not detect version, using default: $version" -ForegroundColor Yellow
}

# Clean previous builds
if ($Clean) {
    Write-Host "`n🧹 Cleaning previous builds..." -ForegroundColor Yellow
    if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
    if (Test-Path "dist") { Remove-Item -Recurse -Force "dist" }
    if (Test-Path "*.spec") { Remove-Item -Force "*.spec" }
    Write-Host "   ✓ Cleaned" -ForegroundColor Gray
}

# Check Python environment
Write-Host "`n🐍 Checking Python environment..." -ForegroundColor Cyan
$pythonVersion = python --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Python not found! Please install Python 3.8+" -ForegroundColor Red
    exit 1
}
Write-Host "   ✓ $pythonVersion" -ForegroundColor Gray

# Check if PyInstaller is installed
Write-Host "`n📦 Checking PyInstaller..." -ForegroundColor Cyan
$pyinstallerCheck = python -c "import PyInstaller" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "   ⚠️  PyInstaller not found, installing..." -ForegroundColor Yellow
    python -m pip install pyinstaller
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install PyInstaller" -ForegroundColor Red
        exit 1
    }
}
$pyinstallerVersion = python -c "import PyInstaller; print(PyInstaller.__version__)" 2>&1
Write-Host "   ✓ PyInstaller $pyinstallerVersion" -ForegroundColor Gray

# Check dependencies
Write-Host "`n📚 Checking dependencies..." -ForegroundColor Cyan
$pillowCheck = python -c "import PIL; print(PIL.__version__)" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "   ⚠️  Pillow not found, installing..." -ForegroundColor Yellow
    python -m pip install Pillow
}
Write-Host "   ✓ All dependencies installed" -ForegroundColor Gray

# Run tests before building (optional)
if ($Test) {
    Write-Host "`n🧪 Running tests..." -ForegroundColor Cyan
    if (Test-Path "run_tests.ps1") {
        .\run_tests.ps1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Tests failed! Build aborted." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "   ⚠️  Test script not found, skipping..." -ForegroundColor Yellow
    }
}

# Build executable
Write-Host "`n🔨 Building executable..." -ForegroundColor Cyan

$buildArgs = @(
    "--name=ImageCompressor",
    "--onefile",
    "--windowed",
    "--clean",
    "..\src\image_compressor_gui.py"
)

# Add debug console if requested
if ($Debug) {
    Write-Host "   🐛 Debug mode: Console window enabled" -ForegroundColor Yellow
    $buildArgs = $buildArgs | Where-Object { $_ -ne "--windowed" }
    $buildArgs += "--console"
}

# Add hidden imports
$buildArgs += "--hidden-import=PIL._tkinter_finder"
$buildArgs += "--hidden-import=PIL.Image"
$buildArgs += "--hidden-import=PIL.ImageTk"

# Add data files
$buildArgs += "--add-data=..\config.ini;."
$buildArgs += "--add-data=..\LICENSE;."
$buildArgs += "--add-data=..\README.md;."

# Add icon if available
if (Test-Path "..\assets\icon.ico") {
    $buildArgs += "--icon=..\assets\icon.ico"
}

Write-Host "   Building with arguments:" -ForegroundColor Gray
$buildArgs | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }

# Execute PyInstaller
& python -m PyInstaller @buildArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Build failed!" -ForegroundColor Red
    exit 1
}

# Check output
Write-Host "`n✅ Build completed successfully!`n" -ForegroundColor Green

if (Test-Path "dist\ImageCompressor.exe") {
    $exeSize = (Get-Item "dist\ImageCompressor.exe").Length / 1MB
    Write-Host "📊 Build Information:" -ForegroundColor Cyan
    Write-Host "   • Executable: dist\ImageCompressor.exe" -ForegroundColor Gray
    Write-Host "   • Size: $([math]::Round($exeSize, 2)) MB" -ForegroundColor Gray
    Write-Host "   • Version: $version" -ForegroundColor Gray
    
    # Test the executable (quick smoke test)
    Write-Host "`n🧪 Quick smoke test..." -ForegroundColor Cyan
    $testProcess = Start-Process -FilePath "dist\ImageCompressor.exe" -PassThru -WindowStyle Hidden
    Start-Sleep -Seconds 2
    
    if (!$testProcess.HasExited) {
        $testProcess.Kill()
        Write-Host "   ✓ Executable starts successfully" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Executable exited immediately (check for errors)" -ForegroundColor Yellow
    }
    
    Write-Host "`n📦 Next Steps:" -ForegroundColor Cyan
    Write-Host "   1. Test the executable: dist\ImageCompressor.exe" -ForegroundColor Gray
    Write-Host "   2. Create installer: .\create_package.ps1 -CreateZip" -ForegroundColor Gray
    Write-Host "   3. Distribute or commit to repository" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "❌ Executable not found in dist folder!" -ForegroundColor Red
    exit 1
}
