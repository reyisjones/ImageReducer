from PIL import Image
import os
import shutil
from pathlib import Path
import hashlib

def get_image_hash(filepath):
    """Calcula el hash MD5 de una imagen para detectar duplicados"""
    with open(filepath, 'rb') as f:
        return hashlib.md5(f.read()).hexdigest()

# Configuración
workspace_root = Path(__file__).parent
reduced_folder = workspace_root / "Reduced"
organized_folder = reduced_folder / "eMdld_Images"

# Crear carpeta organizada
organized_folder.mkdir(exist_ok=True)

# Orden de álbumes según solicitado
album_order = [
    "manjar de los dioses",
    "alucinando",
    "aromas",
    "década de sabores"
]

# Patrones para identificar álbumes en nombres de archivos
album_patterns = {
    "manjar de los dioses": ["manjar", "Manjar"],
    "alucinando": ["Alucinando", "alucinando"],
    "aromas": ["Aromas", "aromas"],
    "década de sabores": ["Década", "decada", "Sabores"]
}

# Obtener todas las imágenes de Reduced
all_images = list(reduced_folder.glob("*.jpg")) + list(reduced_folder.glob("*.JPG"))

print(f"🔍 Encontradas {len(all_images)} imágenes en Reduced\n")
print("=" * 80)

# Diccionario para detectar duplicados por hash
seen_hashes = {}
duplicates_found = 0

# Diccionario para organizar imágenes por álbum
album_images = {album: [] for album in album_order}
other_images = []

# Clasificar imágenes por álbum
for img_path in all_images:
    img_name = img_path.name
    
    # Determinar a qué álbum pertenece
    album_found = None
    for album, patterns in album_patterns.items():
        for pattern in patterns:
            if pattern in img_name:
                album_found = album
                break
        if album_found:
            break
    
    if album_found:
        album_images[album_found].append(img_path)
    else:
        other_images.append(img_path)

# Contador para renombrar
counter = 1

# Procesar imágenes en orden de álbumes
for album in album_order:
    images = album_images[album]
    
    if not images:
        continue
    
    print(f"\n📀 Álbum: {album.upper()}")
    print("-" * 80)
    
    for img_path in sorted(images):
        # Calcular hash para detectar duplicados
        img_hash = get_image_hash(img_path)
        
        if img_hash in seen_hashes:
            duplicates_found += 1
            print(f"⏭️  DUPLICADO: {img_path.name} (igual a {seen_hashes[img_hash]})")
            continue
        
        # Registrar hash
        seen_hashes[img_hash] = img_path.name
        
        # Crear nuevo nombre con prefijo numérico
        new_name = f"{counter:02d}_{img_path.name}"
        dest_path = organized_folder / new_name
        
        # Copiar imagen
        shutil.copy2(img_path, dest_path)
        counter += 1
        
        print(f"✅ Copiado: {img_path.name} → {new_name}")

# Procesar otras imágenes (reportajes, etc.)
if other_images:
    print(f"\n📸 Otras imágenes")
    print("-" * 80)
    
    for img_path in sorted(other_images):
        # Calcular hash para detectar duplicados
        img_hash = get_image_hash(img_path)
        
        if img_hash in seen_hashes:
            duplicates_found += 1
            print(f"⏭️  DUPLICADO: {img_path.name} (igual a {seen_hashes[img_hash]})")
            continue
        
        # Registrar hash
        seen_hashes[img_hash] = img_path.name
        
        # Crear nuevo nombre con prefijo numérico
        new_name = f"{counter:02d}_{img_path.name}"
        dest_path = organized_folder / new_name
        
        # Copiar imagen
        shutil.copy2(img_path, dest_path)
        counter += 1
        
        print(f"✅ Copiado: {img_path.name} → {new_name}")

# Resumen final
print("\n" + "=" * 80)
print("\n📊 RESUMEN FINAL\n")
print(f"✅ Total de imágenes originales en Reduced: {len(all_images)}")
print(f"⏭️  Duplicados detectados y omitidos: {duplicates_found}")
print(f"📁 Imágenes únicas copiadas: {counter - 1}")
print(f"📂 Carpeta destino: {organized_folder}")
print("\n🎯 Orden de álbumes:")
for i, album in enumerate(album_order, 1):
    count = len([img for img in album_images[album]])
    if count > 0:
        print(f"   {i}. {album.title()}: {count} imágenes")
