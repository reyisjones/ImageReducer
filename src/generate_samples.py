# Sample Images Generator
# Creates sample JPG and PNG files for testing the compression application

from PIL import Image, ImageDraw, ImageFont
import os
from pathlib import Path

def create_sample_images():
    """Generate sample images for testing"""
    
    sample_dir = Path(__file__).parent / "sample_images"
    sample_dir.mkdir(exist_ok=True)
    
    print("🎨 Generating sample images...\n")
    
    # Sample 1: Large JPG (Landscape photo simulation)
    img1 = Image.new('RGB', (3000, 2000), color='#3498db')
    draw1 = ImageDraw.Draw(img1)
    
    # Add gradient effect
    for i in range(2000):
        color = int(52 + (i/2000 * 100))
        draw1.rectangle([(0, i), (3000, i+1)], fill=(color, 152, 219))
    
    # Add text
    try:
        font = ImageFont.truetype("arial.ttf", 120)
    except:
        font = ImageFont.load_default()
    
    draw1.text((1500, 1000), "Sample JPG Image", fill='white', anchor='mm', font=font)
    draw1.text((1500, 1150), "3000x2000 - High Resolution", fill='white', anchor='mm', font=font)
    
    img1.save(sample_dir / "sample_landscape.jpg", "JPEG", quality=95)
    size1 = (sample_dir / "sample_landscape.jpg").stat().st_size / 1024 / 1024
    print(f"✅ Created: sample_landscape.jpg ({size1:.2f} MB)")
    
    # Sample 2: Large PNG (Portrait with transparency)
    img2 = Image.new('RGBA', (2000, 3000), color=(231, 76, 60, 255))
    draw2 = ImageDraw.Draw(img2)
    
    # Add circles
    for i in range(10):
        x = 200 + (i * 180)
        y = 300 + (i * 250)
        draw2.ellipse([(x, y), (x+300, y+300)], fill=(255, 255, 255, 150))
    
    # Add text
    draw2.text((1000, 1500), "Sample PNG Image", fill='white', anchor='mm', font=font)
    draw2.text((1000, 1650), "2000x3000 - With Transparency", fill='white', anchor='mm', font=font)
    
    img2.save(sample_dir / "sample_portrait.png", "PNG")
    size2 = (sample_dir / "sample_portrait.png").stat().st_size / 1024 / 1024
    print(f"✅ Created: sample_portrait.png ({size2:.2f} MB)")
    
    # Sample 3: Medium JPG (Square)
    img3 = Image.new('RGB', (2500, 2500), color='#2ecc71')
    draw3 = ImageDraw.Draw(img3)
    
    # Add pattern
    for x in range(0, 2500, 100):
        draw3.rectangle([(x, 0), (x+50, 2500)], fill='#27ae60')
    
    for y in range(0, 2500, 100):
        draw3.rectangle([(0, y), (2500, y+50)], fill='#27ae60')
    
    draw3.text((1250, 1250), "Sample Square", fill='white', anchor='mm', font=font)
    draw3.text((1250, 1400), "2500x2500", fill='white', anchor='mm', font=font)
    
    img3.save(sample_dir / "sample_square.jpg", "JPEG", quality=90)
    size3 = (sample_dir / "sample_square.jpg").stat().st_size / 1024 / 1024
    print(f"✅ Created: sample_square.jpg ({size3:.2f} MB)")
    
    # Sample 4: Small PNG (Icon-like)
    img4 = Image.new('RGBA', (1500, 1500), color=(241, 196, 15, 255))
    draw4 = ImageDraw.Draw(img4)
    
    # Add star shape
    points = []
    for i in range(5):
        angle = (i * 144 - 90) * 3.14159 / 180
        x = 750 + 500 * cos(angle)
        y = 750 + 500 * sin(angle)
        points.append((x, y))
    
    draw4.polygon(points, fill=(243, 156, 18, 255), outline='white')
    draw4.text((750, 750), "Small PNG", fill='white', anchor='mm', font=font)
    
    img4.save(sample_dir / "sample_small.png", "PNG")
    size4 = (sample_dir / "sample_small.png").stat().st_size / 1024 / 1024
    print(f"✅ Created: sample_small.png ({size4:.2f} MB)")
    
    # Sample 5: Very large JPG (Panorama)
    img5 = Image.new('RGB', (4000, 1500), color='#9b59b6')
    draw5 = ImageDraw.Draw(img5)
    
    # Add gradient
    for i in range(4000):
        color = int(155 + (i/4000 * 100))
        draw5.rectangle([(i, 0), (i+1, 1500)], fill=(color, 89, 182))
    
    draw5.text((2000, 750), "Sample Panorama - 4000x1500", fill='white', anchor='mm', font=font)
    
    img5.save(sample_dir / "sample_panorama.jpg", "JPEG", quality=92)
    size5 = (sample_dir / "sample_panorama.jpg").stat().st_size / 1024 / 1024
    print(f"✅ Created: sample_panorama.jpg ({size5:.2f} MB)")
    
    # Create README for samples
    readme_content = """# Sample Images

This folder contains sample images for testing the Image Compressor application.

## Files

1. **sample_landscape.jpg** - 3000x2000 high resolution landscape
2. **sample_portrait.png** - 2000x3000 portrait with transparency
3. **sample_square.jpg** - 2500x2500 square format
4. **sample_small.png** - 1500x1500 smaller image
5. **sample_panorama.jpg** - 4000x1500 wide panorama

## Usage

These images are automatically used by the "Run Demo" feature in the application.

You can also manually select this folder to test compression:
1. Launch Image Compressor
2. Click "Browse Folder"
3. Select this "sample_images" folder
4. Click "Start Compression"

## Expected Results

All images should compress to < 1 MB while maintaining good visual quality.

Typical compression ratios: 60-85% size reduction.
"""
    
    with open(sample_dir / "README.md", "w") as f:
        f.write(readme_content)
    
    print(f"\n✅ Created: README.md")
    
    total_size = sum(f.stat().st_size for f in sample_dir.glob("*.jpg") if f.is_file())
    total_size += sum(f.stat().st_size for f in sample_dir.glob("*.png") if f.is_file())
    total_mb = total_size / 1024 / 1024
    
    print(f"\n📊 Total sample images size: {total_mb:.2f} MB")
    print(f"📁 Location: {sample_dir}")
    print(f"🎉 Sample images ready for testing!")

# Helper functions
def cos(angle):
    import math
    return math.cos(angle)

def sin(angle):
    import math
    return math.sin(angle)

if __name__ == "__main__":
    create_sample_images()
