"""
Image Compressor - Desktop Application
A user-friendly GUI tool to compress JPG and PNG images to < 1MB
while maintaining high visual quality for web and content creation.
"""

import tkinter as tk
from tkinter import ttk, filedialog, messagebox
from pathlib import Path
import threading
import queue
import os
import sys
from PIL import Image

class ImageCompressorGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Image Compressor - Simple & Fast")
        self.root.geometry("700x550")
        self.root.resizable(False, False)
        
        # Configure style
        self.style = ttk.Style()
        self.style.theme_use('clam')
        
        # Variables
        self.selected_path = tk.StringVar()
        self.output_folder_name = tk.StringVar(value="Reduced")
        self.max_size_mb = tk.DoubleVar(value=1.0)
        self.quality = tk.IntVar(value=85)
        self.max_width = tk.IntVar(value=1920)
        self.processing = False
        self.cancel_flag = False
        self.progress_queue = queue.Queue()
        
        # Setup UI
        self.create_widgets()
        
        # Check progress updates
        self.check_progress_queue()
    
    def create_widgets(self):
        """Create all UI widgets"""
        
        # Header
        header_frame = tk.Frame(self.root, bg="#2c3e50", height=80)
        header_frame.pack(fill=tk.X, pady=0)
        header_frame.pack_propagate(False)
        
        title_label = tk.Label(
            header_frame, 
            text="🖼️ Image Compressor",
            font=("Segoe UI", 20, "bold"),
            bg="#2c3e50",
            fg="white"
        )
        title_label.pack(side=tk.LEFT, padx=20)
        
        # Help & Demo buttons in header
        header_btn_frame = tk.Frame(header_frame, bg="#2c3e50")
        header_btn_frame.pack(side=tk.RIGHT, padx=20)
        
        help_btn = tk.Button(
            header_btn_frame,
            text="❓ Help",
            command=self.show_help,
            font=("Segoe UI", 9),
            bg="#3498db",
            fg="white",
            padx=10,
            pady=5,
            cursor="hand2",
            relief=tk.FLAT
        )
        help_btn.pack(side=tk.LEFT, padx=5)
        
        demo_btn = tk.Button(
            header_btn_frame,
            text="▶️ Run Demo",
            command=self.run_demo,
            font=("Segoe UI", 9),
            bg="#e74c3c",
            fg="white",
            padx=10,
            pady=5,
            cursor="hand2",
            relief=tk.FLAT
        )
        demo_btn.pack(side=tk.LEFT, padx=5)
        
        # Main content frame
        content_frame = tk.Frame(self.root, padx=30, pady=20)
        content_frame.pack(fill=tk.BOTH, expand=True)
        
        # File/Folder selection
        selection_frame = tk.LabelFrame(
            content_frame, 
            text="📁 Select Files or Folder",
            font=("Segoe UI", 10, "bold"),
            padx=10,
            pady=10
        )
        selection_frame.pack(fill=tk.X, pady=(0, 15))
        
        path_frame = tk.Frame(selection_frame)
        path_frame.pack(fill=tk.X, pady=5)
        
        self.path_entry = tk.Entry(
            path_frame, 
            textvariable=self.selected_path,
            font=("Segoe UI", 10),
            state="readonly"
        )
        self.path_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5))
        
        browse_btn = tk.Button(
            path_frame,
            text="Browse Folder",
            command=self.browse_folder,
            font=("Segoe UI", 9),
            bg="#3498db",
            fg="white",
            padx=15,
            pady=5,
            cursor="hand2"
        )
        browse_btn.pack(side=tk.LEFT, padx=2)
        
        file_btn = tk.Button(
            path_frame,
            text="Browse Files",
            command=self.browse_files,
            font=("Segoe UI", 9),
            bg="#9b59b6",
            fg="white",
            padx=15,
            pady=5,
            cursor="hand2"
        )
        file_btn.pack(side=tk.LEFT, padx=2)
        
        # Settings
        settings_frame = tk.LabelFrame(
            content_frame,
            text="⚙️ Compression Settings",
            font=("Segoe UI", 10, "bold"),
            padx=10,
            pady=10
        )
        settings_frame.pack(fill=tk.X, pady=(0, 15))
        
        # Max size
        size_frame = tk.Frame(settings_frame)
        size_frame.pack(fill=tk.X, pady=3)
        tk.Label(size_frame, text="Target Size (MB):", font=("Segoe UI", 9)).pack(side=tk.LEFT)
        size_spinbox = tk.Spinbox(
            size_frame, 
            from_=0.1, 
            to=5.0, 
            increment=0.1,
            textvariable=self.max_size_mb,
            width=10,
            font=("Segoe UI", 9)
        )
        size_spinbox.pack(side=tk.LEFT, padx=10)
        tk.Label(size_frame, text="(Images will be compressed to this size)", 
                font=("Segoe UI", 8), fg="gray").pack(side=tk.LEFT)
        
        # Quality
        quality_frame = tk.Frame(settings_frame)
        quality_frame.pack(fill=tk.X, pady=3)
        tk.Label(quality_frame, text="Initial Quality:", font=("Segoe UI", 9)).pack(side=tk.LEFT)
        quality_spinbox = tk.Spinbox(
            quality_frame,
            from_=60,
            to=95,
            increment=5,
            textvariable=self.quality,
            width=10,
            font=("Segoe UI", 9)
        )
        quality_spinbox.pack(side=tk.LEFT, padx=10)
        tk.Label(quality_frame, text="(Higher = better quality, larger file)", 
                font=("Segoe UI", 8), fg="gray").pack(side=tk.LEFT)
        
        # Max width
        width_frame = tk.Frame(settings_frame)
        width_frame.pack(fill=tk.X, pady=3)
        tk.Label(width_frame, text="Max Width (px):", font=("Segoe UI", 9)).pack(side=tk.LEFT)
        width_spinbox = tk.Spinbox(
            width_frame,
            from_=800,
            to=3840,
            increment=100,
            textvariable=self.max_width,
            width=10,
            font=("Segoe UI", 9)
        )
        width_spinbox.pack(side=tk.LEFT, padx=10)
        tk.Label(width_frame, text="(Web-optimized: 1920px, High-res: 2560px)", 
                font=("Segoe UI", 8), fg="gray").pack(side=tk.LEFT)
        
        # Output folder
        output_frame = tk.Frame(settings_frame)
        output_frame.pack(fill=tk.X, pady=3)
        tk.Label(output_frame, text="Output Folder:", font=("Segoe UI", 9)).pack(side=tk.LEFT)
        output_entry = tk.Entry(
            output_frame,
            textvariable=self.output_folder_name,
            width=15,
            font=("Segoe UI", 9)
        )
        output_entry.pack(side=tk.LEFT, padx=10)
        tk.Label(output_frame, text="(Created inside selected folder)", 
                font=("Segoe UI", 8), fg="gray").pack(side=tk.LEFT)
        
        # Action buttons
        button_frame = tk.Frame(content_frame)
        button_frame.pack(fill=tk.X, pady=(0, 15))
        
        self.compress_btn = tk.Button(
            button_frame,
            text="🚀 Start Compression",
            command=self.start_compression,
            font=("Segoe UI", 11, "bold"),
            bg="#27ae60",
            fg="white",
            padx=30,
            pady=10,
            cursor="hand2"
        )
        self.compress_btn.pack(side=tk.LEFT, expand=True, fill=tk.X, padx=5)
        
        self.cancel_btn = tk.Button(
            button_frame,
            text="⏹️ Cancel",
            command=self.cancel_compression,
            font=("Segoe UI", 11, "bold"),
            bg="#e74c3c",
            fg="white",
            padx=30,
            pady=10,
            cursor="hand2",
            state=tk.DISABLED
        )
        self.cancel_btn.pack(side=tk.LEFT, expand=True, fill=tk.X, padx=5)
        
        # Progress section
        progress_frame = tk.LabelFrame(
            content_frame,
            text="📊 Progress",
            font=("Segoe UI", 10, "bold"),
            padx=10,
            pady=10
        )
        progress_frame.pack(fill=tk.BOTH, expand=True)
        
        # Progress bar
        self.progress_bar = ttk.Progressbar(
            progress_frame,
            mode='determinate',
            length=100
        )
        self.progress_bar.pack(fill=tk.X, pady=(0, 10))
        
        # Status text with scrollbar
        text_frame = tk.Frame(progress_frame)
        text_frame.pack(fill=tk.BOTH, expand=True)
        
        scrollbar = tk.Scrollbar(text_frame)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        self.status_text = tk.Text(
            text_frame,
            height=8,
            font=("Consolas", 9),
            yscrollcommand=scrollbar.set,
            wrap=tk.WORD,
            state=tk.DISABLED
        )
        self.status_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.config(command=self.status_text.yview)
    
    def log_message(self, message):
        """Add message to status text"""
        self.status_text.config(state=tk.NORMAL)
        self.status_text.insert(tk.END, message + "\n")
        self.status_text.see(tk.END)
        self.status_text.config(state=tk.DISABLED)
    
    def browse_folder(self):
        """Browse for a folder"""
        folder = filedialog.askdirectory(title="Select Folder with Images")
        if folder:
            self.selected_path.set(folder)
    
    def browse_files(self):
        """Browse for multiple image files"""
        files = filedialog.askopenfilenames(
            title="Select Image Files",
            filetypes=[
                ("Image files", "*.jpg *.jpeg *.png *.JPG *.JPEG *.PNG"),
                ("All files", "*.*")
            ]
        )
        if files:
            # Store files as semicolon-separated string
            self.selected_path.set(";".join(files))
    
    def start_compression(self):
        """Start the compression process"""
        path = self.selected_path.get()
        
        if not path:
            messagebox.showwarning("No Selection", "Please select a folder or files to compress.")
            return
        
        # Clear previous status
        self.status_text.config(state=tk.NORMAL)
        self.status_text.delete(1.0, tk.END)
        self.status_text.config(state=tk.DISABLED)
        
        # Update UI state
        self.processing = True
        self.cancel_flag = False
        self.compress_btn.config(state=tk.DISABLED)
        self.cancel_btn.config(state=tk.NORMAL)
        self.progress_bar['value'] = 0
        
        # Start compression in a separate thread
        thread = threading.Thread(target=self.compress_images, daemon=True)
        thread.start()
    
    def cancel_compression(self):
        """Cancel the ongoing compression"""
        self.cancel_flag = True
        self.log_message("⏹️ Canceling... Please wait.")
    
    def compress_images(self):
        """Main compression logic (runs in separate thread)"""
        try:
            path = self.selected_path.get()
            
            # Determine if it's files or folder
            if ";" in path:
                # Multiple files
                image_files = [Path(f) for f in path.split(";")]
                output_folder = Path(image_files[0].parent) / self.output_folder_name.get()
            else:
                # Single folder
                folder = Path(path)
                if not folder.is_dir():
                    self.progress_queue.put(("error", "Invalid folder path."))
                    return
                
                # Find all images
                image_files = []
                for ext in ['*.jpg', '*.jpeg', '*.png', '*.JPG', '*.JPEG', '*.PNG']:
                    image_files.extend(list(folder.rglob(ext)))
                
                output_folder = folder / self.output_folder_name.get()
                
                # Exclude images already in output folder
                image_files = [f for f in image_files if output_folder.name not in str(f.parent)]
            
            if not image_files:
                self.progress_queue.put(("error", "No image files found in the selected location."))
                return
            
            # Create output folder
            output_folder.mkdir(exist_ok=True)
            
            total = len(image_files)
            self.progress_queue.put(("log", f"🔍 Found {total} image(s) to process\n"))
            self.progress_queue.put(("log", "=" * 70))
            
            # Process each image
            results = []
            for i, input_path in enumerate(image_files, 1):
                if self.cancel_flag:
                    self.progress_queue.put(("log", "\n❌ Compression canceled by user."))
                    break
                
                try:
                    # Get original size
                    original_size_mb = os.path.getsize(input_path) / (1024 * 1024)
                    
                    # Create output path
                    output_path = output_folder / input_path.name
                    counter = 1
                    while output_path.exists():
                        stem = input_path.stem
                        output_path = output_folder / f"{stem}_{counter}{input_path.suffix}"
                        counter += 1
                    
                    # Compress image
                    result = self.reduce_image(
                        input_path,
                        output_path,
                        self.quality.get(),
                        self.max_width.get(),
                        self.max_size_mb.get()
                    )
                    
                    final_size_mb = os.path.getsize(output_path) / (1024 * 1024)
                    reduction = ((original_size_mb - final_size_mb) / original_size_mb) * 100 if original_size_mb > 0 else 0
                    
                    status = "✅" if final_size_mb < self.max_size_mb.get() else "⚠️"
                    msg = f"{status} [{i}/{total}] {input_path.name}\n"
                    msg += f"    {original_size_mb:.2f} MB → {final_size_mb:.2f} MB ({reduction:.1f}% reduction)\n"
                    
                    self.progress_queue.put(("log", msg))
                    self.progress_queue.put(("progress", (i / total) * 100))
                    
                    results.append({
                        'name': input_path.name,
                        'original': original_size_mb,
                        'final': final_size_mb,
                        'reduction': reduction
                    })
                    
                except Exception as e:
                    self.progress_queue.put(("log", f"❌ Error: {input_path.name} - {str(e)}\n"))
            
            # Summary
            if results and not self.cancel_flag:
                total_original = sum(r['original'] for r in results)
                total_final = sum(r['final'] for r in results)
                total_reduction = ((total_original - total_final) / total_original) * 100 if total_original > 0 else 0
                
                self.progress_queue.put(("log", "\n" + "=" * 70))
                self.progress_queue.put(("log", "📈 SUMMARY"))
                self.progress_queue.put(("log", f"✅ Processed: {len(results)} images"))
                self.progress_queue.put(("log", f"💾 Space saved: {total_original - total_final:.2f} MB ({total_reduction:.1f}%)"))
                self.progress_queue.put(("log", f"📁 Output: {output_folder}"))
                self.progress_queue.put(("complete", ""))
            
        except Exception as e:
            self.progress_queue.put(("error", f"Error: {str(e)}"))
    
    def reduce_image(self, input_path, output_path, initial_quality, max_width, max_size_mb):
        """Reduce image size while maintaining quality"""
        target_size_bytes = int(max_size_mb * 1024 * 1024)
        
        with Image.open(input_path) as img:
            # Convert to RGB if needed
            if img.mode in ('RGBA', 'P', 'LA'):
                # For PNG with transparency, use white background
                if img.mode in ('RGBA', 'LA'):
                    background = Image.new('RGB', img.size, (255, 255, 255))
                    if img.mode == 'RGBA':
                        background.paste(img, mask=img.split()[3])
                    else:
                        background.paste(img, mask=img.split()[1])
                    img = background
                else:
                    img = img.convert('RGB')
            
            quality = initial_quality
            
            # Resize if too large
            if max(img.size) > max_width:
                img.thumbnail((max_width, max_width), Image.Resampling.LANCZOS)
            
            # Save with optimization
            img.save(output_path, "JPEG", quality=quality, optimize=True)
            
            # Adjust quality if needed
            while os.path.getsize(output_path) > target_size_bytes and quality > 60:
                quality -= 5
                img.save(output_path, "JPEG", quality=quality, optimize=True)
            
            # Further resize if still too large
            if os.path.getsize(output_path) > target_size_bytes:
                scale_factor = 0.9
                while os.path.getsize(output_path) > target_size_bytes and max(img.size) > 800:
                    new_width = int(img.size[0] * scale_factor)
                    new_height = int(img.size[1] * scale_factor)
                    img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
                    img.save(output_path, "JPEG", quality=quality, optimize=True)
            
            return img.size, quality
    
    def show_help(self):
        """Show help dialog with instructions"""
        help_window = tk.Toplevel(self.root)
        help_window.title("Help & Instructions")
        help_window.geometry("600x500")
        help_window.resizable(False, False)
        
        # Header
        header = tk.Frame(help_window, bg="#3498db", height=60)
        header.pack(fill=tk.X)
        header.pack_propagate(False)
        
        tk.Label(
            header,
            text="❓ How to Use Image Compressor",
            font=("Segoe UI", 16, "bold"),
            bg="#3498db",
            fg="white"
        ).pack(pady=15)
        
        # Content with scrollbar
        content_frame = tk.Frame(help_window)
        content_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        scrollbar = tk.Scrollbar(content_frame)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        help_text = tk.Text(
            content_frame,
            font=("Segoe UI", 10),
            wrap=tk.WORD,
            yscrollcommand=scrollbar.set,
            padx=10,
            pady=10
        )
        help_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.config(command=help_text.yview)
        
        # Help content
        help_content = """
📖 QUICK START GUIDE

1️⃣ SELECT IMAGES
   • Click "Browse Folder" to compress all images in a folder
   • Click "Browse Files" to select specific image files
   • Or try "Run Demo" to see it in action with sample images!

2️⃣ ADJUST SETTINGS (Optional)
   Target Size: How small you want files (default: 1 MB)
   • 0.5 MB = Good for email
   • 1.0 MB = Perfect for websites
   • 2.0 MB = High quality portfolios
   
   Initial Quality: Starting quality level (default: 85)
   • 75-80 = Smaller files, good quality
   • 85 = Balanced (recommended)
   • 90-95 = Excellent quality, larger files
   
   Max Width: Maximum image width in pixels
   • 1280px = Mobile-friendly
   • 1920px = Full HD web (recommended)
   • 2560px = High resolution

3️⃣ START COMPRESSION
   • Click "Start Compression" button
   • Watch progress bar and status messages
   • Wait for completion notification

4️⃣ FIND YOUR IMAGES
   • Compressed images are in "Reduced" folder
   • Located inside your selected folder
   • Original files are NEVER modified!

💡 TIPS
   • Your original files are safe - never changed
   • All compressed images go to "Reduced" folder
   • Try different settings for different uses
   • Use "Run Demo" to test before your own images

📊 COMPARISON FEATURE
   After compression:
   • Check the status log for file sizes
   • Original size → Compressed size
   • Percentage reduction shown

⚠️ TROUBLESHOOTING
   • No images found? Check folder selection
   • Still too large? Lower quality or max width
   • Images blurry? Increase quality setting

🎯 BEST PRACTICES
   • Always backup important originals
   • Test settings on a few images first
   • Use presets for common scenarios
   • Check output quality before bulk operations

Need more help? See README.md in the installation folder.
"""
        
        help_text.insert(1.0, help_content)
        help_text.config(state=tk.DISABLED)
        
        # Close button
        close_btn = tk.Button(
            help_window,
            text="Close",
            command=help_window.destroy,
            font=("Segoe UI", 10),
            bg="#95a5a6",
            fg="white",
            padx=20,
            pady=5,
            cursor="hand2"
        )
        close_btn.pack(pady=10)
    
    def run_demo(self):
        """Run demonstration with sample images"""
        # Check if sample images exist
        sample_dir = Path(__file__).parent / "sample_images"
        
        if not sample_dir.exists() or not list(sample_dir.glob("*.jpg")) and not list(sample_dir.glob("*.png")):
            # Offer to generate samples
            response = messagebox.askyesno(
                "Sample Images Not Found",
                "Sample images are not available.\n\n"
                "Would you like to generate them now?\n\n"
                "This will create 5 sample images (~15 MB total) "
                "in the 'sample_images' folder for testing."
            )
            
            if response:
                try:
                    # Import and run sample generator
                    self.log_message("🎨 Generating sample images...")
                    
                    from generate_samples import create_sample_images
                    create_sample_images()
                    
                    self.log_message("✅ Sample images created successfully!")
                    messagebox.showinfo(
                        "Success",
                        "Sample images have been generated!\n\n"
                        "Click 'Run Demo' again to compress them."
                    )
                except Exception as e:
                    messagebox.showerror(
                        "Error",
                        f"Failed to generate sample images:\n{str(e)}\n\n"
                        "You can generate them manually by running:\n"
                        "python generate_samples.py"
                    )
            return
        
        # Show demo information
        demo_info = messagebox.askyesno(
            "Run Demonstration",
            "This will compress the sample images to demonstrate how the application works.\n\n"
            "Sample images location:\n"
            f"{sample_dir}\n\n"
            "Output will be saved to:\n"
            f"{sample_dir / 'Reduced'}\n\n"
            "Current settings will be used:\n"
            f"• Target Size: {self.max_size_mb.get()} MB\n"
            f"• Quality: {self.quality.get()}\n"
            f"• Max Width: {self.max_width.get()}px\n\n"
            "Proceed with demo?"
        )
        
        if demo_info:
            # Set sample folder as selected path
            self.selected_path.set(str(sample_dir))
            
            # Start compression
            self.log_message("🎬 Running demonstration with sample images...")
            self.log_message("=" * 70)
            self.start_compression()
    
    def check_progress_queue(self):
        """Check for progress updates from worker thread"""
        try:
            while True:
                msg_type, data = self.progress_queue.get_nowait()
                
                if msg_type == "log":
                    self.log_message(data)
                elif msg_type == "progress":
                    self.progress_bar['value'] = data
                elif msg_type == "complete":
                    self.processing = False
                    self.compress_btn.config(state=tk.NORMAL)
                    self.cancel_btn.config(state=tk.DISABLED)
                    messagebox.showinfo("Complete", "Image compression completed successfully!")
                elif msg_type == "error":
                    self.processing = False
                    self.compress_btn.config(state=tk.NORMAL)
                    self.cancel_btn.config(state=tk.DISABLED)
                    messagebox.showerror("Error", data)
        except queue.Empty:
            pass
        
        # Continue checking
        self.root.after(100, self.check_progress_queue)


def check_dependencies():
    """Check if required dependencies are installed"""
    try:
        import PIL
        return True
    except ImportError:
        return False


def main():
    """Main entry point"""
    # Check dependencies
    if not check_dependencies():
        root = tk.Tk()
        root.withdraw()
        response = messagebox.askyesno(
            "Missing Dependencies",
            "The required library 'Pillow' is not installed.\n\n"
            "Would you like to install it now?\n\n"
            "This requires an internet connection and will run:\n"
            "pip install Pillow"
        )
        
        if response:
            import subprocess
            try:
                subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow"])
                messagebox.showinfo("Success", "Pillow installed successfully!\n\nPlease restart the application.")
            except Exception as e:
                messagebox.showerror("Installation Failed", f"Failed to install Pillow:\n{str(e)}")
        
        root.destroy()
        return
    
    # Create and run GUI
    root = tk.Tk()
    app = ImageCompressorGUI(root)
    root.mainloop()


if __name__ == "__main__":
    main()
