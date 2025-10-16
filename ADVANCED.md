# 🔧 Advanced Features Guide

## Configuration File

The `config.ini` file allows you to customize default settings without modifying code.

### Location
- **Portable**: Same folder as application
- **Installed**: `%LOCALAPPDATA%\ImageCompressor\config.ini`

### Quick Edit
1. Open `config.ini` in Notepad
2. Modify values
3. Save and restart application

---

## Command Line Usage

### Python Version

```powershell
# Basic usage
python image_compressor_gui.py

# With default settings
python -c "from image_compressor_gui import main; main()"
```

### PowerShell Version

```powershell
# Interactive GUI
.\compress_fallback.ps1

# Command line
.\compress_fallback.ps1 -InputPath "C:\Photos" -MaxWidth 1920 -OutputFolder "Compressed"

# Parameters
-InputPath      # Folder with images
-OutputFolder   # Output folder name (default: Reduced)
-MaxWidth       # Maximum width in pixels (default: 1920)
-Quality        # JPEG quality (default: 85)
-MaxSizeMB      # Target size in MB (default: 1.0)
```

---

## Batch Processing Scripts

### Process Multiple Folders

Create `batch_compress.bat`:
```batch
@echo off
for /d %%D in (C:\Photos\*) do (
    echo Processing %%D
    python image_compressor_gui.py --folder "%%D" --auto-start
)
echo All folders processed!
```

### Scheduled Compression

Use Windows Task Scheduler:
1. Open Task Scheduler
2. Create Basic Task
3. Set trigger (daily, weekly, etc.)
4. Action: Start program
5. Program: `python`
6. Arguments: `"C:\Path\To\image_compressor_gui.py" --folder "C:\Photos" --auto-start`

---

## Integration with Other Tools

### Context Menu Integration

Add "Compress Images" to right-click menu:

**Registry file** (`add_context_menu.reg`):
```registry
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\Directory\shell\CompressImages]
@="Compress Images"
"Icon"="imageres.dll,72"

[HKEY_CLASSES_ROOT\Directory\shell\CompressImages\command]
@="\"C:\\Windows\\System32\\cmd.exe\" /c \"cd /d \"%1\" && python \"C:\\Path\\To\\image_compressor_gui.py\" --folder \"%1\" --auto-start\""
```

### Drag and Drop

Create `drop_here.bat`:
```batch
@echo off
python image_compressor_gui.py --folder "%~1"
```

Then drag folders onto this batch file to compress.

---

## Performance Optimization

### Multi-Threading

Edit `config.ini`:
```ini
[Advanced]
MultiThreading = true
MaxThreads = 8
```

**Recommended threads:**
- 2-4 cores: 2 threads
- 4-8 cores: 4 threads
- 8+ cores: 6-8 threads

### Memory Management

For large batches (1000+ images):
1. Process in smaller batches
2. Close other applications
3. Increase virtual memory

---

## Custom Presets

### Creating Presets

Edit `config.ini`:
```ini
[Presets]
Portfolio = 3.0,95,3840
Thumbnail = 0.1,70,600
Instagram = 0.8,88,1920
Email = 0.5,80,1600
```

### Using Presets in Code

Modify `image_compressor_gui.py` to add preset buttons:
```python
def load_preset(self, preset_name):
    config = configparser.ConfigParser()
    config.read('config.ini')
    
    if preset_name in config['Presets']:
        size, quality, width = config['Presets'][preset_name].split(',')
        self.max_size_mb.set(float(size))
        self.quality.set(int(quality))
        self.max_width.set(int(width))
```

---

## Automation Examples

### Watch Folder Script

Monitor a folder and auto-compress new images:

```powershell
# watch_folder.ps1
$folder = "C:\Photos\Incoming"
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $folder
$watcher.Filter = "*.jpg"
$watcher.EnableRaisingEvents = $true

$action = {
    $path = $Event.SourceEventArgs.FullPath
    Write-Host "New image: $path"
    python image_compressor_gui.py --file "$path" --auto-start
}

Register-ObjectEvent $watcher "Created" -Action $action
Write-Host "Watching $folder for new images..."
while($true) { Start-Sleep 1 }
```

### Bulk Rename After Compression

```powershell
# rename_compressed.ps1
$folder = "C:\Photos\Reduced"
$counter = 1

Get-ChildItem $folder -Filter *.jpg | ForEach-Object {
    $newName = "photo_{0:D4}.jpg" -f $counter
    Rename-Item $_.FullName $newName
    $counter++
}
```

---

## Quality Control

### Compare Before/After

```python
# compare_images.py
from PIL import Image
import os

def compare_images(original_path, compressed_path):
    orig = Image.open(original_path)
    comp = Image.open(compressed_path)
    
    orig_size = os.path.getsize(original_path) / 1024 / 1024
    comp_size = os.path.getsize(compressed_path) / 1024 / 1024
    
    print(f"Original: {orig.size} @ {orig_size:.2f} MB")
    print(f"Compressed: {comp.size} @ {comp_size:.2f} MB")
    print(f"Reduction: {((orig_size - comp_size) / orig_size * 100):.1f}%")

compare_images("original.jpg", "Reduced/original.jpg")
```

### Visual Quality Check

```python
# quality_check.py
from PIL import Image, ImageChops

def calculate_difference(img1_path, img2_path):
    img1 = Image.open(img1_path).convert('RGB')
    img2 = Image.open(img2_path).convert('RGB')
    
    # Resize to same size for comparison
    if img1.size != img2.size:
        img2 = img2.resize(img1.size, Image.LANCZOS)
    
    diff = ImageChops.difference(img1, img2)
    
    # Calculate average difference
    stat = ImageStat.stat(diff)
    avg_diff = sum(stat.mean) / len(stat.mean)
    
    print(f"Average difference: {avg_diff:.2f}")
    return avg_diff

# Usage
diff = calculate_difference("original.jpg", "Reduced/original.jpg")
if diff < 10:
    print("✅ Excellent quality preservation")
elif diff < 25:
    print("✅ Good quality")
else:
    print("⚠️ Noticeable quality loss")
```

---

## Error Handling

### Skip Corrupted Images

Modify processing to continue on errors:

```python
try:
    compress_image(file)
except Exception as e:
    log_error(file, str(e))
    continue  # Skip to next image
```

### Retry Failed Compressions

```python
max_retries = 3
for attempt in range(max_retries):
    try:
        compress_image(file)
        break
    except Exception as e:
        if attempt == max_retries - 1:
            log_error(file, "Failed after 3 attempts")
        else:
            time.sleep(1)  # Wait before retry
```

---

## Export/Import Settings

### Export Settings

```powershell
# Export current config
Copy-Item config.ini config_backup.ini
```

### Import Settings

```powershell
# Restore config
Copy-Item config_backup.ini config.ini
```

### Share Settings

Email `config.ini` to share your perfect compression settings with others!

---

## Platform-Specific Features

### Windows 10/11

- **Windows Terminal**: Better colors and Unicode support
- **PowerShell 7**: Improved performance
- **Windows Sandbox**: Test installation safely

### Network Drives

When compressing images on network drives:
```powershell
# Mount network drive
net use Z: \\server\photos

# Compress with local temp folder
python image_compressor_gui.py --folder "Z:\Photos" --temp "C:\Temp"
```

---

## Troubleshooting Advanced Issues

### Out of Memory

Reduce batch size:
```ini
[Advanced]
MaxBatchSize = 50
ProcessInChunks = true
```

### Slow Performance

Enable benchmarking:
```ini
[Logging]
EnableProfiling = true
```

### Permission Errors

Run as administrator or check folder permissions:
```powershell
icacls "C:\Photos" /grant Users:(OI)(CI)M
```

---

## Developer Features

### API Usage

```python
from image_compressor_gui import compress_image

# Programmatic compression
result = compress_image(
    input_path="photo.jpg",
    output_path="compressed.jpg",
    quality=85,
    max_width=1920,
    target_size_mb=1.0
)

print(f"Compressed: {result['original_size']} → {result['final_size']} MB")
```

### Plugin System

Create custom processors:
```python
# custom_processor.py
def custom_watermark(img):
    # Add watermark logic
    return img

# Register plugin
register_processor('watermark', custom_watermark)
```

---

## Best Practices

1. **Always backup** originals before bulk operations
2. **Test settings** on a few images first
3. **Monitor quality** with sample comparisons
4. **Use presets** for consistent results
5. **Schedule** regular compressions for efficiency

---

**Need more help?**  
See `README.md` for basics or create a GitHub issue for complex scenarios.
