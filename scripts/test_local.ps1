# Local Testing Script - Non-interactive
# Quick way to test ImageReducer locally

Write-Host "`n🧪 ImageReducer Local Testing`n" -ForegroundColor Cyan

# 1. Check Python
Write-Host "1. Checking Python..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ $pythonVersion" -ForegroundColor Green
    } else {
        throw "Python not found"
    }
} catch {
    Write-Host "   ❌ Python not found. Please install Python 3.8+ from python.org" -ForegroundColor Red
    exit 1
}

# 2. Install dependencies
Write-Host "`n2. Installing dependencies..." -ForegroundColor Yellow
pip install -r requirements.txt -q
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Dependencies installed" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Some dependencies may have failed" -ForegroundColor Yellow
}

# 3. Run unit tests
Write-Host "`n3. Running unit tests..." -ForegroundColor Yellow
pip install -r requirements-test.txt -q
pytest ..\src\tests\ -v --tb=short
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ All tests passed" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Some tests failed" -ForegroundColor Yellow
}

# 4. Test GUI (quick launch)
Write-Host "`n4. Testing GUI application..." -ForegroundColor Yellow
Write-Host "   Starting GUI (will close in 3 seconds)..." -ForegroundColor Gray

$process = Start-Process -FilePath "python" -ArgumentList "..\src\image_compressor_gui.py" -PassThru
Start-Sleep -Seconds 3
if (!$process.HasExited) {
    $process.Kill()
    Write-Host "   ✅ GUI application starts successfully" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  GUI exited immediately (check for errors)" -ForegroundColor Yellow
}

# 5. Generate sample images for testing
Write-Host "`n5. Generating sample images..." -ForegroundColor Yellow
python ..\src\generate_samples.py
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Sample images generated" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Could not generate sample images" -ForegroundColor Yellow
}

Write-Host "`n🎉 Local testing complete!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "   • Run: python src\image_compressor_gui.py" -ForegroundColor Gray
Write-Host "   • Or build executable: .\scripts\build_exe.ps1" -ForegroundColor Gray
Write-Host "   • Test with images in sample_images/ folder" -ForegroundColor Gray
Write-Host ""