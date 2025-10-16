# 🚀 Quick Start Guide - Image Compressor

## First Time Setup (Choose One)

### ✨ Option 1: Full Installation (Recommended)
**Best for**: Regular use, desktop shortcut

1. **Right-click** `install.ps1`
2. **Select** "Run with PowerShell"
3. **Follow** on-screen prompts
4. **Done!** Launch from desktop shortcut

**What it does:**
- ✅ Installs Python (if needed)
- ✅ Installs dependencies
- ✅ Creates desktop shortcut
- ✅ Creates Start Menu entry

---

### ⚡ Option 2: Quick Launch
**Best for**: Python already installed, quick test

1. **Double-click** `launch.bat`
2. **Done!** Application starts immediately

**Requirements:**
- Python 3.8+ installed
- Will auto-install Pillow if needed

---

### 🔧 Option 3: PowerShell Fallback
**Best for**: No Python, one-time use

1. **Right-click** `compress_fallback.ps1`
2. **Select** "Run with PowerShell"
3. **Use** the GUI that appears

**Note:** Limited features, slower performance

---

## Using the Application

### Step 1: Select Images
- Click **"Browse Folder"** to select a folder with images
- OR click **"Browse Files"** to select specific images

### Step 2: Adjust Settings (Optional)
| Setting | Default | When to Change |
|---------|---------|----------------|
| **Target Size** | 1 MB | For email (0.5 MB) or high quality (2 MB) |
| **Initial Quality** | 85 | For better quality (90+) or smaller size (75) |
| **Max Width** | 1920px | For mobile (1280px) or high-res (2560px) |

### Step 3: Compress
1. Click **"Start Compression"**
2. Wait for progress bar to complete
3. Find compressed images in **"Reduced"** folder

---

## Common Use Cases

### 📧 Email Attachments
```
Target Size: 0.5 MB
Quality: 80
Max Width: 1920px
```

### 🌐 Website Images
```
Target Size: 1 MB
Quality: 85
Max Width: 1920px
```

### 📱 Social Media
```
Target Size: 0.8 MB
Quality: 85
Max Width: 1920px
```

### 🖼️ High Quality Portfolio
```
Target Size: 2 MB
Quality: 90
Max Width: 2560px
```

---

## Troubleshooting

### ❌ "Python not found"
**Solution:** Run `install.ps1` to auto-install Python

### ❌ Application won't start
**Solution:** Try PowerShell fallback: `compress_fallback.ps1`

### ⚠️ Images still too large
**Solution:** 
- Lower "Initial Quality" to 75
- Reduce "Max Width" to 1600px

### ⚠️ Images look blurry
**Solution:**
- Increase "Initial Quality" to 90
- Increase "Target Size" to 1.5-2 MB

---

## File Organization

After compression, your folder will look like this:

```
Your Folder/
├── image1.jpg          ← Original
├── image2.jpg          ← Original
├── image3.png          ← Original
└── Reduced/            ← NEW FOLDER
    ├── image1.jpg      ← Compressed
    ├── image2.jpg      ← Compressed
    └── image3.jpg      ← Compressed (PNG→JPG)
```

**Note:** Original files are never modified!

---

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Ctrl+O` | Browse folder |
| `Enter` | Start compression (when button focused) |
| `Esc` | Cancel compression |

---

## Performance Tips

### Faster Processing
- Close other applications
- Process folders (not individual files)
- Use SSD storage if available

### Better Quality
- Start with high quality settings
- Use larger max width
- Allow larger target file size

### Smaller Files
- Reduce max width to 1280-1600px
- Lower quality to 75-80
- Set target size to 0.5 MB

---

## Need Help?

1. **Check** `README.md` for detailed documentation
2. **Review** troubleshooting section above
3. **Try** PowerShell fallback if Python issues

---

## Uninstall

### If installed via installer:
```
%LOCALAPPDATA%\ImageCompressor\uninstall.bat
```

### If using portable mode:
Simply delete the folder

---

**Version:** 1.0  
**Last Updated:** October 2025  

Happy compressing! 🎉
