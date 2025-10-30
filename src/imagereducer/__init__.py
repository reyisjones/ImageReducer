"""
ImageReducer Package

This package provides image and video compression functionality.
"""

from .video_reducer import VideoReducer, compress_video, check_ffmpeg_installed

__all__ = ['VideoReducer', 'compress_video', 'check_ffmpeg_installed']
