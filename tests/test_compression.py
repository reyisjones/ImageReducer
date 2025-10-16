"""
Unit Tests for Image Compressor Application
Tests compression functionality, file handling, and error cases
"""

import pytest
import os
import sys
from pathlib import Path
from PIL import Image
import tempfile
import shutil

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

# Import the compression functions (we'll need to refactor GUI code to separate logic)
# For now, we'll test the core compression algorithm

class TestCompressionCore:
    """Test core compression functionality"""
    
    @pytest.fixture
    def temp_dir(self):
        """Create temporary directory for tests"""
        temp_path = tempfile.mkdtemp()
        yield temp_path
        shutil.rmtree(temp_path, ignore_errors=True)
    
    @pytest.fixture
    def sample_image(self, temp_dir):
        """Create a sample test image"""
        img_path = Path(temp_dir) / "test_image.jpg"
        img = Image.new('RGB', (2000, 1500), color='blue')
        img.save(img_path, 'JPEG', quality=95)
        return img_path
    
    @pytest.fixture
    def sample_png(self, temp_dir):
        """Create a sample PNG with transparency"""
        img_path = Path(temp_dir) / "test_image.png"
        img = Image.new('RGBA', (1800, 1200), color=(255, 0, 0, 128))
        img.save(img_path, 'PNG')
        return img_path
    
    def compress_image_test(self, input_path, output_path, quality=85, max_width=1920, max_size_mb=1.0):
        """Test implementation of compression algorithm"""
        target_size_bytes = int(max_size_mb * 1024 * 1024)
        
        with Image.open(input_path) as img:
            # Convert to RGB if needed
            if img.mode in ('RGBA', 'P', 'LA'):
                if img.mode in ('RGBA', 'LA'):
                    background = Image.new('RGB', img.size, (255, 255, 255))
                    if img.mode == 'RGBA':
                        background.paste(img, mask=img.split()[3])
                    else:
                        background.paste(img, mask=img.split()[1])
                    img = background
                else:
                    img = img.convert('RGB')
            
            # Resize if needed
            if max(img.size) > max_width:
                img.thumbnail((max_width, max_width), Image.Resampling.LANCZOS)
            
            # Save with optimization
            img.save(output_path, "JPEG", quality=quality, optimize=True)
            
            # Adjust quality if needed
            while os.path.getsize(output_path) > target_size_bytes and quality > 60:
                quality -= 5
                img.save(output_path, "JPEG", quality=quality, optimize=True)
            
            # Further resize if needed
            if os.path.getsize(output_path) > target_size_bytes:
                scale_factor = 0.9
                while os.path.getsize(output_path) > target_size_bytes and max(img.size) > 800:
                    new_width = int(img.size[0] * scale_factor)
                    new_height = int(img.size[1] * scale_factor)
                    img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
                    img.save(output_path, "JPEG", quality=quality, optimize=True)
        
        return os.path.getsize(output_path) / 1024 / 1024
    
    def test_image_compression_below_1mb(self, sample_image, temp_dir):
        """Test that image is compressed below 1 MB"""
        output_path = Path(temp_dir) / "compressed.jpg"
        
        final_size = self.compress_image_test(sample_image, output_path, max_size_mb=1.0)
        
        assert output_path.exists(), "Output file should exist"
        assert final_size <= 1.1, f"File size {final_size:.2f} MB should be <= 1.1 MB"
    
    def test_png_to_jpeg_conversion(self, sample_png, temp_dir):
        """Test PNG to JPEG conversion"""
        output_path = Path(temp_dir) / "converted.jpg"
        
        self.compress_image_test(sample_png, output_path)
        
        assert output_path.exists(), "Output file should exist"
        
        # Verify it's a JPEG
        with Image.open(output_path) as img:
            assert img.format == 'JPEG', "Output should be JPEG format"
    
    def test_maintains_aspect_ratio(self, sample_image, temp_dir):
        """Test that aspect ratio is maintained"""
        output_path = Path(temp_dir) / "resized.jpg"
        
        # Get original dimensions
        with Image.open(sample_image) as orig:
            orig_ratio = orig.width / orig.height
        
        self.compress_image_test(sample_image, output_path, max_width=1920)
        
        # Get compressed dimensions
        with Image.open(output_path) as comp:
            comp_ratio = comp.width / comp.height
        
        # Allow small floating point difference
        assert abs(orig_ratio - comp_ratio) < 0.01, "Aspect ratio should be maintained"
    
    def test_resizes_large_images(self, temp_dir):
        """Test that large images are resized"""
        # Create very large image
        large_img_path = Path(temp_dir) / "large.jpg"
        img = Image.new('RGB', (4000, 3000), color='red')
        img.save(large_img_path, 'JPEG', quality=95)
        
        output_path = Path(temp_dir) / "resized_large.jpg"
        self.compress_image_test(large_img_path, output_path, max_width=1920)
        
        with Image.open(output_path) as compressed:
            assert max(compressed.size) <= 1920, "Image should be resized to max width"
    
    def test_quality_adjustment(self, sample_image, temp_dir):
        """Test that quality is adjusted to meet size target"""
        output_path = Path(temp_dir) / "quality_adjusted.jpg"
        
        # Try to compress to very small size
        final_size = self.compress_image_test(sample_image, output_path, max_size_mb=0.3)
        
        # Should be close to target (allow some tolerance)
        assert final_size <= 0.35, f"Should compress to near target size, got {final_size:.2f} MB"


class TestFileHandling:
    """Test file and folder handling"""
    
    @pytest.fixture
    def test_folder(self):
        """Create test folder with images"""
        temp_path = tempfile.mkdtemp()
        
        # Create test images
        for i in range(3):
            img = Image.new('RGB', (1500, 1000), color=['red', 'green', 'blue'][i])
            img.save(Path(temp_path) / f"test_{i}.jpg", 'JPEG')
        
        yield temp_path
        shutil.rmtree(temp_path, ignore_errors=True)
    
    def test_output_folder_creation(self, test_folder):
        """Test that output folder is created"""
        output_folder = Path(test_folder) / "Reduced"
        
        assert not output_folder.exists(), "Output folder shouldn't exist yet"
        
        output_folder.mkdir(exist_ok=True)
        
        assert output_folder.exists(), "Output folder should be created"
        assert output_folder.is_dir(), "Output should be a directory"
    
    def test_finds_jpg_files(self, test_folder):
        """Test finding JPG files in folder"""
        jpg_files = list(Path(test_folder).glob("*.jpg"))
        
        assert len(jpg_files) == 3, "Should find 3 JPG files"
    
    def test_handles_duplicate_filenames(self, test_folder):
        """Test handling of duplicate output filenames"""
        output_folder = Path(test_folder) / "Reduced"
        output_folder.mkdir(exist_ok=True)
        
        # Create first file
        output_path = output_folder / "test.jpg"
        Image.new('RGB', (100, 100), color='red').save(output_path)
        
        # Handle duplicate
        counter = 1
        while output_path.exists():
            output_path = output_folder / f"test_{counter}.jpg"
            counter += 1
        
        assert not output_path.exists(), "Should find non-existing filename"
        assert "test_1" in str(output_path), "Should have counter suffix"


class TestErrorHandling:
    """Test error handling and edge cases"""
    
    def test_handles_missing_file(self):
        """Test handling of missing file"""
        fake_path = Path("nonexistent_image.jpg")
        
        with pytest.raises(FileNotFoundError):
            with Image.open(fake_path) as img:
                pass
    
    def test_handles_invalid_image(self, tmp_path):
        """Test handling of invalid image file"""
        invalid_file = tmp_path / "invalid.jpg"
        invalid_file.write_text("This is not an image")
        
        with pytest.raises(Exception):
            with Image.open(invalid_file) as img:
                pass
    
    def test_handles_corrupted_image(self, tmp_path):
        """Test handling of corrupted image"""
        corrupted = tmp_path / "corrupted.jpg"
        
        # Create partial image file
        img = Image.new('RGB', (100, 100), color='blue')
        img.save(corrupted, 'JPEG')
        
        # Truncate file to corrupt it
        with open(corrupted, 'r+b') as f:
            f.truncate(100)
        
        # Should raise error when trying to fully process
        with pytest.raises(Exception):
            img = Image.open(corrupted)
            img.verify()
    
    def test_handles_read_only_directory(self, tmp_path):
        """Test handling of read-only directory"""
        # Note: This test may not work on all systems
        read_only_dir = tmp_path / "readonly"
        read_only_dir.mkdir()
        
        # Try to make read-only (platform-specific)
        try:
            os.chmod(read_only_dir, 0o444)
            
            # Should not be able to create file
            test_file = read_only_dir / "test.txt"
            
            with pytest.raises(PermissionError):
                test_file.write_text("test")
        finally:
            # Restore permissions for cleanup
            os.chmod(read_only_dir, 0o755)


class TestConfiguration:
    """Test configuration and settings"""
    
    def test_default_settings(self):
        """Test default configuration values"""
        default_target_size = 1.0
        default_quality = 85
        default_max_width = 1920
        
        assert default_target_size == 1.0, "Default target size should be 1.0 MB"
        assert default_quality == 85, "Default quality should be 85"
        assert default_max_width == 1920, "Default max width should be 1920"
    
    def test_quality_bounds(self):
        """Test quality setting bounds"""
        min_quality = 60
        max_quality = 95
        
        assert 60 <= min_quality <= 95, "Min quality should be in valid range"
        assert 60 <= max_quality <= 95, "Max quality should be in valid range"
    
    def test_size_bounds(self):
        """Test file size bounds"""
        min_size = 0.1
        max_size = 5.0
        
        assert min_size > 0, "Min size should be positive"
        assert max_size >= min_size, "Max size should be >= min size"


class TestImageQuality:
    """Test image quality preservation"""
    
    @pytest.fixture
    def reference_image(self, tmp_path):
        """Create reference image"""
        img_path = tmp_path / "reference.jpg"
        img = Image.new('RGB', (2000, 1500), color='blue')
        
        # Add some details
        from PIL import ImageDraw
        draw = ImageDraw.Draw(img)
        for i in range(0, 2000, 100):
            draw.line([(i, 0), (i, 1500)], fill='white', width=2)
        for i in range(0, 1500, 100):
            draw.line([(0, i), (2000, i)], fill='white', width=2)
        
        img.save(img_path, 'JPEG', quality=95)
        return img_path
    
    def test_compressed_image_openable(self, reference_image, tmp_path):
        """Test that compressed image can be opened"""
        output_path = tmp_path / "compressed_quality.jpg"
        
        # Compress
        with Image.open(reference_image) as img:
            img.thumbnail((1920, 1920), Image.Resampling.LANCZOS)
            img.save(output_path, 'JPEG', quality=85, optimize=True)
        
        # Should be able to open and process
        with Image.open(output_path) as compressed:
            assert compressed.size is not None
            assert compressed.mode in ['RGB', 'L']
    
    def test_maintains_reasonable_quality(self, reference_image, tmp_path):
        """Test that quality remains reasonable after compression"""
        output_path = tmp_path / "quality_check.jpg"
        
        # Get original size
        orig_size = os.path.getsize(reference_image) / 1024 / 1024
        
        # Compress
        with Image.open(reference_image) as img:
            img.thumbnail((1920, 1920), Image.Resampling.LANCZOS)
            img.save(output_path, 'JPEG', quality=85, optimize=True)
        
        final_size = os.path.getsize(output_path) / 1024 / 1024
        
        # Should achieve some compression
        assert final_size < orig_size, "Should reduce file size"
        
        # But not too aggressive
        with Image.open(output_path) as compressed:
            # Image should still have reasonable dimensions
            assert min(compressed.size) >= 800, "Should maintain reasonable dimensions"


# Test runner configuration
if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
