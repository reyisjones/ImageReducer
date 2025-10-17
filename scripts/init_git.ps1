# Git Repository Initialization Script
# Sets up version control with proper commit history

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "`n=== Git Repository Initialization ===`n" -ForegroundColor Cyan

# Check if git is installed
try {
    $gitVersion = git --version
    Write-Host "Git detected: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "Git is not installed. Please install Git first." -ForegroundColor Red
    Write-Host "   Download from: https://git-scm.com/downloads" -ForegroundColor Yellow
    exit 1
}

# Check if already a git repo
if (Test-Path ".git") {
    if (-not $Force) {
    Write-Host "Git repository already exists." -ForegroundColor Yellow
        $response = Read-Host "Reinitialize? This will preserve history. (Y/N)"
        if ($response -ne "Y" -and $response -ne "y") {
            Write-Host "Aborted." -ForegroundColor Yellow
            exit 0
        }
    }
}

# Create .gitignore
Write-Host "`nCreating .gitignore..." -ForegroundColor Cyan
$gitignore = @"
# Python
__pycache__/
*.py[cod]
*`$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual Environment
venv/
ENV/
env/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Testing
.pytest_cache/
.coverage
htmlcov/
*.cover
.hypothesis/
.tox/

# Output folders
Reduced/
sample_images/Reduced/

# Logs
*.log
compression.log

# Temporary files
*.tmp
*.bak
*.backup

# OS
Thumbs.db
desktop.ini

# Package files
*.zip
ImageCompressor_Package/

# User-specific
config_backup.ini
"@

Set-Content -Path ".gitignore" -Value $gitignore
Write-Host "   .gitignore created" -ForegroundColor Gray

# Initialize repository
if (-not (Test-Path ".git")) {
    Write-Host "`nInitializing Git repository..." -ForegroundColor Cyan
    git init
    Write-Host "   Repository initialized" -ForegroundColor Gray
}

# Configure git (if not already configured globally)
$userName = git config user.name 2>$null
$userEmail = git config user.email 2>$null

if ([string]::IsNullOrWhiteSpace($userName)) {
    Write-Host "`nConfiguring Git user..." -ForegroundColor Cyan
    $name = Read-Host "Enter your name (e.g. Reyis Jones)"
    git config user.name "$name"
    Write-Host "   User name set" -ForegroundColor Gray
}

if ([string]::IsNullOrWhiteSpace($userEmail)) {
    $email = Read-Host "Enter your email"
    git config user.email "$email"
    Write-Host "   User email set" -ForegroundColor Gray
}

# Feature-based commits
Write-Host "`nCreating feature-based commits..." -ForegroundColor Cyan

# Commit 1: Project structure
Write-Host "`n[1/8] Project structure..." -ForegroundColor Yellow
# Stage root-level and docs files according to current structure
git add LICENSE README.md config.ini .gitignore 2>$null
git add docs/QUICKSTART.md docs/ADVANCED.md docs/PROJECT_SUMMARY.md docs/VISUAL_GUIDE.md 2>$null
git commit -m "feat: initialize project structure

- Add MIT License (Copyright 2025 Reyis Jones)
- Create comprehensive documentation (README, QUICKSTART, ADVANCED)
- Add configuration file with presets
- Set up .gitignore for Python project

Created with Copilot AI assistance" 2>$null

 # Commit 2: Core compression engine
Write-Host "[2/8] Core compression engine..." -ForegroundColor Yellow
git add src/image_compressor_gui.py src/version.py requirements.txt 2>$null
git commit -m "feat: add image compression core

- Implement smart compression algorithm
- Support JPG and PNG formats
- Automatic quality adjustment to meet target size
- Maintain aspect ratios during resize
- Convert PNG to JPEG with transparency handling

Features:
- Target file size: configurable (default 1 MB)
- Quality range: 60-95%
- Resolution control: 800-3840px
- Web-optimized defaults (1920px, 85% quality)" 2>$null

 # Commit 3: UI implementation
Write-Host "[3/8] UI implementation..." -ForegroundColor Yellow
git add src/image_compressor_gui.py src/main.py 2>$null
git commit -m "feat: implement GUI for folder/file selection

- Clean, modern interface using tkinter
- Folder and individual file selection dialogs
- Real-time progress tracking with progress bar
- Status messages and logging window
- Customizable compression settings
- Cancel operation support

UI Components:
- Browse folder/files buttons
- Settings panel (size, quality, dimensions)
- Progress indicator
- Status text with scrolling" 2>$null

 # Commit 4: Installation system and scripts
Write-Host "[4/8] Installation system..." -ForegroundColor Yellow
git add scripts/install.ps1 scripts/start.bat scripts/launch.bat scripts/compress_fallback.ps1 2>$null
git commit -m "feat: create installer and launchers

- Automated installer with Python detection
- Bootstrap Python installation if needed
- Desktop shortcut creation
- Start Menu integration
- Uninstaller included
- PowerShell fallback (no Python required)
- Smart launcher with multiple options

Installation Options:
1. Full installation (install.ps1)
2. Quick launch (start.bat)
3. PowerShell mode (compress_fallback.ps1)" 2>$null

 # Commit 5: Testing
Write-Host "[5/8] Testing framework..." -ForegroundColor Yellow
git add src/tests/ pytest.ini requirements-test.txt scripts/test_system.ps1 scripts/run_tests.ps1 scripts/test_local.ps1 2>$null
git commit -m "test: add pytest and system test cases

- Unit tests for compression algorithm
- File handling tests
- Error handling and edge cases
- Image quality preservation tests
- Configuration tests
- System validation script

Test Coverage:
- Compression below 1 MB
- PNG to JPEG conversion
- Aspect ratio maintenance
- Quality adjustment
- File/folder operations
- Permission errors
- Corrupted image handling

Run tests: pytest tests/ -v" 2>$null

 # Commit 6: Sample images
Write-Host "[6/8] Sample images..." -ForegroundColor Yellow
git add src/generate_samples.py sample_images/ 2>$null
git commit -m "feat: add sample images for testing

- Generate 5 test images (various sizes and formats)
- Sample image generator script
- README for samples
- Support for demo functionality

Sample Images:
- Landscape (3000x2000 JPG)
- Portrait (2000x3000 PNG)
- Square (2500x2500 JPG)
- Small (1500x1500 PNG)
- Panorama (4000x1500 JPG)" 2>$null

 # Commit 7: Package builder
Write-Host "[7/8] Package builder..." -ForegroundColor Yellow
git add scripts/create_package.ps1 scripts/build_exe.ps1 2>$null
git commit -m "build: create installer and package builder

- Distribution package builder
- HTML user guide generation
- ZIP archive creation
- Professional structure
- All dependencies included

Package Contents:
- Application files
- Documentation
- Sample images
- Installers
- Configuration

Run: .\create_package.ps1 -CreateZip" 2>$null

 # Commit 8: Legacy scripts
Write-Host "[8/8] Legacy integration..." -ForegroundColor Yellow
git add batch-resize.py resize_images.py organize_images.py Compress-Images.ps1 2>$null
git commit -m "chore: integrate legacy scripts

- batch-resize.py (GIMP integration)
- resize_images.py (CLI compression)
- organize_images.py (image organization)
- Compress-Images.ps1 (PowerShell compression)

Note: Legacy scripts integrated into main application
Kept for reference and backward compatibility" 2>$null

# Create initial tag
Write-Host "`nCreating release tag..." -ForegroundColor Cyan
git tag -a v1.0.0 -m "Release v1.0.0 - Initial Release

Image Compressor Desktop Application

Features:
- User-friendly GUI
- Smart compression algorithm
- Multiple installation options
- PowerShell fallback
- Comprehensive documentation
- Unit tests with pytest
- Sample images
- MIT License

Created by Reyis Jones with Copilot AI assistance
October 2025"

Write-Host "   Tag v1.0.0 created" -ForegroundColor Gray

# Summary
Write-Host "`nGit Repository Initialized!`n" -ForegroundColor Green

Write-Host "Repository Status:" -ForegroundColor White
git log --oneline --all --graph --decorate -10

Write-Host "`nCurrent Branch:" -ForegroundColor White
git branch

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "   - Review commits: git log" -ForegroundColor Gray
Write-Host "   - Create remote repo on GitHub/GitLab" -ForegroundColor Gray
Write-Host "   - Add remote: git remote add origin <url>" -ForegroundColor Gray
Write-Host "   - Push: git push -u origin main --tags`n" -ForegroundColor Gray

Write-Host "Ready for version control!" -ForegroundColor Green
