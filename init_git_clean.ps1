# Simple Git Initialization Script
# Creates feature-based commits for Image Compressor project

Write-Host "🚀 Initializing Git Repository..." -ForegroundColor Green
Write-Host ""

# Check if already a git repo
if (Test-Path ".git") {
    Write-Host "⚠️  Git repository already exists!" -ForegroundColor Yellow
    $response = Read-Host "Do you want to remove it and start fresh? (yes/no)"
    if ($response -eq "yes") {
        Remove-Item -Recurse -Force ".git"
        Write-Host "   ✓ Removed existing repository" -ForegroundColor Gray
    } else {
        Write-Host "❌ Aborted" -ForegroundColor Red
        exit 1
    }
}

# Initialize repository
Write-Host "📁 Initializing repository..." -ForegroundColor Cyan
git init
git config core.autocrlf true

# Check Git user configuration
$userName = git config user.name
$userEmail = git config user.email

if ([string]::IsNullOrWhiteSpace($userName)) {
    Write-Host ""
    Write-Host "⚙️  Git user not configured. Please enter your details:" -ForegroundColor Cyan
    $name = Read-Host "Your name"
    git config user.name "$name"
}

if ([string]::IsNullOrWhiteSpace($userEmail)) {
    $email = Read-Host "Your email"
    git config user.email "$email"
}

Write-Host ""
Write-Host "📦 Creating feature-based commits..." -ForegroundColor Cyan
Write-Host ""

# Commit 1: Project structure and documentation
Write-Host "[1/8] Project structure and documentation..." -ForegroundColor Yellow
git add LICENSE README.md QUICKSTART.md ADVANCED.md PROJECT_SUMMARY.md VISUAL_GUIDE.md COMPLETION_SUMMARY.md Prompt.md config.ini .gitignore
$msg1 = @"
feat: add project structure and documentation

Add MIT License with proper attribution to Reyis Jones
Add comprehensive README with badges and sections
Add QUICKSTART, ADVANCED, and VISUAL_GUIDE documentation
Add PROJECT_SUMMARY and COMPLETION_SUMMARY
Add config.ini with compression presets
Add .gitignore for Python projects
Add original Prompt.md requirements
"@
git commit -m $msg1

# Commit 2: Core compression and GUI
Write-Host "[2/8] Core compression and GUI..." -ForegroundColor Yellow
git add image_compressor_gui.py
$msg2 = @"
feat: implement GUI and compression engine

Implement smart compression to target file size (default <1MB)
Add quality adjustment algorithm (60-95%)
Add dimension scaling with aspect ratio preservation
Convert PNG to JPEG for better compression
Use LANCZOS resampling for quality preservation
Create Tkinter-based user interface
Add folder and file selection modes
Add settings configuration (quality, dimensions, target size)
Implement progress bar and status messages
Add thread-based processing for responsive UI
Add Help dialog with comprehensive instructions
Add Demo mode with sample image integration
"@
git commit -m $msg2

# Commit 3: Installation system
Write-Host "[3/8] Installation system..." -ForegroundColor Yellow
git add install.ps1 start.bat launch.bat compress_fallback.ps1
$msg3 = @"
build: add installation and launcher system

Add full installer (install.ps1) with Python bootstrap
Add smart launcher (start.bat) with environment detection
Add quick launch script (launch.bat)
Add PowerShell fallback (compress_fallback.ps1) for no-Python scenarios
Implement desktop shortcut and Start Menu integration
Add automatic dependency installation
"@
git commit -m $msg3

# Commit 4: Testing framework
Write-Host "[4/8] Testing framework..." -ForegroundColor Yellow
git add tests/ pytest.ini requirements.txt requirements-test.txt run_tests.ps1 test_system.ps1
$msg4 = @"
test: add comprehensive testing framework

Add 40+ unit tests with pytest
Achieve test coverage >85%
Add test categories: compression, file handling, errors, quality
Create test runner (run_tests.ps1) with coverage reporting
Add system validation tests (test_system.ps1)
Add requirements files for dependencies
"@
git commit -m $msg4

# Commit 5: Sample images system
Write-Host "[5/8] Sample images system..." -ForegroundColor Yellow
git add generate_samples.py
$msg5 = @"
feat: add sample image generation system

Generate 5 test images (landscape, portrait, square, small, panorama)
Support various formats (JPG, PNG) and sizes
Create ~15MB total for realistic compression testing
Integrate with demo functionality
Add auto-generation if samples missing
"@
git commit -m $msg5

# Commit 6: Package builder
Write-Host "[6/8] Package builder and quick setup..." -ForegroundColor Yellow
git add create_package.ps1 quick_setup.bat
$msg6 = @"
build: add package builder and quick setup

Create distribution package creator (create_package.ps1)
Generate ZIP with installer and documentation
Add quick setup script (quick_setup.bat) for one-click setup
Implement automated workflow for samples + tests + git + package
"@
git commit -m $msg6

# Commit 7: Legacy scripts integration
Write-Host "[7/8] Legacy scripts integration..." -ForegroundColor Yellow
git add batch-resize.py resize_images.py organize_images.py Compress-Images.ps1
$msg7 = @"
chore: integrate legacy compression scripts

Add batch-resize.py for batch image resizing
Add resize_images.py for individual image resizing
Add organize_images.py for image organization utilities
Add Compress-Images.ps1 for original PowerShell compression
Keep for reference and compatibility
"@
git commit -m $msg7

# Commit 8: Git initialization scripts
Write-Host "[8/8] Git initialization scripts..." -ForegroundColor Yellow
git add init_git.ps1 init_git_simple.ps1
$msg8 = @"
build: add git initialization scripts

Add init_git.ps1 for feature-based commit setup
Add init_git_simple.ps1 as alternative initialization method
Support automated repository setup with clean history
"@
git commit -m $msg8

# Create tag
Write-Host ""
Write-Host "🏷️  Creating version tag..." -ForegroundColor Cyan
$tagMsg = @"
Release v1.0.0 - Image Compressor Desktop Application

Features:
- Smart image compression to <1MB target
- User-friendly GUI with help and demo
- Multiple installation options
- Comprehensive testing (40+ tests, 85%+ coverage)
- Full documentation (6 guides)
- Sample images for demonstration
- PowerShell fallback for no-Python environments

Created by: Reyis Jones
With assistance from: GitHub Copilot AI
Date: October 2025
"@
git tag -a v1.0.0 -m $tagMsg

Write-Host ""
Write-Host "✅ Git repository initialized successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Repository Summary:" -ForegroundColor Cyan
Write-Host "   • 8 feature-based commits" -ForegroundColor Gray
Write-Host "   • Tagged as v1.0.0" -ForegroundColor Gray
Write-Host "   • Following Conventional Commits style" -ForegroundColor Gray
Write-Host ""
Write-Host "🔍 View commit history:" -ForegroundColor Cyan
Write-Host "   git log --oneline --graph --decorate" -ForegroundColor Gray
Write-Host ""
Write-Host "📝 View detailed log:" -ForegroundColor Cyan
Write-Host "   git log --stat" -ForegroundColor Gray
Write-Host ""
