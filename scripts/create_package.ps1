# Package Builder for Image Compressor
# Creates a portable/distributable package

param(
    [string]$OutputDir = ".\ImageCompressor_Package",
    [switch]$CreateZip
)

Write-Host "`n=== Image Compressor - Package Builder ===`n" -ForegroundColor Cyan

# Create output directory
if (Test-Path $OutputDir) {
    Write-Host "⚠️  Output directory exists. Cleaning..." -ForegroundColor Yellow
    Remove-Item $OutputDir -Recurse -Force
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
Write-Host "✅ Created output directory: $OutputDir" -ForegroundColor Green

# Files to include
$files = @(
    "src/image_compressor_gui.py",
    "src/main.py",
    "src/version.py",
    "scripts/install.ps1",
    "scripts/launch.bat",
    "scripts/start.bat",
    "scripts/compress_fallback.ps1",
    "scripts/build_exe.ps1",
    "scripts/run_tests.ps1",
    "scripts/test_system.ps1",
    "scripts/test_local.ps1",
    "config.ini",
    "README.md",
    "docs/QUICKSTART.md",
    "docs/ADVANCED.md",
    "docs/PROJECT_SUMMARY.md",
    "docs/VISUAL_GUIDE.md"
)

# Copy files
Write-Host "`nCopying files..." -ForegroundColor Cyan
foreach ($file in $files) {
    if (Test-Path $file) {
        $dest = Join-Path $OutputDir (Split-Path $file -Leaf)
        Copy-Item $file -Destination $dest -Force
        Write-Host "   ✓ $file" -ForegroundColor Gray
    } else {
        Write-Host "   ⚠️  $file (not found, skipping)" -ForegroundColor Yellow
    }
}

# Copy docs folder recursively for completeness
if (Test-Path "docs") {
    Copy-Item "docs" -Destination (Join-Path $OutputDir "docs") -Recurse -Force
    Write-Host "   ✓ docs/ (recursive)" -ForegroundColor Gray
}

# Create quick start HTML
Write-Host "`n📄 Generating HTML guide..." -ForegroundColor Cyan
$htmlGuide = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Image Compressor - User Guide</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
            color: white;
            padding: 40px;
            text-align: center;
        }
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        .header p {
            font-size: 1.2em;
            opacity: 0.9;
        }
        .content {
            padding: 40px;
        }
        .section {
            margin-bottom: 30px;
        }
        .section h2 {
            color: #2c3e50;
            border-left: 4px solid #667eea;
            padding-left: 15px;
            margin-bottom: 15px;
        }
        .section h3 {
            color: #34495e;
            margin: 15px 0 10px 0;
        }
        .button-group {
            display: flex;
            gap: 15px;
            margin: 20px 0;
            flex-wrap: wrap;
        }
        .button {
            flex: 1;
            min-width: 200px;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-align: center;
            border-radius: 8px;
            text-decoration: none;
            font-weight: bold;
            transition: transform 0.2s;
        }
        .button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        .button.secondary {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
        }
        .button.alt {
            background: linear-gradient(135deg, #ee0979 0%, #ff6a00 100%);
        }
        .feature-list {
            list-style: none;
            padding-left: 0;
        }
        .feature-list li {
            padding: 10px 0;
            padding-left: 30px;
            position: relative;
        }
        .feature-list li:before {
            content: "✓";
            position: absolute;
            left: 0;
            color: #27ae60;
            font-weight: bold;
            font-size: 1.2em;
        }
        .steps {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin: 15px 0;
        }
        .steps ol {
            margin-left: 20px;
        }
        .steps li {
            margin: 10px 0;
        }
        .tip {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 15px;
            margin: 15px 0;
            border-radius: 4px;
        }
        .footer {
            background: #2c3e50;
            color: white;
            text-align: center;
            padding: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        th {
            background: #667eea;
            color: white;
        }
        tr:nth-child(even) {
            background: #f8f9fa;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🖼️ Image Compressor</h1>
            <p>Simple, Fast, Reliable Image Compression</p>
        </div>
        
        <div class="content">
            <div class="section">
                <h2>🚀 Quick Start</h2>
                <div class="button-group">
                    <a href="install.ps1" class="button">
                        📦 Full Installation<br>
                        <small>Recommended - One-click setup</small>
                    </a>
                    <a href="start.bat" class="button secondary">
                        ⚡ Quick Launch<br>
                        <small>Already have Python?</small>
                    </a>
                    <a href="compress_fallback.ps1" class="button alt">
                        🔧 PowerShell Mode<br>
                        <small>No Python needed</small>
                    </a>
                </div>
            </div>

            <div class="section">
                <h2>📖 How to Use</h2>
                <div class="steps">
                    <ol>
                        <li><strong>Select</strong> images or folder using Browse buttons</li>
                        <li><strong>Adjust</strong> compression settings (or use defaults)</li>
                        <li><strong>Click</strong> "Start Compression" button</li>
                        <li><strong>Wait</strong> for progress to complete</li>
                        <li><strong>Find</strong> compressed images in "Reduced" folder</li>
                    </ol>
                </div>
            </div>

            <div class="section">
                <h2>✨ Features</h2>
                <ul class="feature-list">
                    <li>Compress JPG and PNG images to &lt; 1 MB</li>
                    <li>Maintain high visual quality</li>
                    <li>Web-optimized resolution (1920px default)</li>
                    <li>Batch process entire folders</li>
                    <li>Progress tracking and status updates</li>
                    <li>Original files never modified</li>
                    <li>Customizable compression settings</li>
                    <li>Desktop shortcut for easy access</li>
                </ul>
            </div>

            <div class="section">
                <h2>⚙️ Recommended Settings</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Use Case</th>
                            <th>Target Size</th>
                            <th>Quality</th>
                            <th>Max Width</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>📧 Email</td>
                            <td>0.5 MB</td>
                            <td>80</td>
                            <td>1920px</td>
                        </tr>
                        <tr>
                            <td>🌐 Website</td>
                            <td>1.0 MB</td>
                            <td>85</td>
                            <td>1920px</td>
                        </tr>
                        <tr>
                            <td>📱 Social Media</td>
                            <td>0.8 MB</td>
                            <td>85</td>
                            <td>1920px</td>
                        </tr>
                        <tr>
                            <td>🖼️ Portfolio</td>
                            <td>2.0 MB</td>
                            <td>90</td>
                            <td>2560px</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="tip">
                <strong>💡 Pro Tip:</strong> Original images are never modified! All compressed images are saved to a new "Reduced" folder, keeping your originals safe.
            </div>

            <div class="section">
                <h2>❓ Troubleshooting</h2>
                
                <h3>Python not found?</h3>
                <p>Run <code>install.ps1</code> to automatically install Python and all dependencies.</p>
                
                <h3>Application won't start?</h3>
                <p>Try the PowerShell fallback: Right-click <code>compress_fallback.ps1</code> → Run with PowerShell</p>
                
                <h3>Images still too large?</h3>
                <ul>
                    <li>Lower "Initial Quality" to 75-80</li>
                    <li>Reduce "Max Width" to 1600px</li>
                    <li>Set smaller "Target Size"</li>
                </ul>
                
                <h3>Images look blurry?</h3>
                <ul>
                    <li>Increase "Initial Quality" to 90-95</li>
                    <li>Increase "Max Width" to 2560px</li>
                    <li>Allow larger "Target Size" (1.5-2 MB)</li>
                </ul>
            </div>

            <div class="section">
                <h2>📚 Documentation</h2>
                <ul>
                    <li><strong>README.md</strong> - Complete documentation</li>
                    <li><strong>QUICKSTART.md</strong> - Quick reference guide</li>
                    <li><strong>ADVANCED.md</strong> - Advanced features & automation</li>
                    <li><strong>config.ini</strong> - Configuration file</li>
                </ul>
            </div>
        </div>

        <div class="footer">
            <p><strong>Image Compressor v1.0</strong></p>
            <p>Simple • Fast • Reliable</p>
        </div>
    </div>
</body>
</html>
"@

Set-Content -Path (Join-Path $OutputDir "START_HERE.html") -Value $htmlGuide
Write-Host "   ✓ START_HERE.html" -ForegroundColor Gray

# Create README file for package
$packageReadme = @"
# Image Compressor - Package Contents

This package contains everything you need to compress images quickly and easily.

## 📦 What's Included

- **START_HERE.html** - Open this in your browser for full guide
- **start.bat** - Double-click to run (detects Python or offers installation)
- **install.ps1** - Full installation with desktop shortcut
- **launch.bat** - Quick launch (requires Python)
- **compress_fallback.ps1** - PowerShell mode (no Python needed)
- **image_compressor_gui.py** - Main application
- **config.ini** - Configuration file
- **Documentation** - README.md, QUICKSTART.md, ADVANCED.md

## 🚀 Get Started

### Option 1: Easiest (Recommended)
Double-click **start.bat** and follow the prompts

### Option 2: Full Installation
Right-click **install.ps1** → "Run with PowerShell"

### Option 3: No Python
Right-click **compress_fallback.ps1** → "Run with PowerShell"

## 📖 Learn More

Open **START_HERE.html** in your web browser for:
- Full user guide
- Screenshots
- Troubleshooting
- Tips & tricks

## 💬 Need Help?

Read the documentation files:
- **QUICKSTART.md** - Quick reference
- **README.md** - Complete guide
- **ADVANCED.md** - Advanced features

---

**Version:** 1.0.0
**Created:** $(Get-Date -Format "yyyy-MM-dd")
"@

Set-Content -Path (Join-Path $OutputDir "PACKAGE_README.txt") -Value $packageReadme
Write-Host "   ✓ PACKAGE_README.txt" -ForegroundColor Gray

# Create ZIP if requested
if ($CreateZip) {
    Write-Host "`n📦 Creating ZIP archive..." -ForegroundColor Cyan
    $zipPath = "ImageCompressor_v1.0_$(Get-Date -Format 'yyyyMMdd').zip"
    
    Compress-Archive -Path "$OutputDir\*" -DestinationPath $zipPath -Force
    
    $zipSize = (Get-Item $zipPath).Length / 1KB
    Write-Host "✅ Created: $zipPath ($([math]::Round($zipSize, 2)) KB)" -ForegroundColor Green
}

# Summary
Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   ✅ Package Created Successfully!    ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Green

Write-Host "📁 Package location: $OutputDir" -ForegroundColor White
Write-Host "`n📋 Contents:" -ForegroundColor White
Get-ChildItem $OutputDir | ForEach-Object {
    $size = if ($_.PSIsContainer) { "DIR" } else { "$([math]::Round($_.Length / 1KB, 1)) KB" }
    Write-Host "   • $($_.Name) ($size)" -ForegroundColor Cyan
}

Write-Host "`n🎉 Package is ready for distribution!" -ForegroundColor Green
Write-Host "   Users can extract and run START_HERE.html`n" -ForegroundColor Gray

# Open package folder
$openFolder = Read-Host "Open package folder now? (Y/N)"
if ($openFolder -eq "Y" -or $openFolder -eq "y") {
    explorer $OutputDir
}
