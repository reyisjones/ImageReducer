#!/usr/bin/env python3
"""
ImageReducer - Main Entry Point

Smart desktop application for intelligent image and video compression with customizable quality settings.
Supports batch processing and provides an intuitive GUI for users to compress media files efficiently.

Usage:
    python main.py                                    # Launch GUI application
    python main.py --help                             # Show help information
    python main.py --video INPUT [OPTIONS]            # Compress video via CLI
    
Video Compression Options:
    --video INPUT                                     # Input video file
    --output OUTPUT                                   # Output file or directory
    --crf CRF                                        # Quality (0-51, default 28, lower=better)
    --preset PRESET                                  # Speed preset (default 'medium')
    --resolution WIDTHxHEIGHT                        # Resize video (e.g., 1280x720)
"""

import sys
import os
import argparse
import logging
from pathlib import Path

# Add src to path if running from project root
src_dir = Path(__file__).parent
if str(src_dir) not in sys.path:
    sys.path.insert(0, str(src_dir))

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def compress_video_cli(args):
    """Handle video compression from CLI arguments"""
    try:
        from imagereducer.video_reducer import compress_video
        
        input_file = args.video
        
        # Determine output path
        if args.output:
            output_file = args.output
            # If output is a directory, create output filename
            if os.path.isdir(output_file):
                input_path = Path(input_file)
                output_file = os.path.join(
                    output_file, 
                    f"{input_path.stem}_compressed{input_path.suffix}"
                )
        else:
            # Default: add _compressed to filename
            input_path = Path(input_file)
            output_file = str(input_path.parent / f"{input_path.stem}_compressed{input_path.suffix}")
        
        # Parse resolution if provided
        resolution = None
        if args.resolution:
            try:
                width, height = args.resolution.lower().split('x')
                resolution = (int(width), int(height))
            except ValueError:
                logger.error("Invalid resolution format. Use WIDTHxHEIGHT (e.g., 1280x720)")
                return 1
        
        # Compress video
        logger.info(f"Compressing: {input_file}")
        logger.info(f"Output: {output_file}")
        
        result = compress_video(
            input_file,
            output_file,
            crf=args.crf,
            preset=args.preset,
            resolution=resolution
        )
        
        if result['success']:
            print(f"\n✅ Video compression successful!")
            print(f"Input size:  {result['input_size'] / (1024*1024):.2f} MB")
            print(f"Output size: {result['output_size'] / (1024*1024):.2f} MB")
            print(f"Reduction:   {result['reduction_percent']:.2f}%")
            print(f"Output file: {output_file}")
            return 0
        else:
            print(f"\n❌ Video compression failed: {result['error']}")
            return 1
            
    except ImportError as e:
        logger.error(f"Error importing video reducer: {e}")
        logger.error("Make sure ffmpeg-python is installed: pip install ffmpeg-python")
        logger.error("Also ensure FFmpeg is installed on your system")
        return 1
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return 1


def main():
    """Main entry point for the application"""
    
    # Parse command line arguments
    parser = argparse.ArgumentParser(
        description='ImageReducer - Compress images and videos',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Launch GUI
  python main.py
  
  # Compress video with default settings
  python main.py --video sample.mp4
  
  # Compress with custom quality and speed
  python main.py --video sample.mov --crf 26 --preset slow --output compressed/
  
  # Resize and compress
  python main.py --video sample.mpeg --resolution 1280x720 --output output.mp4
"""
    )
    
    parser.add_argument('--version', action='store_true', help='Show version information')
    parser.add_argument('--video', type=str, help='Video file to compress')
    parser.add_argument('--output', type=str, help='Output file or directory')
    parser.add_argument('--crf', type=int, default=28, help='Quality (0-51, lower=better, default=28)')
    parser.add_argument('--preset', type=str, default='medium', 
                       choices=['ultrafast', 'superfast', 'veryfast', 'faster', 'fast', 
                               'medium', 'slow', 'slower', 'veryslow'],
                       help='Encoding speed preset (default=medium)')
    parser.add_argument('--resolution', type=str, help='Resize video (e.g., 1280x720)')
    
    args = parser.parse_args()
    
    # Handle version flag
    if args.version:
        try:
            from version import __version__, APP_NAME
            print(f"{APP_NAME} v{__version__}")
        except ImportError:
            print("ImageReducer (version unknown)")
        return 0
    
    # Handle video compression
    if args.video:
        return compress_video_cli(args)
    
    # Default: Launch GUI
    try:
        from image_compressor_gui import main as gui_main
        gui_main()
        return 0
        
    except ImportError as e:
        print(f"Error importing GUI module: {e}")
        print("Make sure all dependencies are installed:")
        print("  pip install -r requirements.txt")
        return 1
    except Exception as e:
        print(f"Unexpected error: {e}")
        return 1


if __name__ == "__main__":
    # Launch the application
    sys.exit(main())