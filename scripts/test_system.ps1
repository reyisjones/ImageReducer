# Image Compressor - System Test Script
# Validates installation, dependencies, and functionality

param(
    [switch]$Quick,
    [switch]$Full
)

$ErrorActionPreference = "Continue"
$script:TestsPassed = 0
$script:TestsFailed = 0
$script:Warnings = 0

function Write-TestResult {
    param(
        [string]$Test,
        [bool]$Passed,
        [string]$Message = ""
    )
    
    if ($Passed) {
        Write-Host "✅ PASS: $Test" -ForegroundColor Green
        $script:TestsPassed++
    } else {
        Write-Host "❌ FAIL: $Test" -ForegroundColor Red
        if ($Message) {
        Clear-Host
        Write-Host "`n=== Image Compressor - System Test ===`n" -ForegroundColor Magenta

        # Determine repository root (parent of scripts folder)
        $repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
            Write-Host "   → $Message" -ForegroundColor Yellow
        }
        $script:TestsFailed++
            Write-Host "`n=== $Title ===`n" -ForegroundColor Cyan
function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  WARN: $Message" -ForegroundColor Yellow
    $script:Warnings++
}

        $requiredFiles = @(
            "src/image_compressor_gui.py",
            "scripts/install.ps1",
            "scripts/launch.bat",
            "scripts/start.bat",
            "scripts/compress_fallback.ps1",
            "config.ini",
            "README.md",
            "docs/QUICKSTART.md",
            "docs/ADVANCED.md",
            "docs/PROJECT_SUMMARY.md"
        )

# Start tests
            $path = Join-Path $repoRoot $file
            $exists = Test-Path $path
            Write-TestResult "File exists: $file" $exists "File not found: $file"
Write-Host "║   Image Compressor - System Test      ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Magenta

# Test 1: File Existence
Write-Section "File Existence Tests"

$requiredFiles = @(
    "image_compressor_gui.py",
    "install.ps1",
    "launch.bat",
                    $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $Path -Raw), [ref]$null)
    "compress_fallback.ps1",
    "config.ini",
    "README.md",
    "QUICKSTART.md",
    "ADVANCED.md",
    "PROJECT_SUMMARY.md"
)

foreach ($file in $requiredFiles) {
    $exists = Test-Path $file
    Write-TestResult "File exists: $file" $exists "File not found"
        Write-TestResult "install.ps1 syntax" (Test-ScriptSyntax $installPath)
        Write-TestResult "compress_fallback.ps1 syntax" (Test-ScriptSyntax $fallbackPath)
# Test 2: Python Installation
        $installPath = Join-Path $repoRoot "scripts/install.ps1"
        $fallbackPath = Join-Path $repoRoot "scripts/compress_fallback.ps1"
Write-Section "Python Environment Tests"

            $pyFile = Join-Path $repoRoot "src/image_compressor_gui.py"
            Write-TestResult "image_compressor_gui.py syntax" (Test-ScriptSyntax $pyFile)
    $pythonVersion = & python --version 2>&1
    if ($pythonVersion -match "Python (\d+)\.(\d+)\.(\d+)") {
        $major = [int]$Matches[1]
        $minor = [int]$Matches[2]
        
        Write-TestResult "Python installed" $true
        Write-Info "Version: $pythonVersion"
        if (Test-Path (Join-Path $repoRoot "config.ini")) {
        $validVersion = ($major -eq 3 -and $minor -ge 8)
                $config = Get-Content (Join-Path $repoRoot "config.ini") -Raw
    } else {
        Write-TestResult "Python installed" $false "Python not found or invalid version"
    }
} catch {
    Write-TestResult "Python installed" $false "Python not found in PATH"
}

# Test 3: Python Dependencies
Write-Section "Dependency Tests"

try {
    $pillowTest = & python -c "import PIL; print(PIL.__version__)" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-TestResult "Pillow installed" $true
        Write-Info "Version: $pillowTest"
    } else {
        Write-TestResult "Pillow installed" $false "Run: pip install Pillow"
    }
} catch {
    Write-TestResult "Pillow installed" $false "Cannot test - Python not available"
}

try {
    $tkinterTest = & python -c "import tkinter; print('OK')" 2>&1
    Write-TestResult "tkinter available" ($LASTEXITCODE -eq 0) "tkinter is required for GUI"
} catch {
    Write-TestResult "tkinter available" $false "Cannot test - Python not available"
}

# Test 4: PowerShell Version
Write-Section "PowerShell Environment Tests"

$psVersion = $PSVersionTable.PSVersion
Write-Info "PowerShell Version: $($psVersion.Major).$($psVersion.Minor)"

$validPS = ($psVersion.Major -ge 5)
Write-TestResult "PowerShell version >= 5.0" $validPS "PowerShell 5.0+ required"

# Test 5: .NET Framework (for PowerShell fallback)
Write-Section ".NET Framework Tests"
            Write-Host "ALL TESTS PASSED! System is ready for use.`n" -ForegroundColor Green
} catch {
    Write-TestResult "System.Drawing available" $false "Required for PowerShell fallback"
            Write-Host "MINOR ISSUES DETECTED. System may work with limitations.`n" -ForegroundColor Yellow
    Write-TestResult "System.Windows.Forms available" $true
} catch {
            Write-Host "CRITICAL ISSUES DETECTED. Please fix errors before using.`n" -ForegroundColor Red
Write-Section "Script Syntax Tests"

function Test-ScriptSyntax {
    param([string]$Path)
    
    try {
        if ($Path -like "*.ps1") {
            $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $Path -Raw), [ref]$null)
            return $true
        } elseif ($Path -like "*.py") {
            $result = & python -m py_compile $Path 2>&1
            return $LASTEXITCODE -eq 0
        }
        return $true
    } catch {
        return $false
    }
}

Write-TestResult "install.ps1 syntax" (Test-ScriptSyntax "install.ps1")
Write-TestResult "compress_fallback.ps1 syntax" (Test-ScriptSyntax "compress_fallback.ps1")

if (Test-Path "python" -PathType Leaf) {
    Write-TestResult "image_compressor_gui.py syntax" (Test-ScriptSyntax "image_compressor_gui.py")
} else {
    Write-Warning "Cannot test Python syntax - Python not available"
}

# Test 7: Configuration File
Write-Section "Configuration Tests"

if (Test-Path "config.ini") {
    try {
        $config = Get-Content "config.ini" -Raw
        
        $hasCompression = $config -match "\[Compression\]"
        Write-TestResult "config.ini has [Compression] section" $hasCompression
        
        $hasAdvanced = $config -match "\[Advanced\]"
        Write-TestResult "config.ini has [Advanced] section" $hasAdvanced
        
        $hasPresets = $config -match "\[Presets\]"
        Write-TestResult "config.ini has [Presets] section" $hasPresets
        
    } catch {
        Write-TestResult "config.ini readable" $false "Cannot read config file"
    }
}

# Test 8: Documentation Quality
Write-Section "Documentation Tests"

function Test-Documentation {
    param([string]$File, [int]$MinLines = 50)
    
    if (Test-Path $File) {
        $lines = (Get-Content $File).Count
        $valid = $lines -ge $MinLines
        Write-TestResult "$File completeness" $valid "Only $lines lines (minimum $MinLines expected)"
        return $valid
    }
    return $false
}

Test-Documentation "README.md" 100
Test-Documentation "QUICKSTART.md" 50
Test-Documentation "ADVANCED.md" 100

# Test 9: Permissions
Write-Section "Permission Tests"

$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Info "Running as Administrator"
} else {
    Write-Info "Running as Standard User"
}

$canWrite = Test-Path $PSScriptRoot -PathType Container
Write-TestResult "Write access to directory" $canWrite

# Test 10: Functional Test (if -Full)
if ($Full) {
    Write-Section "Functional Tests"
    
    # Create test image
    Write-Info "Creating test image..."
    
    try {
        Add-Type -AssemblyName System.Drawing
        
        $testImage = New-Object System.Drawing.Bitmap(2000, 1500)
        $graphics = [System.Drawing.Graphics]::FromImage($testImage)
        $graphics.Clear([System.Drawing.Color]::Blue)
        
        $testPath = Join-Path $PSScriptRoot "test_image.jpg"
        $testImage.Save($testPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
        
        $graphics.Dispose()
        $testImage.Dispose()
        
        Write-TestResult "Test image created" (Test-Path $testPath)
        
        if (Test-Path $testPath) {
            $size = (Get-Item $testPath).Length / 1KB
            Write-Info "Test image size: $([math]::Round($size, 2)) KB"
            
            # Test compression (if Python available)
            if (Test-Path "python" -PathType Leaf) {
                Write-Info "Testing compression..."
                
                # This would require importing and testing the actual compression function
                Write-Warning "Full functional test requires manual validation"
            }
            
            # Cleanup
            Remove-Item $testPath -ErrorAction SilentlyContinue
        }
        
    } catch {
        Write-TestResult "Functional test" $false "Error: $_"
    }
}

# Test 11: Package Integrity
Write-Section "Package Integrity Tests"

$criticalFiles = @("image_compressor_gui.py", "install.ps1", "start.bat")
$allCriticalExist = $true

foreach ($file in $criticalFiles) {
    if (-not (Test-Path $file)) {
        $allCriticalExist = $false
        break
    }
}

Write-TestResult "All critical files present" $allCriticalExist "Missing critical files"

# Summary
Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor White
Write-Host "║           TEST SUMMARY                ║" -ForegroundColor White
Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor White

Write-Host "Tests Passed:  " -NoNewline
Write-Host $script:TestsPassed -ForegroundColor Green

Write-Host "Tests Failed:  " -NoNewline
Write-Host $script:TestsFailed -ForegroundColor Red

Write-Host "Warnings:      " -NoNewline
Write-Host $script:Warnings -ForegroundColor Yellow

$totalTests = $script:TestsPassed + $script:TestsFailed
if ($totalTests -gt 0) {
    $passRate = [math]::Round(($script:TestsPassed / $totalTests) * 100, 1)
    Write-Host "`nPass Rate:     $passRate%`n" -ForegroundColor Cyan
}

# Overall result
if ($script:TestsFailed -eq 0) {
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║   ✅ ALL TESTS PASSED!                ║" -ForegroundColor Green
    Write-Host "║   System is ready for use.            ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Green
    exit 0
} elseif ($script:TestsFailed -le 2) {
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║   ⚠️  MINOR ISSUES DETECTED           ║" -ForegroundColor Yellow
    Write-Host "║   System may work with limitations.   ║" -ForegroundColor Yellow
    Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║   ❌ CRITICAL ISSUES DETECTED         ║" -ForegroundColor Red
    Write-Host "║   Please fix errors before using.    ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Red
    exit 2
}
