$source = ".\images"
$dest = ".\compressed"

if (!(Test-Path $dest)) {
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
}

Add-Type -AssemblyName System.Drawing

Get-ChildItem $source -Filter *.jpg | ForEach-Object {
    $img = [System.Drawing.Image]::FromFile($_.FullName)
    $width = 1920
    if ($img.Width -gt $width) {
        $height = [int]($img.Height * ($width / $img.Width))
        $thumb = New-Object System.Drawing.Bitmap $width, $height
        $graphics = [System.Drawing.Graphics]::FromImage($thumb)
        $graphics.DrawImage($img, 0, 0, $width, $height)
        $output = Join-Path $dest $_.Name
        $thumb.Save($output, [System.Drawing.Imaging.ImageFormat]::Jpeg)
        $graphics.Dispose()
        $thumb.Dispose()
    } else {
        Copy-Item $_.FullName $dest
    }
    $img.Dispose()
    Write-Host "✔️ Procesado: $($_.Name)"
}

Write-Host "✅ Compresión completada"
