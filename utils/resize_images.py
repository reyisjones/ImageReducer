from PIL import Image
import os
from pathlib import Path

# Configuración
workspace_root = Path(__file__).parent
output_folder = workspace_root / "Reduced"
max_size_mb = 1.0  # Tamaño objetivo en MB
target_size_bytes = int(max_size_mb * 1024 * 1024)

# Crear carpeta de salida si no existe
output_folder.mkdir(exist_ok=True)

def get_file_size_mb(filepath):
    """Retorna el tamaño del archivo en MB"""
    return os.path.getsize(filepath) / (1024 * 1024)

def reduce_image(input_path, output_path, initial_quality=85, max_width=1920):
    """
    Reduce el tamaño de una imagen manteniendo buena calidad visual
    Ajusta automáticamente calidad y resolución para lograr < 1MB
    """
    with Image.open(input_path) as img:
        # Convertir a RGB si es necesario (para JPEGs)
        if img.mode in ('RGBA', 'P', 'LA'):
            img = img.convert('RGB')
        
        original_size = img.size
        quality = initial_quality
        
        # Primera pasada: reducir resolución si es necesario
        if max(img.size) > max_width:
            img.thumbnail((max_width, max_width), Image.Resampling.LANCZOS)
        
        # Guardar con optimización
        img.save(output_path, "JPEG", quality=quality, optimize=True)
        
        # Ajustar calidad si el archivo sigue siendo muy grande
        while os.path.getsize(output_path) > target_size_bytes and quality > 60:
            quality -= 5
            img.save(output_path, "JPEG", quality=quality, optimize=True)
        
        # Si todavía es grande, reducir más la resolución
        if os.path.getsize(output_path) > target_size_bytes:
            scale_factor = 0.9
            while os.path.getsize(output_path) > target_size_bytes and max(img.size) > 800:
                new_width = int(img.size[0] * scale_factor)
                new_height = int(img.size[1] * scale_factor)
                img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
                img.save(output_path, "JPEG", quality=quality, optimize=True)
        
        return original_size, img.size, quality

# Buscar todas las imágenes .jpg recursivamente
print("🔍 Buscando imágenes .jpg en el workspace...\n")
jpg_files = list(workspace_root.rglob("*.jpg")) + list(workspace_root.rglob("*.JPG"))

# Excluir la carpeta Reduced de la búsqueda
jpg_files = [f for f in jpg_files if not str(output_folder) in str(f.parent)]

print(f"📊 Se encontraron {len(jpg_files)} imágenes para procesar\n")
print("=" * 80)

# Procesar cada imagen
results = []
for i, input_path in enumerate(jpg_files, 1):
    try:
        # Tamaño original
        original_size_mb = get_file_size_mb(input_path)
        
        # Crear ruta de salida conservando el nombre
        output_path = output_folder / input_path.name
        
        # Si hay duplicados, agregar un sufijo
        counter = 1
        while output_path.exists():
            stem = input_path.stem
            output_path = output_folder / f"{stem}_{counter}{input_path.suffix}"
            counter += 1
        
        # Reducir imagen
        original_dims, final_dims, quality_used = reduce_image(input_path, output_path)
        
        # Tamaño final
        final_size_mb = get_file_size_mb(output_path)
        reduction_percent = ((original_size_mb - final_size_mb) / original_size_mb) * 100
        
        # Guardar resultado
        results.append({
            'name': input_path.name,
            'original_size': original_size_mb,
            'final_size': final_size_mb,
            'reduction': reduction_percent,
            'original_dims': original_dims,
            'final_dims': final_dims,
            'quality': quality_used
        })
        
        status = "✅" if final_size_mb < max_size_mb else "⚠️"
        print(f"{status} [{i}/{len(jpg_files)}] {input_path.name}")
        print(f"   Tamaño: {original_size_mb:.2f} MB → {final_size_mb:.2f} MB ({reduction_percent:.1f}% reducción)")
        print(f"   Dimensiones: {original_dims} → {final_dims} | Calidad: {quality_used}")
        print()
        
    except Exception as e:
        print(f"❌ Error procesando {input_path.name}: {str(e)}\n")

# Resumen final
print("=" * 80)
print("\n📈 RESUMEN FINAL\n")
print(f"{'Archivo':<40} {'Original':<12} {'Final':<12} {'Reducción':<10}")
print("-" * 80)

total_original = 0
total_final = 0

for result in results:
    print(f"{result['name']:<40} {result['original_size']:>8.2f} MB  {result['final_size']:>8.2f} MB  {result['reduction']:>7.1f}%")
    total_original += result['original_size']
    total_final += result['final_size']

print("-" * 80)
total_reduction = ((total_original - total_final) / total_original) * 100 if total_original > 0 else 0
print(f"{'TOTAL':<40} {total_original:>8.2f} MB  {total_final:>8.2f} MB  {total_reduction:>7.1f}%")
print(f"\n✅ Proceso completado: {len(results)} imágenes optimizadas")
print(f"💾 Espacio ahorrado: {total_original - total_final:.2f} MB")
print(f"📁 Archivos guardados en: {output_folder}")
