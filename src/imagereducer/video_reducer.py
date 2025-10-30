"""
Video Reducer Module

Provides video compression functionality using FFmpeg.
Supports MP4, MOV, and MPEG formats with configurable quality settings.
"""

import os
import logging
import shutil
from pathlib import Path
from typing import Optional, Tuple
import ffmpeg

# Set up logging
logger = logging.getLogger(__name__)


def check_ffmpeg_installed() -> bool:
    """
    Check if FFmpeg is installed and available in system PATH.
    
    Returns:
        True if FFmpeg is available, False otherwise
    """
    return shutil.which('ffmpeg') is not None


class VideoReducer:
    """
    A class to handle video compression using FFmpeg.
    
    Attributes:
        crf (int): Constant Rate Factor for quality (0-51, lower is better quality)
        preset (str): Encoding speed preset
        supported_formats (tuple): Supported video file extensions
    """
    
    def __init__(self, crf: int = 28, preset: str = "medium"):
        """
        Initialize VideoReducer with compression settings.
        
        Args:
            crf: Quality setting (0-51, default 28). Lower = better quality, larger file
            preset: Speed preset (ultrafast, superfast, veryfast, faster, fast, 
                   medium, slow, slower, veryslow). Default is 'medium'
        """
        self.crf = crf
        self.preset = preset
        self.supported_formats = ('.mp4', '.mov', '.mpeg', '.avi', '.mkv')
        
    def is_supported(self, file_path: str) -> bool:
        """
        Check if the file format is supported.
        
        Args:
            file_path: Path to the video file
            
        Returns:
            True if the file format is supported, False otherwise
        """
        return Path(file_path).suffix.lower() in self.supported_formats
    
    def get_file_size(self, file_path: str) -> int:
        """
        Get file size in bytes.
        
        Args:
            file_path: Path to the file
            
        Returns:
            File size in bytes
        """
        return os.path.getsize(file_path)
    
    def compress(
        self, 
        input_path: str, 
        output_path: str, 
        resolution: Optional[Tuple[int, int]] = None,
        crf: Optional[int] = None,
        preset: Optional[str] = None
    ) -> dict:
        """
        Compress a video file.
        
        Args:
            input_path: Path to input video file
            output_path: Path to output video file
            resolution: Optional tuple (width, height) to resize video
            crf: Override default CRF value
            preset: Override default preset value
            
        Returns:
            Dictionary with compression results including:
                - success: bool
                - input_size: int (bytes)
                - output_size: int (bytes)
                - reduction_percent: float
                - error: str (if failed)
        """
        result = {
            'success': False,
            'input_size': 0,
            'output_size': 0,
            'reduction_percent': 0.0,
            'error': None
        }
        
        try:
            # Validate input file
            if not os.path.exists(input_path):
                result['error'] = f"Input file not found: {input_path}"
                logger.error(result['error'])
                return result
            
            if not self.is_supported(input_path):
                result['error'] = f"Unsupported file format. Supported: {self.supported_formats}"
                logger.error(result['error'])
                return result
            
            # Get input file size
            input_size = self.get_file_size(input_path)
            result['input_size'] = input_size
            
            # Create output directory if needed
            output_dir = os.path.dirname(output_path)
            if output_dir and not os.path.exists(output_dir):
                os.makedirs(output_dir, exist_ok=True)
            
            # Use provided or default settings
            crf_value = crf if crf is not None else self.crf
            preset_value = preset if preset is not None else self.preset
            
            # Build FFmpeg stream
            logger.info(f"Compressing video: {input_path}")
            logger.info(f"Settings - CRF: {crf_value}, Preset: {preset_value}")
            
            stream = ffmpeg.input(input_path)
            
            # Apply resolution filter if specified
            if resolution:
                width, height = resolution
                logger.info(f"Resizing to: {width}x{height}")
                stream = stream.filter('scale', width, height)
            
            # Ensure output is MP4 format for compatibility
            # Extract audio stream to handle transcoding
            video = stream['v']
            audio = stream['a']
            
            # Output with compression settings
            # Use explicit format specification and handle audio properly
            output_file = ffmpeg.output(
                video,
                audio,
                output_path,
                vcodec='libx264',
                crf=crf_value,
                preset=preset_value,
                acodec='aac',
                audio_bitrate='128k',
                f='mp4'  # Explicitly set output format to MP4
            )
            stream = output_file
            
            # Run FFmpeg (overwrite output file if exists)
            ffmpeg.run(stream, overwrite_output=True, capture_stdout=True, capture_stderr=True)
            
            # Get output file size
            if os.path.exists(output_path):
                output_size = self.get_file_size(output_path)
                result['output_size'] = output_size
                
                # Calculate reduction
                if input_size > 0:
                    reduction = ((input_size - output_size) / input_size) * 100
                    result['reduction_percent'] = round(reduction, 2)
                
                result['success'] = True
                logger.info(f"Compression complete!")
                logger.info(f"Input size: {input_size / (1024*1024):.2f} MB")
                logger.info(f"Output size: {output_size / (1024*1024):.2f} MB")
                logger.info(f"Reduction: {result['reduction_percent']:.2f}%")
            else:
                result['error'] = "Output file was not created"
                logger.error(result['error'])
                
        except ffmpeg.Error as e:
            error_msg = e.stderr.decode('utf-8') if e.stderr else str(e)
            result['error'] = f"FFmpeg error: {error_msg}"
            logger.error(result['error'])
        except FileNotFoundError as e:
            # FFmpeg binary not found in system PATH
            result['error'] = "FFmpeg not found. Please install FFmpeg and add it to your system PATH. Download from: https://ffmpeg.org/download.html"
            logger.error(result['error'])
        except Exception as e:
            result['error'] = f"Unexpected error: {str(e)}"
            logger.error(result['error'])
        
        return result


def compress_video(
    input_file: str,
    output_file: str,
    crf: int = 28,
    preset: str = "medium",
    resolution: Optional[Tuple[int, int]] = None
) -> dict:
    """
    Convenience function to compress a video file.
    
    Args:
        input_file: Path to input video file
        output_file: Path to output video file
        crf: Constant Rate Factor (0-51, default 28). Lower = better quality
        preset: Encoding speed preset (default 'medium')
        resolution: Optional tuple (width, height) to resize video
        
    Returns:
        Dictionary with compression results
        
    Example:
        >>> result = compress_video("input.mp4", "output.mp4", crf=26, preset="slow")
        >>> if result['success']:
        ...     print(f"Reduced by {result['reduction_percent']}%")
    """
    reducer = VideoReducer(crf=crf, preset=preset)
    return reducer.compress(input_file, output_file, resolution=resolution)
