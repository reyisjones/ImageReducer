#!/usr/bin/env python3
"""
ImageReducer - Main Entry Point

Smart desktop application for intelligent image compression with customizable quality settings.
Supports batch processing and provides an intuitive GUI for users to compress images efficiently.

Usage:
    python main.py              # Launch GUI application
    python main.py --help       # Show help information
"""

import sys
import os
from pathlib import Path

# Add src to path if running from project root
src_dir = Path(__file__).parent
if str(src_dir) not in sys.path:
    sys.path.insert(0, str(src_dir))

def main():
    """Main entry point for the application"""
    try:
        # Import the GUI application
        from image_compressor_gui import main as gui_main
        
        # Launch the GUI
        gui_main()
        
    except ImportError as e:
        print(f"Error importing GUI module: {e}")
        print("Make sure all dependencies are installed:")
        print("  pip install -r ../requirements.txt")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    # Handle command line arguments
    if len(sys.argv) > 1:
        if sys.argv[1] in ["--help", "-h"]:
            print(__doc__)
            sys.exit(0)
        elif sys.argv[1] == "--version":
            try:
                from version import __version__, APP_NAME
                print(f"{APP_NAME} v{__version__}")
            except ImportError:
                print("ImageReducer (version unknown)")
            sys.exit(0)
    
    # Launch the application
    main()