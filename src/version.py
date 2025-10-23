"""
Version information for Image Compressor application.
"""

__version__ = "1.0.2"
__version_info__ = tuple(map(int, __version__.split(".")))

# Application metadata
APP_NAME = "Image Compressor"
APP_AUTHOR = "Reyis Jones"
APP_COPYRIGHT = "Copyright (c) 2025 Reyis Jones"
APP_DESCRIPTION = "Desktop application for smart image compression to target file size"

# Semantic Versioning: MAJOR.MINOR.PATCH
# MAJOR: Incompatible API changes
# MINOR: New functionality (backwards compatible)
# PATCH: Bug fixes (backwards compatible)

def get_version():
    """Return the current version string."""
    return __version__

def get_version_info():
    """Return the version as a tuple of integers (major, minor, patch)."""
    return __version_info__

def get_full_version():
    """Return full version info with metadata."""
    return f"{APP_NAME} v{__version__}"

if __name__ == "__main__":
    print(f"{APP_NAME} v{__version__}")
    print(f"Version info: {__version_info__}")
    print(APP_COPYRIGHT)
