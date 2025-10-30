# Installing FFmpeg for Video Compression

Video compression requires FFmpeg to be installed on your system. The application will automatically install the Python wrapper (`ffmpeg-python`), but you also need the FFmpeg binary.

## Windows Installation

### Option 1: Using winget (Windows 10/11)
```powershell
winget install ffmpeg
```

### Option 2: Using Chocolatey
```powershell
choco install ffmpeg
```

### Option 3: Manual Installation
1. Download FFmpeg from: https://ffmpeg.org/download.html
2. Extract the ZIP file to a location (e.g., `C:\ffmpeg`)
3. Add FFmpeg to your system PATH:
   - Open "Environment Variables" in System Properties
   - Under "System variables", find and edit "Path"
   - Add the path to FFmpeg's `bin` folder (e.g., `C:\ffmpeg\bin`)
   - Click OK to save
4. Restart your terminal/application

## Verify Installation

Open a new terminal and run:
```bash
ffmpeg -version
```

You should see FFmpeg version information if it's installed correctly.

## Troubleshooting

### "FFmpeg not found" error
- Make sure FFmpeg is in your system PATH
- Restart the ImageReducer application after installing FFmpeg
- Try running `ffmpeg -version` in a terminal to verify

### Permission errors
- Run the installer or terminal as Administrator
- Make sure you have write permissions to the installation directory

## Alternative: Use CLI Without FFmpeg in GUI

If you prefer not to install FFmpeg for GUI use, you can still use video compression via command line:

```bash
python src/main.py --video input.mp4 --crf 28 --preset medium --output compressed.mp4
```

Just make sure FFmpeg is available in your terminal's PATH.
