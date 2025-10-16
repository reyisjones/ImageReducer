# 🔨 Build & Release Guide

This guide explains how to build, package, and release the Image Compressor application.

---

## 📋 Prerequisites

### Required Software
- **Python 3.8+** - [Download](https://www.python.org/downloads/)
- **Git** - [Download](https://git-scm.com/downloads)
- **PyInstaller** - Installed via `requirements-build.txt`

### Required Files
All required files are included in this repository.

---

## 🏗️ Building the Executable

### Option 1: Automated Build Script (Recommended)

```powershell
# Clean build (removes previous builds)
.\build_exe.ps1 -Clean

# Build with tests
.\build_exe.ps1 -Test

# Build with debug console (for troubleshooting)
.\build_exe.ps1 -Debug
```

### Option 2: Manual Build

```powershell
# Install build dependencies
pip install -r requirements-build.txt

# Build executable
python -m PyInstaller --name=ImageCompressor --onefile --windowed --clean image_compressor_gui.py
```

### Build Output

After successful build:
- **Executable**: `dist\ImageCompressor.exe` (~25 MB)
- **Build files**: `build\` directory (can be deleted)
- **Spec file**: `ImageCompressor.spec` (PyInstaller configuration)

---

## 📦 Creating Distribution Package

### Using create_package.ps1

```powershell
# Create ZIP package
.\create_package.ps1 -CreateZip

# Full package with docs
.\create_package.ps1 -IncludeDocs -CreateZip
```

### Manual Package Creation

```powershell
# Create package folder
$version = "1.0.0"
New-Item -ItemType Directory -Path "release/ImageCompressor-v$version"

# Copy files
Copy-Item "dist\ImageCompressor.exe" "release/ImageCompressor-v$version\"
Copy-Item "README.md" "release/ImageCompressor-v$version\"
Copy-Item "LICENSE" "release/ImageCompressor-v$version\"
Copy-Item "config.ini" "release/ImageCompressor-v$version\"

# Create ZIP
Compress-Archive -Path "release/ImageCompressor-v$version\*" -DestinationPath "release/ImageCompressor-v$version.zip"
```

---

## 🚀 Release Process

### 1. Update Version

Edit `version.py`:
```python
__version__ = "1.1.0"  # Update version number
```

### 2. Commit Changes

```bash
git add version.py
git commit -m "chore: bump version to 1.1.0"
git push origin master
```

### 3. Create Git Tag

```bash
# Create annotated tag
git tag -a v1.1.0 -m "Release version 1.1.0

Features:
- New feature 1
- New feature 2

Fixes:
- Bug fix 1
"

# Push tag to GitHub
git push origin v1.1.0
```

### 4. GitHub Actions Workflow

When you push a tag, GitHub Actions automatically:
1. ✅ Runs all tests
2. 🔨 Builds the executable
3. 📦 Creates distribution package
4. 📤 Uploads to GitHub Releases
5. 📝 Generates release notes

### 5. Verify Release

1. Go to [GitHub Releases](https://github.com/reyisjones/ImageReducer/releases)
2. Verify v1.1.0 release is published
3. Download and test artifacts:
   - `ImageCompressor.exe`
   - `ImageCompressor-v1.1.0-Windows.zip`
4. Verify SHA256 checksum

---

## 🧪 Testing Before Release

### Run All Tests

```powershell
# Unit tests with coverage
.\run_tests.ps1 -Coverage

# System validation
.\test_system.ps1

# Build test
.\build_exe.ps1 -Test
```

### Manual Testing Checklist

- [ ] Application launches without errors
- [ ] GUI displays correctly
- [ ] Help dialog shows version info
- [ ] Demo feature works with sample images
- [ ] Folder compression works
- [ ] Individual file compression works
- [ ] Settings save and load correctly
- [ ] Progress bar updates properly
- [ ] Output files are created in "Reduced" folder
- [ ] Compressed images are < target size
- [ ] Quality is acceptable

---

## 📝 Version Management

### Semantic Versioning

Follow [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes (e.g., 2.0.0)
- **MINOR**: New features, backwards compatible (e.g., 1.1.0)
- **PATCH**: Bug fixes, backwards compatible (e.g., 1.0.1)

### Version Files to Update

1. `version.py` - Main version source
2. `README.md` - Update version badge
3. Git tag - Create new tag for release

---

## 🔄 Continuous Integration (CI)

### GitHub Actions Workflows

#### CI Workflow (`.github/workflows/ci.yml`)
Runs on every push and PR:
- ✅ Unit tests
- 🔍 Code linting
- 🔨 Test build

#### Release Workflow (`.github/workflows/release.yml`)
Runs on tag push (v*.*.* ):
- ✅ All tests
- 🔨 Production build
- 📦 Package creation
- 📤 Upload to GitHub Releases

### Viewing Workflow Status

1. Go to [Actions tab](https://github.com/reyisjones/ImageReducer/actions)
2. Select workflow run
3. View logs and artifacts

---

## 🐛 Troubleshooting Build Issues

### PyInstaller Import Errors

If missing imports, add to `build_exe.ps1`:
```powershell
--hidden-import=module_name
```

### Large Executable Size

Executable is large (~25 MB) because it bundles:
- Python interpreter
- Pillow library
- tkinter GUI toolkit
- All dependencies

To reduce size:
- Use `--exclude-module` for unused modules
- Consider using `--onedir` instead of `--onefile`

### Build Failures

1. Check Python version: `python --version`
2. Verify dependencies: `pip list`
3. Clean build: `.\build_exe.ps1 -Clean`
4. Check build logs in `build/` directory
5. Try debug build: `.\build_exe.ps1 -Debug`

---

## 📚 Additional Resources

- [PyInstaller Documentation](https://pyinstaller.org/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

## 🤝 Contributing

When contributing code:

1. Create feature branch: `git checkout -b feature/new-feature`
2. Make changes and test: `.\run_tests.ps1`
3. Commit with conventional style: `git commit -m "feat: add new feature"`
4. Push and create PR: `git push origin feature/new-feature`
5. CI will automatically run tests

---

**Build System Created by:** Reyis Jones with GitHub Copilot AI  
**Last Updated:** October 2025
