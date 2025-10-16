# Test Runner Script
# Runs all tests and generates coverage reports

param(
    [switch]$Unit,
    [switch]$Integration,
    [switch]$All,
    [switch]$Coverage,
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"

Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Image Compressor - Test Runner      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Check if Python is installed
try {
    $pythonVersion = & python --version 2>&1
    Write-Host "✅ Python detected: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Python not found. Please install Python first." -ForegroundColor Red
    exit 1
}

# Check if pytest is installed
Write-Host "`n📦 Checking test dependencies..." -ForegroundColor Cyan
$pytestInstalled = & python -c "import pytest; print('OK')" 2>&1

if ($pytestInstalled -ne "OK") {
    Write-Host "⚠️  pytest not installed" -ForegroundColor Yellow
    $install = Read-Host "Install test dependencies now? (Y/N)"
    
    if ($install -eq "Y" -or $install -eq "y") {
        Write-Host "`n📥 Installing test dependencies..." -ForegroundColor Cyan
        & python -m pip install -r requirements-test.txt
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "✅ Test dependencies installed" -ForegroundColor Green
    } else {
        Write-Host "❌ Tests require pytest. Install with:" -ForegroundColor Red
        Write-Host "   pip install -r requirements-test.txt" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "✅ pytest is installed" -ForegroundColor Green
}

# Determine what to run
$runAll = $All -or (-not $Unit -and -not $Integration)

Write-Host "`n🧪 Running tests..." -ForegroundColor Cyan

# Build pytest command
$pytestCmd = "python -m pytest tests/"

if ($Unit) {
    $pytestCmd += " -m unit"
    Write-Host "   Running unit tests only" -ForegroundColor Gray
}

if ($Integration) {
    $pytestCmd += " -m integration"
    Write-Host "   Running integration tests only" -ForegroundColor Gray
}

if ($Coverage) {
    $pytestCmd += " --cov=. --cov-report=html --cov-report=term"
    Write-Host "   Generating coverage report" -ForegroundColor Gray
}

if ($Verbose) {
    $pytestCmd += " -vv"
}

Write-Host "`nCommand: $pytestCmd`n" -ForegroundColor Gray
Write-Host "=" * 80 -ForegroundColor Gray

# Run tests
Invoke-Expression $pytestCmd

$testExitCode = $LASTEXITCODE

Write-Host "`n" + "=" * 80 -ForegroundColor Gray

# Summary
if ($testExitCode -eq 0) {
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║   ✅ ALL TESTS PASSED!                ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Green
} else {
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║   ❌ SOME TESTS FAILED                ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Red
}

# Show coverage report location
if ($Coverage) {
    $htmlCoverage = Join-Path $PSScriptRoot "htmlcov" "index.html"
    if (Test-Path $htmlCoverage) {
        Write-Host "📊 Coverage report generated:" -ForegroundColor Cyan
        Write-Host "   $htmlCoverage`n" -ForegroundColor Gray
        
        $openReport = Read-Host "Open coverage report in browser? (Y/N)"
        if ($openReport -eq "Y" -or $openReport -eq "y") {
            Start-Process $htmlCoverage
        }
    }
}

# Additional information
Write-Host "💡 Test Options:" -ForegroundColor Cyan
Write-Host "   .\run_tests.ps1 -Unit          # Run unit tests only" -ForegroundColor Gray
Write-Host "   .\run_tests.ps1 -Integration   # Run integration tests only" -ForegroundColor Gray
Write-Host "   .\run_tests.ps1 -Coverage      # Generate coverage report" -ForegroundColor Gray
Write-Host "   .\run_tests.ps1 -Verbose       # Verbose output" -ForegroundColor Gray
Write-Host "   .\run_tests.ps1 -All -Coverage # Run all with coverage`n" -ForegroundColor Gray

exit $testExitCode
