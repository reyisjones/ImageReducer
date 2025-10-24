"""Create a demo PNG with transparency for testing"""
from PIL import Image, ImageDraw
import os

# Create image with transparent background
img = Image.new('RGBA', (800, 600), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Draw red vertical stripes with transparency
for i in range(0, 800, 100):
    draw.rectangle([i, 0, i+50, 600], fill=(255, 0, 0, 200))

# Draw blue horizontal stripes with transparency
for i in range(0, 600, 100):
    draw.rectangle([0, i, 800, i+50], fill=(0, 0, 255, 150))

# Draw a semi-transparent green circle
draw.ellipse([200, 150, 600, 450], fill=(0, 255, 0, 180), outline=(255, 255, 0, 255), width=10)

# Save
output_path = 'sample_images/transparency_demo.png'
img.save(output_path, 'PNG')
print(f'✅ Created: {output_path}')
print(f'📊 Size: {os.path.getsize(output_path) / (1024*1024):.2f} MB')
print(f'🎨 Mode: {img.mode}')
print('\nNow you can use this file to test the transparency preservation feature!')
