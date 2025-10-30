# Add FFmpeg to Windows PATH environment variable

$ffmpegPath = "C:\Users\renieves\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.0-full_build\bin"

# Get current user PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Check if FFmpeg is already in PATH
if ($currentPath -like "*$ffmpegPath*") {
    Write-Host "FFmpeg is already in your PATH" -ForegroundColor Green
} else {
    # Add FFmpeg to PATH
    $newPath = "$currentPath;$ffmpegPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "FFmpeg has been added to your PATH" -ForegroundColor Green
    Write-Host "Please restart your terminal or application for changes to take effect" -ForegroundColor Yellow
}

# Test if FFmpeg is accessible
Write-Host "`nTesting FFmpeg..." -ForegroundColor Cyan
try {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    $ffmpegVersion = & ffmpeg -version 2>&1 | Select-Object -First 1
    Write-Host "Success: $ffmpegVersion" -ForegroundColor Green
} catch {
    Write-Host "FFmpeg not yet accessible in this session. Restart required." -ForegroundColor Yellow
}
