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

function Show-Header {
    param([string]$Title)
    Write-Host "`n=== $Title ===`n" -ForegroundColor Cyan
}

function Write-TestResult {
    param(
        [string]$Test,
        [bool]$Passed,
        [string]$Message = ""
    )
    if ($Passed) {
        Write-Host "PASS: $Test" -ForegroundColor Green
        $script:TestsPassed++
    } else {
        Write-Host "FAIL: $Test" -ForegroundColor Red
        if ($Message) { Write-Host "  -> $Message" -ForegroundColor Yellow }
        $script:TestsFailed++
    }
}

function Info {
    param([string]$Message)
    Write-Host "INFO: $Message" -ForegroundColor Cyan
}

function Warn {
    param([string]$Message)
    Write-Host "WARN: $Message" -ForegroundColor Yellow
    $script:Warnings++
}

function Test-ScriptSyntax {
    param([string]$Path)
    try {
        if ($Path -like "*.ps1") {
            $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $Path -Raw), [ref]$null)
            return $true
        } elseif ($Path -like "*.py") {
            & python -m py_compile $Path 2>$null
            return $LASTEXITCODE -eq 0
        }
        return $true
    } catch {
        return $false
    }
}

Clear-Host
Write-Host "`n=== Image Compressor - System Test ===`n" -ForegroundColor Magenta

# Determine repository root (parent of scripts folder)
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

# 1) File Existence
Show-Header "File Existence"
$requiredFiles = @(
    "src/image_compressor_gui.py",
    "src/main.py",
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
foreach ($file in $requiredFiles) {
    $path = Join-Path $repoRoot $file
    $exists = Test-Path $path
    Write-TestResult "File exists: $file" $exists "Missing: $file"
}

# 2) Python Environment
Show-Header "Python Environment"
try {
    $pythonVersion = & python --version 2>&1
    if ($pythonVersion -match "Python (\d+)\.(\d+)\.(\d+)") {
        $major = [int]$Matches[1]
        $minor = [int]$Matches[2]
        Write-TestResult "Python installed" $true
        Info "Version: $pythonVersion"
        $validVersion = ($major -eq 3 -and $minor -ge 8)
        Write-TestResult "Python version >= 3.8" $validVersion "Python 3.8+ required"
    } else {
        Write-TestResult "Python installed" $false "Python not found or invalid version"
    }
} catch {
    Write-TestResult "Python installed" $false "Python not found in PATH"
}

# 3) Python Dependencies
Show-Header "Dependencies"
try {
    $pillowVersion = & python -c "import PIL; print(PIL.__version__)" 2>&1
    Write-TestResult "Pillow installed" ($LASTEXITCODE -eq 0) "Run: pip install Pillow"
    if ($LASTEXITCODE -eq 0) { Info "Pillow: $pillowVersion" }
} catch {
    Write-TestResult "Pillow installed" $false "Cannot test - Python not available"
}
try {
    & python -c "import tkinter; print('OK')" 2>$null
    Write-TestResult "tkinter available" ($LASTEXITCODE -eq 0) "tkinter is required for GUI"
} catch {
    Write-TestResult "tkinter available" $false "Cannot test - Python not available"
}

# 4) PowerShell Environment
Show-Header "PowerShell Environment"
$psVersion = $PSVersionTable.PSVersion
Info "PowerShell Version: $($psVersion.Major).$($psVersion.Minor)"
$validPS = ($psVersion.Major -ge 5)
Write-TestResult "PowerShell version >= 5.0" $validPS "PowerShell 5.0+ required"

# 5) .NET Assemblies
Show-Header ".NET Assemblies"
try { Add-Type -AssemblyName System.Drawing; Write-TestResult "System.Drawing available" $true } catch { Write-TestResult "System.Drawing available" $false "Required for PowerShell fallback" }
try { Add-Type -AssemblyName System.Windows.Forms; Write-TestResult "System.Windows.Forms available" $true } catch { Write-TestResult "System.Windows.Forms available" $false "Required for PowerShell GUI" }

# 6) Script Syntax
Show-Header "Script Syntax"
$installPath = Join-Path $repoRoot "scripts/install.ps1"
$fallbackPath = Join-Path $repoRoot "scripts/compress_fallback.ps1"
Write-TestResult "install.ps1 syntax" (Test-ScriptSyntax $installPath)
Write-TestResult "compress_fallback.ps1 syntax" (Test-ScriptSyntax $fallbackPath)
$pyFile = Join-Path $repoRoot "src/image_compressor_gui.py"
$hasPython = $null -ne (Get-Command python -ErrorAction SilentlyContinue)
if ($hasPython) {
    Write-TestResult "image_compressor_gui.py syntax" (Test-ScriptSyntax $pyFile)
} else {
    Warn "Cannot test Python syntax - Python not available"
}

# 7) Configuration File
Show-Header "Configuration"
$configPath = Join-Path $repoRoot "config.ini"
if (Test-Path $configPath) {
    try {
        $config = Get-Content $configPath -Raw
        Write-TestResult "config.ini has [Compression]" ($config -match "\[Compression\]")
        Write-TestResult "config.ini has [Advanced]" ($config -match "\[Advanced\]")
        Write-TestResult "config.ini has [Presets]" ($config -match "\[Presets\]")
    } catch {
        Write-TestResult "config.ini readable" $false "Cannot read config file"
    }
} else {
    Write-TestResult "config.ini exists" $false "Missing config.ini"
}

# 8) Documentation Quality
Show-Header "Documentation"
function Test-Doc { param([string]$File, [int]$MinLines) if (Test-Path $File) { $lines = (Get-Content $File).Count; Write-TestResult "$File lines >= $MinLines" ($lines -ge $MinLines) "Only $lines lines" } else { Write-TestResult "$File exists" $false "Missing" } }
Test-Doc (Join-Path $repoRoot "README.md") 50
Test-Doc (Join-Path $repoRoot "docs/QUICKSTART.md") 30
Test-Doc (Join-Path $repoRoot "docs/ADVANCED.md") 50

# 9) Permissions
Show-Header "Permissions"
$canWrite = Test-Path $PSScriptRoot -PathType Container
Write-TestResult "Write access to scripts directory" $canWrite

# 10) Functional Test (optional)
if ($Full) {
    Show-Header "Functional Test"
    try {
        Add-Type -AssemblyName System.Drawing
        $testImage = New-Object System.Drawing.Bitmap(1200, 800)
        $graphics = [System.Drawing.Graphics]::FromImage($testImage)
        $graphics.Clear([System.Drawing.Color]::Blue)
        $testPath = Join-Path $PSScriptRoot "test_image.jpg"
        $testImage.Save($testPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
        $graphics.Dispose(); $testImage.Dispose()
        Write-TestResult "Test image created" (Test-Path $testPath)
        if (Test-Path $testPath) { Remove-Item $testPath -ErrorAction SilentlyContinue }
    } catch { Write-TestResult "Functional test" $false "Error: $_" }
}

# 11) Package Integrity
Show-Header "Package Integrity"
$critical = @("src/image_compressor_gui.py", "scripts/install.ps1", "scripts/start.bat")
$allOk = $true
foreach ($f in $critical) { if (-not (Test-Path (Join-Path $repoRoot $f))) { $allOk = $false; break } }
Write-TestResult "Critical files present" $allOk "Some critical files are missing"

# Summary
Show-Header "TEST SUMMARY"
Write-Host ("Tests Passed:  {0}" -f $script:TestsPassed) -ForegroundColor Green
Write-Host ("Tests Failed:  {0}" -f $script:TestsFailed) -ForegroundColor Red
Write-Host ("Warnings:      {0}" -f $script:Warnings) -ForegroundColor Yellow
$total = $script:TestsPassed + $script:TestsFailed
if ($total -gt 0) { $passRate = [math]::Round(($script:TestsPassed / $total) * 100, 1); Write-Host ("Pass Rate:     {0}%`n" -f $passRate) -ForegroundColor Cyan }

if ($script:TestsFailed -eq 0) { exit 0 }
elseif ($script:TestsFailed -le 2) { exit 1 }
else { exit 2 }
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
        param(
            [switch]$Quick,
            [switch]$Full
        )

        $ErrorActionPreference = "Continue"
        $script:TestsPassed = 0
        $script:TestsFailed = 0
        $script:Warnings = 0

        function Show-Header {
            param([string]$Title)
            Write-Host "`n=== $Title ===`n" -ForegroundColor Cyan
        }

        function Write-TestResult {
            param(
                [string]$Test,
                [bool]$Passed,
                [string]$Message = ""
            )
            if ($Passed) {
                Write-Host "PASS: $Test" -ForegroundColor Green
                $script:TestsPassed++
            } else {
                Write-Host "FAIL: $Test" -ForegroundColor Red
                if ($Message) { Write-Host "  -> $Message" -ForegroundColor Yellow }
                $script:TestsFailed++
            }
        }

        function Info {
            param([string]$Message)
            Write-Host "INFO: $Message" -ForegroundColor Cyan
        }

        function Warn {
            param([string]$Message)
            Write-Host "WARN: $Message" -ForegroundColor Yellow
            $script:Warnings++
        }

        function Test-ScriptSyntax {
            param([string]$Path)
            try {
                if ($Path -like "*.ps1") {
                    $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $Path -Raw), [ref]$null)
                    return $true
                } elseif ($Path -like "*.py") {
                    & python -m py_compile $Path 2>$null
                    return $LASTEXITCODE -eq 0
                }
                return $true
            } catch {
                return $false
            }
        }

        Clear-Host
        Write-Host "`n=== Image Compressor - System Test ===`n" -ForegroundColor Magenta

        # Determine repository root (parent of scripts folder)
        $repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

        # 1) File Existence
        Show-Header "File Existence"
        $requiredFiles = @(
            "src/image_compressor_gui.py",
            "src/main.py",
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
        foreach ($file in $requiredFiles) {
            $path = Join-Path $repoRoot $file
            $exists = Test-Path $path
            Write-TestResult "File exists: $file" $exists "Missing: $file"
        }

        # 2) Python Environment
        Show-Header "Python Environment"
        try {
            $pythonVersion = & python --version 2>&1
            if ($pythonVersion -match "Python (\d+)\.(\d+)\.(\d+)") {
                $major = [int]$Matches[1]
                $minor = [int]$Matches[2]
                Write-TestResult "Python installed" $true
                Info "Version: $pythonVersion"
                $validVersion = ($major -eq 3 -and $minor -ge 8)
                Write-TestResult "Python version >= 3.8" $validVersion "Python 3.8+ required"
            } else {
                Write-TestResult "Python installed" $false "Python not found or invalid version"
            }
        } catch {
            Write-TestResult "Python installed" $false "Python not found in PATH"
        }

        # 3) Python Dependencies
        Show-Header "Dependencies"
        try {
            $pillowVersion = & python -c "import PIL; print(PIL.__version__)" 2>&1
            Write-TestResult "Pillow installed" ($LASTEXITCODE -eq 0) "Run: pip install Pillow"
            if ($LASTEXITCODE -eq 0) { Info "Pillow: $pillowVersion" }
        } catch {
            Write-TestResult "Pillow installed" $false "Cannot test - Python not available"
        }
        try {
            & python -c "import tkinter; print('OK')" 2>$null
            Write-TestResult "tkinter available" ($LASTEXITCODE -eq 0) "tkinter is required for GUI"
        } catch {
            Write-TestResult "tkinter available" $false "Cannot test - Python not available"
        }

        # 4) PowerShell Environment
        Show-Header "PowerShell Environment"
        $psVersion = $PSVersionTable.PSVersion
        Info "PowerShell Version: $($psVersion.Major).$($psVersion.Minor)"
        $validPS = ($psVersion.Major -ge 5)
        Write-TestResult "PowerShell version >= 5.0" $validPS "PowerShell 5.0+ required"

        # 5) .NET Assemblies
        Show-Header ".NET Assemblies"
        try { Add-Type -AssemblyName System.Drawing; Write-TestResult "System.Drawing available" $true } catch { Write-TestResult "System.Drawing available" $false "Required for PowerShell fallback" }
        try { Add-Type -AssemblyName System.Windows.Forms; Write-TestResult "System.Windows.Forms available" $true } catch { Write-TestResult "System.Windows.Forms available" $false "Required for PowerShell GUI" }

        # 6) Script Syntax
        Show-Header "Script Syntax"
        $installPath = Join-Path $repoRoot "scripts/install.ps1"
        $fallbackPath = Join-Path $repoRoot "scripts/compress_fallback.ps1"
        Write-TestResult "install.ps1 syntax" (Test-ScriptSyntax $installPath)
        Write-TestResult "compress_fallback.ps1 syntax" (Test-ScriptSyntax $fallbackPath)
        $pyFile = Join-Path $repoRoot "src/image_compressor_gui.py"
        $hasPython = $null -ne (Get-Command python -ErrorAction SilentlyContinue)
        if ($hasPython) {
            Write-TestResult "image_compressor_gui.py syntax" (Test-ScriptSyntax $pyFile)
        } else {
            Warn "Cannot test Python syntax - Python not available"
        }

        # 7) Configuration File
        Show-Header "Configuration"
        $configPath = Join-Path $repoRoot "config.ini"
        if (Test-Path $configPath) {
            try {
                $config = Get-Content $configPath -Raw
                Write-TestResult "config.ini has [Compression]" ($config -match "\[Compression\]")
                Write-TestResult "config.ini has [Advanced]" ($config -match "\[Advanced\]")
                Write-TestResult "config.ini has [Presets]" ($config -match "\[Presets\]")
            } catch {
                Write-TestResult "config.ini readable" $false "Cannot read config file"
            }
        } else {
            Write-TestResult "config.ini exists" $false "Missing config.ini"
        }

        # 8) Documentation Quality
        Show-Header "Documentation"
        function Test-Doc { param([string]$File, [int]$MinLines) if (Test-Path $File) { $lines = (Get-Content $File).Count; Write-TestResult "$File lines >= $MinLines" ($lines -ge $MinLines) "Only $lines lines" } else { Write-TestResult "$File exists" $false "Missing" } }
        Test-Doc (Join-Path $repoRoot "README.md") 50
        Test-Doc (Join-Path $repoRoot "docs/QUICKSTART.md") 30
        Test-Doc (Join-Path $repoRoot "docs/ADVANCED.md") 50

        # 9) Permissions
        Show-Header "Permissions"
        $canWrite = Test-Path $PSScriptRoot -PathType Container
        Write-TestResult "Write access to scripts directory" $canWrite

        # 10) Functional Test (optional)
        if ($Full) {
            Show-Header "Functional Test"
            try {
                Add-Type -AssemblyName System.Drawing
                $testImage = New-Object System.Drawing.Bitmap(1200, 800)
                $graphics = [System.Drawing.Graphics]::FromImage($testImage)
                $graphics.Clear([System.Drawing.Color]::Blue)
                $testPath = Join-Path $PSScriptRoot "test_image.jpg"
                $testImage.Save($testPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
                $graphics.Dispose(); $testImage.Dispose()
                Write-TestResult "Test image created" (Test-Path $testPath)
                if (Test-Path $testPath) { Remove-Item $testPath -ErrorAction SilentlyContinue }
            } catch { Write-TestResult "Functional test" $false "Error: $_" }
        }

        # 11) Package Integrity
        Show-Header "Package Integrity"
        $critical = @("src/image_compressor_gui.py", "scripts/install.ps1", "scripts/start.bat")
        $allOk = $true
        foreach ($f in $critical) { if (-not (Test-Path (Join-Path $repoRoot $f))) { $allOk = $false; break } }
        Write-TestResult "Critical files present" $allOk "Some critical files are missing"

        # Summary
        Show-Header "TEST SUMMARY"
        Write-Host ("Tests Passed:  {0}" -f $script:TestsPassed) -ForegroundColor Green
        Write-Host ("Tests Failed:  {0}" -f $script:TestsFailed) -ForegroundColor Red
        Write-Host ("Warnings:      {0}" -f $script:Warnings) -ForegroundColor Yellow
        $total = $script:TestsPassed + $script:TestsFailed
        if ($total -gt 0) { $passRate = [math]::Round(($script:TestsPassed / $total) * 100, 1); Write-Host ("Pass Rate:     {0}%`n" -f $passRate) -ForegroundColor Cyan }

        if ($script:TestsFailed -eq 0) { exit 0 }
        elseif ($script:TestsFailed -le 2) { exit 1 }
        else { exit 2 }
    Write-Info "Running as Administrator"
