**Prompt for Copilot (place in `Prompts/VideoFeature.md` or in a code comment)**


# ✨ New Feature Request — Add Video Compression to ImageReducer

The `ImageReducer` Python application currently compresses images (PNG, JPEG) using Pillow.
We want to extend its functionality to also **compress videos** (MP4, MOV, MPEG) using FFmpeg or moviepy.

## 🧩 Requirements
1. Add a new module or class: `VideoReducer`.
2. The module should:
   - Accept a video file path as input.
   - Output a compressed version to the same or specified output folder.
   - Support formats: `.mp4`, `.mov`, `.mpeg`.
3. Use **ffmpeg-python** (preferred) or **moviepy** to handle compression.
4. Add configurable compression options:
   - `crf`: quality (default = 28)
   - `preset`: speed (default = "medium")
   - `resolution`: optional (resize to width/height)
5. Log progress and output file size reduction (before/after).
6. Integrate with the existing CLI or GUI flow where images are reduced.
7. Add unit tests for video compression functions.

```
## 🧱 Suggested Folder Structure Update
```
src/
├── imagereducer/
│   ├── **init**.py
│   ├── image_reducer.py
│   ├── video_reducer.py   ← 🆕 new file
│   └── utils.py
├── main.py
└── tests/
├── test_image_reducer.py
├── test_video_reducer.py  ← 🆕 new test file

```

## ⚙️ Example Function
```python
from ffmpeg import input, output, run

def compress_video(in_file, out_file, crf=28, preset="medium", resolution=None):
    stream = input(in_file)
    if resolution:
        stream = stream.filter('scale', resolution[0], resolution[1])
    output(stream, out_file, vcodec='libx264', crf=crf, preset=preset, acodec='aac').run()
````

## 🧪 Example Usage

```bash
python main.py --video "sample.mov" --output "compressed/" --crf 26 --preset slow
```

## ✅ Deliverables

* `video_reducer.py` implemented and imported into main flow.
* CLI updated to detect image vs. video input automatically.
* Unit tests verifying compression works and reduces file size.
* README updated with usage examples and new feature description.

 
