"""
Unit tests for video_reducer module

Tests the VideoReducer class and compress_video function.
"""

import os
import sys
import pytest
import tempfile
from pathlib import Path

# Add src directory to path
src_dir = Path(__file__).parent.parent
sys.path.insert(0, str(src_dir))

from imagereducer.video_reducer import VideoReducer, compress_video


class TestVideoReducer:
    """Test cases for VideoReducer class"""
    
    def test_init_default_values(self):
        """Test VideoReducer initialization with default values"""
        reducer = VideoReducer()
        assert reducer.crf == 28
        assert reducer.preset == "medium"
        assert reducer.supported_formats == ('.mp4', '.mov', '.mpeg', '.avi', '.mkv')
    
    def test_init_custom_values(self):
        """Test VideoReducer initialization with custom values"""
        reducer = VideoReducer(crf=24, preset="slow")
        assert reducer.crf == 24
        assert reducer.preset == "slow"
    
    def test_is_supported_valid_formats(self):
        """Test is_supported with valid video formats"""
        reducer = VideoReducer()
        assert reducer.is_supported("video.mp4") is True
        assert reducer.is_supported("video.MP4") is True
        assert reducer.is_supported("video.mov") is True
        assert reducer.is_supported("video.mpeg") is True
        assert reducer.is_supported("video.avi") is True
        assert reducer.is_supported("video.mkv") is True
    
    def test_is_supported_invalid_formats(self):
        """Test is_supported with invalid formats"""
        reducer = VideoReducer()
        assert reducer.is_supported("image.jpg") is False
        assert reducer.is_supported("document.pdf") is False
        assert reducer.is_supported("audio.mp3") is False
    
    def test_compress_nonexistent_file(self):
        """Test compression with non-existent input file"""
        reducer = VideoReducer()
        result = reducer.compress("nonexistent.mp4", "output.mp4")
        
        assert result['success'] is False
        assert 'not found' in result['error'].lower()
        assert result['input_size'] == 0
        assert result['output_size'] == 0
    
    def test_compress_unsupported_format(self):
        """Test compression with unsupported file format"""
        reducer = VideoReducer()
        
        # Create a temporary file with unsupported extension
        with tempfile.NamedTemporaryFile(suffix='.txt', delete=False) as tmp:
            tmp.write(b"test content")
            tmp_path = tmp.name
        
        try:
            result = reducer.compress(tmp_path, "output.mp4")
            assert result['success'] is False
            assert 'unsupported' in result['error'].lower()
        finally:
            os.unlink(tmp_path)
    
    @pytest.mark.skipif(
        not os.path.exists("sample_videos/sample_960x400_ocean_with_audio.mpeg"),
        reason="Sample video not found"
    )
    def test_compress_real_video(self):
        """Test compression with a real video file (if available)"""
        reducer = VideoReducer(crf=28, preset="ultrafast")  # Use ultrafast for speed
        
        input_file = "sample_videos/sample_960x400_ocean_with_audio.mpeg"
        
        with tempfile.TemporaryDirectory() as tmp_dir:
            output_file = os.path.join(tmp_dir, "compressed.mp4")
            
            result = reducer.compress(input_file, output_file)
            
            # Check result structure
            assert 'success' in result
            assert 'input_size' in result
            assert 'output_size' in result
            assert 'reduction_percent' in result
            
            # If compression succeeded, verify output
            if result['success']:
                assert result['input_size'] > 0
                assert result['output_size'] > 0
                assert os.path.exists(output_file)
                assert os.path.getsize(output_file) > 0
    
    @pytest.mark.skipif(
        not os.path.exists("sample_videos/sample_960x400_ocean_with_audio.mpeg"),
        reason="Sample video not found"
    )
    def test_compress_with_resolution(self):
        """Test compression with resolution scaling"""
        reducer = VideoReducer(crf=28, preset="ultrafast")
        
        input_file = "sample_videos/sample_960x400_ocean_with_audio.mpeg"
        
        with tempfile.TemporaryDirectory() as tmp_dir:
            output_file = os.path.join(tmp_dir, "resized.mp4")
            
            # Resize to 640x360
            result = reducer.compress(
                input_file, 
                output_file, 
                resolution=(640, 360)
            )
            
            if result['success']:
                assert os.path.exists(output_file)
                assert os.path.getsize(output_file) > 0
    
    def test_get_file_size(self):
        """Test get_file_size method"""
        reducer = VideoReducer()
        
        # Create a temporary file with known size
        with tempfile.NamedTemporaryFile(delete=False) as tmp:
            tmp.write(b"x" * 1024)  # 1KB
            tmp_path = tmp.name
        
        try:
            size = reducer.get_file_size(tmp_path)
            assert size == 1024
        finally:
            os.unlink(tmp_path)


class TestCompressVideoFunction:
    """Test cases for compress_video convenience function"""
    
    def test_compress_video_function_signature(self):
        """Test that compress_video function exists and has correct signature"""
        import inspect
        sig = inspect.signature(compress_video)
        params = list(sig.parameters.keys())
        
        assert 'input_file' in params
        assert 'output_file' in params
        assert 'crf' in params
        assert 'preset' in params
        assert 'resolution' in params
    
    def test_compress_video_nonexistent_file(self):
        """Test compress_video with non-existent file"""
        result = compress_video("nonexistent.mp4", "output.mp4")
        
        assert result['success'] is False
        assert result['error'] is not None
    
    @pytest.mark.skipif(
        not os.path.exists("sample_videos/sample_960x400_ocean_with_audio.mpeg"),
        reason="Sample video not found"
    )
    def test_compress_video_real_file(self):
        """Test compress_video function with real video"""
        input_file = "sample_videos/sample_960x400_ocean_with_audio.mpeg"
        
        with tempfile.TemporaryDirectory() as tmp_dir:
            output_file = os.path.join(tmp_dir, "output.mp4")
            
            result = compress_video(
                input_file,
                output_file,
                crf=30,
                preset="ultrafast"
            )
            
            assert 'success' in result
            assert 'input_size' in result
            assert 'output_size' in result
            
            if result['success']:
                assert os.path.exists(output_file)


if __name__ == '__main__':
    # Run tests
    pytest.main([__file__, '-v'])
