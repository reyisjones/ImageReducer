# 🖼️ Image Compressor - Desktop Application

A simple, user-friendly desktop application to compress JPG and PNG images to web-optimized sizes while maintaining high visual quality.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![Tests](https://img.shields.io/badge/Tests-Passing-brightgreen.svg)](#testing)
[![GitHub Release](https://img.shields.io/github/v/release/reyisjones/ImageReducer)](https://github.com/reyisjones/ImageReducer/releases/latest)
[![GitHub Downloads](https://img.shields.io/github/downloads/reyisjones/ImageReducer/total)](https://github.com/reyisjones/ImageReducer/releases)
[![CI Status](https://github.com/reyisjones/ImageReducer/workflows/CI%20-%20Tests%20and%20Validation/badge.svg)](https://github.com/reyisjones/ImageReducer/actions)

**Created by Reyis Jones with GitHub Copilot AI** | October 2025 | v1.0.0

---

## 📦 Download

### 🚀 Latest Release

**[View All Releases](https://github.com/reyisjones/ImageReducer/releases)** | **[Latest Version](https://github.com/reyisjones/ImageReducer/releases/latest)**

### Windows Downloads

Choose the best option for you:

#### Option 1: Standalone Executable (Recommended for Quick Use)
- **File:** `ImageCompressor.exe` (~25 MB)
- **Direct Download:** Available in [latest release assets](https://github.com/reyisjones/ImageReducer/releases/latest)
- **No installation required** - Just download and run!
- **Perfect for:** Quick usage, portable installation

#### Option 2: Full Installation Package
- **File:** `ImageCompressor-v{version}-Windows.zip` (~95 MB)
- **Includes:** Executable, documentation, installer scripts, sample images
- **Download from:** [Latest release](https://github.com/reyisjones/ImageReducer/releases/latest)
- **Perfect for:** Complete installation with desktop shortcuts

### 📥 Installation Steps

#### Quick Start (Standalone .exe):
```powershell
# 1. Download ImageCompressor.exe from the latest release
# 2. Double-click to run - that's it!
```

#### Full Installation (Recommended):
```powershell
# 1. Download ImageCompressor-v{version}-Windows.zip
# 2. Extract the ZIP file
# 3. Right-click install.ps1 → Run with PowerShell
# 4. Follow the installation wizard
# 5. Find the app in Start Menu or Desktop shortcut
```

#### Manual Installation:
```powershell
# 1. Extract ZIP to desired location
# 2. Run start.bat or ImageCompressor.exe directly
```

### 🔐 Verify Download (Optional)

Each release includes SHA256 checksums for security verification:

```powershell
# Windows PowerShell
Get-FileHash ImageCompressor-v{version}-Windows.zip -Algorithm SHA256

# Compare with .sha256 file from release
```

---

## ✨ Features

- **User-Friendly GUI** - Clean, intuitive interface built with tkinter
- **Smart Compression** - Automatically compress images to < 1 MB while preserving quality
- **Flexible Input** - Select entire folders or individual files
- **🎯 Help & Demo System** - Built-in help guide and interactive demo with sample images
- **▶️ Run Demo** - One-click demonstration using included sample images
- **Customizable Settings**:
  - Target file size (default: 1 MB)
  - Initial quality (60-95%)
  - Maximum width (800-3840px, default: 1920px for web)
- **Batch Processing** - Process multiple images at once with progress tracking
- **Organized Output** - Compressed images saved to "Reduced" folder
- **No Manual Scripts** - Everything runs from a desktop shortcut
- **🧪 Fully Tested** - Comprehensive unit tests with 85%+ coverage

## 🎮 Quick Demo

Want to see it in action? 

1. **Launch** the application (double-click `start.bat`)
2. **Click** the **"▶️ Run Demo"** button in the header
3. **Watch** as sample images are compressed with before/after comparisons
4. **Review** the results in the status window

The demo uses 5 sample images (various sizes and formats) to showcase the compression capabilities.

## 🚀 Installation

### Option 1: Automated Installer (Recommended)

1. Right-click `install.ps1`
2. Select "Run with PowerShell"
3. Follow the on-screen instructions

The installer will:
- ✅ Detect and install Python if needed
- ✅ Install required dependencies (Pillow)
- ✅ Create desktop shortcut
- ✅ Create Start Menu entry
- ✅ Set up uninstaller

### Option 2: Quick Launch (If Python Already Installed)

Simply double-click `launch.bat` to run the application directly.

### Option 3: Manual Installation

1. Install Python 3.8+ from https://www.python.org/downloads/
2. Install dependencies:
   ```powershell
   pip install Pillow
   ```
3. Run the application:
   ```powershell
   python image_compressor_gui.py
   ```

## 📖 How to Use

1. **Launch** the application from desktop shortcut or Start Menu
2. **Select** a folder or individual image files using the Browse buttons
3. **Adjust** compression settings (optional):
   - Target Size: How small you want files (default 1 MB)
   - Initial Quality: Starting quality level (85 is recommended)
   - Max Width: Maximum image width in pixels (1920 for web)
4. **Click** "Start Compression" button
5. **Wait** for processing to complete
6. **Find** compressed images in the "Reduced" folder

## ⚙️ Compression Settings Guide

| Use Case | Target Size | Quality | Max Width |
|----------|-------------|---------|-----------|
| **Web/Email** | 1 MB | 85 | 1920px |
| **Social Media** | 0.5 MB | 80 | 1920px |
| **High Quality** | 2 MB | 90 | 2560px |
| **Mobile** | 0.3 MB | 75 | 1280px |

## 📁 Project Structure

```
ImageReducer/
├── image_compressor_gui.py    # Main GUI application
├── install.ps1                # Automated installer
├── launch.bat                 # Quick launch script
├── README.md                  # This file
├── batch-resize.py            # Legacy GIMP script
├── resize_images.py           # CLI compression tool
├── organize_images.py         # Image organization utility
└── Compress-Images.ps1        # PowerShell compression script
```

## 🛠️ Technical Details

### Requirements
- **Python**: 3.8 or higher
- **Pillow**: Image processing library
- **Operating System**: Windows 10/11

### How It Works

1. **Image Loading**: Opens images using Pillow (PIL)
2. **Format Conversion**: Converts RGBA/PNG to RGB/JPEG
3. **Smart Resizing**: 
   - Reduces dimensions if larger than max width
   - Maintains aspect ratio
   - Uses LANCZOS resampling for quality
4. **Quality Adjustment**:
   - Starts at specified quality (default 85%)
   - Iteratively reduces quality if file too large
   - Further reduces dimensions if needed
5. **Optimization**: Uses JPEG optimization for smallest file size

### Compression Algorithm

```python
1. Convert image to RGB (if needed)
2. Resize to max_width (if larger)
3. Save with initial quality + optimization
4. While file_size > target_size AND quality > 60:
   - Reduce quality by 5%
   - Re-save
5. While file_size > target_size AND width > 800:
   - Reduce dimensions by 10%
   - Re-save
```

## 🔧 Troubleshooting

### "Python is not installed"
- Run `install.ps1` which will download and install Python automatically
- Or manually install from https://python.org and check "Add to PATH"

### "Failed to install Pillow"
- Open PowerShell as Administrator
- Run: `python -m pip install --upgrade pip`
- Run: `python -m pip install Pillow`

### Application won't start
- Ensure Python is in your PATH
- Try running from command line: `python image_compressor_gui.py`
- Check error messages

### Images not compressing enough
- Lower the "Initial Quality" setting
- Reduce the "Max Width" to 1280px or 1600px
- Set a smaller "Target Size"

### Images losing too much quality
- Increase "Initial Quality" to 90-95
- Increase "Max Width" to 2560px
- Allow larger "Target Size" (1.5-2 MB)

## 🧪 Testing

This project includes comprehensive unit tests to ensure reliability.

### Running Tests

```powershell
# Quick test run
.\run_tests.ps1

# With coverage report
.\run_tests.ps1 -Coverage

# Verbose output
.\run_tests.ps1 -Verbose -Coverage
```

### Test Coverage

- ✅ **Compression Algorithm**: 95%+ coverage
- ✅ **File Handling**: 90%+ coverage
- ✅ **Error Handling**: 85%+ coverage
- ✅ **Overall**: 85%+ coverage

### Test Categories

**Unit Tests** (`tests/test_compression.py`):
- Image compression below target size
- PNG to JPEG conversion
- Aspect ratio preservation
- Quality adjustment
- Error handling

**System Tests** (`test_system.ps1`):
- File existence validation
- Python environment checks
- Dependency verification
- Configuration validation

See `tests/README.md` for detailed testing documentation.

## 🗑️ Uninstallation

### If installed via installer:
1. Navigate to: `%LOCALAPPDATA%\ImageCompressor`
2. Double-click `uninstall.bat`

### Manual removal:
1. Delete desktop shortcut
2. Delete from Start Menu
3. Delete application folder: `%LOCALAPPDATA%\ImageCompressor`

## 📝 License

This project is licensed under the MIT License.

**Copyright (c) 2025 Reyis Jones**

See `LICENSE` file for full license text.

Created with the assistance of GitHub Copilot AI.

## 🔧 Development & Contributing

### Project Setup

For developers wanting to contribute or customize:

```powershell
# Quick setup (runs all setup steps)
.\quick_setup.bat

# Or step by step:

# 1. Generate sample images
python generate_samples.py

# 2. Run tests
.\run_tests.ps1 -Coverage

# 3. Initialize Git (if not done)
.\init_git.ps1

# 4. Create package
.\create_package.ps1 -CreateZip
```

### Git Repository

The project includes proper version control setup:

```powershell
# Initialize with organized commits
.\init_git.ps1
```

This creates 8 feature-based commits following Conventional Commits style:
- `feat:` New features
- `test:` Testing additions
- `build:` Build/deployment changes
- `chore:` Maintenance tasks

### File Structure

```
ImageReducer/
├── image_compressor_gui.py      # Main application
├── install.ps1                  # Installer
├── start.bat                    # Smart launcher
├── tests/                       # Test suite
├── sample_images/               # Demo images
├── docs/                        # Documentation
└── config.ini                   # Configuration
```

See `PROJECT_SUMMARY.md` for complete technical documentation.

## 📚 Documentation

- **README.md** (this file) - Overview and basic usage
- **QUICKSTART.md** - Quick reference guide
- **ADVANCED.md** - Advanced features and automation
- **VISUAL_GUIDE.md** - Step-by-step visual walkthrough
- **PROJECT_SUMMARY.md** - Technical architecture
- **COMPLETION_SUMMARY.md** - Implementation checklist
- **tests/README.md** - Testing documentation

## 👨‍💻 Credits

**Created by:** Reyis Jones  
**With assistance from:** GitHub Copilot AI  
**Date:** October 2025  
**Version:** 1.0.0

Created for easy image compression and optimization for web content, email, and content creation.

---

**Version**: 1.0.0  
**Last Updated**: October 2025
