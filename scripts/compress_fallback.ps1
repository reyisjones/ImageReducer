# Image Compressor - PowerShell Fallback
# This script provides image compression using PowerShell when Python is not available

param(
    [Parameter(Mandatory=$false)]
    [string]$InputPath,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFolder = "Reduced",
    
    [Parameter(Mandatory=$false)]
    [int]$MaxWidth = 1920,
    
    [Parameter(Mandatory=$false)]
    [int]$Quality = 85,
    
    [Parameter(Mandatory=$false)]
    [decimal]$MaxSizeMB = 1.0
)

$ErrorActionPreference = "Continue"

function Write-ColorMessage {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Show-GUI {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    # Create form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Image Compressor (PowerShell Mode)"
    $form.Size = New-Object System.Drawing.Size(600, 400)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    
    # Header
    $headerLabel = New-Object System.Windows.Forms.Label
    $headerLabel.Location = New-Object System.Drawing.Point(10, 10)
    $headerLabel.Size = New-Object System.Drawing.Size(580, 30)
    $headerLabel.Text = "🖼️  Image Compressor - PowerShell Mode"
    $headerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($headerLabel)
    
    # Info label
    $infoLabel = New-Object System.Windows.Forms.Label
    $infoLabel.Location = New-Object System.Drawing.Point(10, 50)
    $infoLabel.Size = New-Object System.Drawing.Size(580, 40)
    $infoLabel.Text = "Note: Running in PowerShell mode (limited features).`nFor full functionality, install Python and use the main application."
    $infoLabel.ForeColor = [System.Drawing.Color]::DarkOrange
    $form.Controls.Add($infoLabel)
    
    # Path selection
    $pathLabel = New-Object System.Windows.Forms.Label
    $pathLabel.Location = New-Object System.Drawing.Point(10, 100)
    $pathLabel.Size = New-Object System.Drawing.Size(100, 20)
    $pathLabel.Text = "Select Folder:"
    $form.Controls.Add($pathLabel)
    
    $pathTextBox = New-Object System.Windows.Forms.TextBox
    $pathTextBox.Location = New-Object System.Drawing.Point(10, 125)
    $pathTextBox.Size = New-Object System.Drawing.Size(470, 20)
    $form.Controls.Add($pathTextBox)
    
    $browseButton = New-Object System.Windows.Forms.Button
    $browseButton.Location = New-Object System.Drawing.Point(490, 123)
    $browseButton.Size = New-Object System.Drawing.Size(90, 25)
    $browseButton.Text = "Browse..."
    $browseButton.Add_Click({
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.Description = "Select folder containing images"
        if ($folderBrowser.ShowDialog() -eq "OK") {
            $pathTextBox.Text = $folderBrowser.SelectedPath
        }
    })
    $form.Controls.Add($browseButton)
    
    # Max width
    $widthLabel = New-Object System.Windows.Forms.Label
    $widthLabel.Location = New-Object System.Drawing.Point(10, 165)
    $widthLabel.Size = New-Object System.Drawing.Size(150, 20)
    $widthLabel.Text = "Max Width (pixels):"
    $form.Controls.Add($widthLabel)
    
    $widthTextBox = New-Object System.Windows.Forms.TextBox
    $widthTextBox.Location = New-Object System.Drawing.Point(160, 165)
    $widthTextBox.Size = New-Object System.Drawing.Size(100, 20)
    $widthTextBox.Text = "1920"
    $form.Controls.Add($widthTextBox)
    
    # Output folder
    $outputLabel = New-Object System.Windows.Forms.Label
    $outputLabel.Location = New-Object System.Drawing.Point(10, 200)
    $outputLabel.Size = New-Object System.Drawing.Size(150, 20)
    $outputLabel.Text = "Output Folder Name:"
    $form.Controls.Add($outputLabel)
    
    $outputTextBox = New-Object System.Windows.Forms.TextBox
    $outputTextBox.Location = New-Object System.Drawing.Point(160, 200)
    $outputTextBox.Size = New-Object System.Drawing.Size(100, 20)
    $outputTextBox.Text = "Reduced"
    $form.Controls.Add($outputTextBox)
    
    # Progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 280)
    $progressBar.Size = New-Object System.Drawing.Size(570, 23)
    $form.Controls.Add($progressBar)
    
    # Status label
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Location = New-Object System.Drawing.Point(10, 310)
    $statusLabel.Size = New-Object System.Drawing.Size(570, 20)
    $statusLabel.Text = "Ready"
    $form.Controls.Add($statusLabel)
    
    # Compress button
    $compressButton = New-Object System.Windows.Forms.Button
    $compressButton.Location = New-Object System.Drawing.Point(10, 240)
    $compressButton.Size = New-Object System.Drawing.Size(570, 30)
    $compressButton.Text = "🚀 Start Compression"
    $compressButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $compressButton.BackColor = [System.Drawing.Color]::FromArgb(46, 204, 113)
    $compressButton.ForeColor = [System.Drawing.Color]::White
    $compressButton.FlatStyle = "Flat"
    $compressButton.Add_Click({
        $inputPath = $pathTextBox.Text
        $outputFolder = $outputTextBox.Text
        $maxWidth = [int]$widthTextBox.Text
        
        if ([string]::IsNullOrWhiteSpace($inputPath) -or -not (Test-Path $inputPath)) {
            [System.Windows.Forms.MessageBox]::Show("Please select a valid folder.", "Error", "OK", "Error")
            return
        }
        
        $compressButton.Enabled = $false
        $statusLabel.Text = "Processing..."
        $form.Refresh()
        
        try {
            Compress-ImagesFolder -InputPath $inputPath -OutputFolder $outputFolder -MaxWidth $maxWidth -ProgressBar $progressBar -StatusLabel $statusLabel -Form $form
            [System.Windows.Forms.MessageBox]::Show("Compression completed successfully!", "Success", "OK", "Information")
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error: $_", "Error", "OK", "Error")
        } finally {
            $compressButton.Enabled = $true
            $statusLabel.Text = "Ready"
        }
    })
    $form.Controls.Add($compressButton)
    
    # Show form
    $form.ShowDialog() | Out-Null
}

function Compress-ImagesFolder {
    param(
        [string]$InputPath,
        [string]$OutputFolder,
        [int]$MaxWidth,
        [object]$ProgressBar,
        [object]$StatusLabel,
        [object]$Form
    )
    
    # Create output directory
    $outputPath = Join-Path $InputPath $OutputFolder
    if (-not (Test-Path $outputPath)) {
        New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
    }
    
    # Load System.Drawing assembly
    Add-Type -AssemblyName System.Drawing
    
    # Get all image files
    $imageFiles = Get-ChildItem -Path $InputPath -Include *.jpg,*.jpeg,*.png,*.JPG,*.JPEG,*.PNG -File -Recurse | 
                  Where-Object { $_.DirectoryName -notmatch [regex]::Escape($OutputFolder) }
    
    if ($imageFiles.Count -eq 0) {
        throw "No image files found in the selected folder."
    }
    
    $total = $imageFiles.Count
    $processed = 0
    
    foreach ($file in $imageFiles) {
        try {
            $processed++
            $percent = [int](($processed / $total) * 100)
            
            if ($ProgressBar) {
                $ProgressBar.Value = $percent
            }
            if ($StatusLabel) {
                $StatusLabel.Text = "Processing $processed of $total : $($file.Name)"
            }
            if ($Form) {
                $Form.Refresh()
            }
            
            # Load image
            $img = [System.Drawing.Image]::FromFile($file.FullName)
            
            # Calculate new size
            $newWidth = $MaxWidth
            $newHeight = $MaxWidth
            
            if ($img.Width -gt $MaxWidth -or $img.Height -gt $MaxWidth) {
                if ($img.Width -gt $img.Height) {
                    $newWidth = $MaxWidth
                    $newHeight = [int]($img.Height * ($MaxWidth / $img.Width))
                } else {
                    $newHeight = $MaxWidth
                    $newWidth = [int]($img.Width * ($MaxWidth / $img.Height))
                }
                
                # Create new bitmap
                $bitmap = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
                $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.DrawImage($img, 0, 0, $newWidth, $newHeight)
                
                # Save
                $outputFile = Join-Path $outputPath $file.Name
                $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
                $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
                    [System.Drawing.Imaging.Encoder]::Quality, 
                    [long]85
                )
                
                $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | 
                             Where-Object { $_.MimeType -eq 'image/jpeg' } | 
                             Select-Object -First 1
                
                $bitmap.Save($outputFile, $jpegCodec, $encoderParams)
                
                # Cleanup
                $graphics.Dispose()
                $bitmap.Dispose()
            } else {
                # Copy as-is if smaller than max
                Copy-Item $file.FullName (Join-Path $outputPath $file.Name) -Force
            }
            
            $img.Dispose()
            
        } catch {
            Write-ColorMessage "❌ Error processing $($file.Name): $_" Red
        }
    }
}

# Main execution
if ([string]::IsNullOrWhiteSpace($InputPath)) {
    # Show GUI
    Show-GUI
} else {
    # Run from command line
    Write-ColorMessage "`n🖼️  Image Compressor - PowerShell Mode`n" Cyan
    
    if (-not (Test-Path $InputPath)) {
        Write-ColorMessage "❌ Error: Input path does not exist: $InputPath" Red
        exit 1
    }
    
    try {
        Compress-ImagesFolder -InputPath $InputPath -OutputFolder $OutputFolder -MaxWidth $MaxWidth
        Write-ColorMessage "`n✅ Compression completed successfully!" Green
        Write-ColorMessage "📁 Output folder: $(Join-Path $InputPath $OutputFolder)`n" Cyan
    } catch {
        Write-ColorMessage "`n❌ Error: $_`n" Red
        exit 1
    }
}
