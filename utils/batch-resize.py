#!/usr/bin/env python
from gimpfu import *

def batch_resize(in_dir, out_dir, width):
    import os
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)

    for file in os.listdir(in_dir):
        if file.lower().endswith(".jpg"):
            img = pdb.file_jpeg_load(os.path.join(in_dir, file), file)
            pdb.gimp_image_scale_full(img, width, width, INTERPOLATION_CUBIC)
            pdb.file_jpeg_save(img, img.layers[0], os.path.join(out_dir, file), file, 0.85, 0, 1, 0, "", 0, 1, 0, 2)
            pdb.gimp_image_delete(img)

register(
    "python_fu_batch_resize",
    "Batch resize JPG images",
    "Resizes all JPGs in a folder",
    "Reyis", "Reyis", "2025",
    "<Image>/Filters/Batch/Resize JPGs...",
    "",
    [
        (PF_DIRNAME, "in_dir", "Input folder", ""),
        (PF_DIRNAME, "out_dir", "Output folder", ""),
        (PF_INT, "width", "Max width", 1920)
    ],
    [],
    batch_resize)

main()
