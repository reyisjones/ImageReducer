# 📋 Manual para Crear Releases

Este documento explica cómo crear releases manualmente en GitHub para publicar nuevas versiones del Image Compressor.

---

## 🎯 Proceso Automático (Recomendado)

El proyecto usa GitHub Actions para automatizar la creación de releases. Simplemente:

### 1. Actualizar Versión

Edita `version.py`:
```python
__version__ = "1.0.1"  # Actualiza el número de versión
```

### 2. Commit y Push

```bash
git add version.py
git commit -m "chore: bump version to 1.0.1"
git push origin master
```

### 3. Crear y Empujar Tag

```bash
# Crear tag anotado
git tag -a v1.0.1 -m "Release v1.0.1

Nuevas características:
- Característica 1
- Característica 2

Correcciones:
- Bug fix 1
"

# Empujar tag (esto dispara el workflow automático)
git push origin v1.0.1
```

### 4. Esperar GitHub Actions

El workflow `.github/workflows/release.yml` automáticamente:
- ✅ Ejecuta todos los tests
- 🔨 Compila el ejecutable con PyInstaller  
- 📦 Crea el paquete ZIP con documentación
- 🔐 Genera checksums SHA256
- 📤 Sube los archivos al release
- 📝 Crea notas de versión

**Tiempo estimado:** 5-10 minutos

**Verificar en:** https://github.com/reyisjones/ImageReducer/actions

---

## 🛠️ Proceso Manual (Si el Automático Falla)

### Paso 1: Compilar el Ejecutable

```powershell
# Limpiar builds anteriores
.\build_exe.ps1 -Clean

# Compilar con tests
.\build_exe.ps1 -Test

# Resultado: dist\ImageCompressor.exe
```

### Paso 2: Crear Paquete ZIP

```powershell
# Usar el script de empaquetado
.\create_package.ps1 -CreateZip

# O manualmente:
$version = "1.0.1"
$packageName = "ImageCompressor-v$version-Windows"

# Crear directorio
New-Item -ItemType Directory -Path "release\$packageName"

# Copiar archivos
Copy-Item "dist\ImageCompressor.exe" "release\$packageName\"
Copy-Item "README.md" "release\$packageName\"
Copy-Item "LICENSE" "release\$packageName\"
Copy-Item "QUICKSTART.md" "release\$packageName\"
Copy-Item "config.ini" "release\$packageName\"
Copy-Item "install.ps1" "release\$packageName\"
Copy-Item "start.bat" "release\$packageName\"

# Crear ZIP
Compress-Archive -Path "release\$packageName\*" -DestinationPath "release\$packageName.zip"
```

### Paso 3: Generar Checksum

```powershell
$version = "1.0.1"
$zipFile = "release\ImageCompressor-v$version-Windows.zip"

# Calcular SHA256
$hash = Get-FileHash $zipFile -Algorithm SHA256

# Guardar en archivo
$hash.Hash + "  " + (Split-Path $zipFile -Leaf) | 
    Out-File "release\ImageCompressor-v$version-Windows.zip.sha256" -Encoding ASCII

Write-Host "SHA256: $($hash.Hash)"
```

### Paso 4: Crear Release en GitHub

#### Opción A: Interfaz Web

1. Ve a: https://github.com/reyisjones/ImageReducer/releases
2. Click en **"Draft a new release"**
3. **Choose a tag:** Selecciona `v1.0.1` (o crea nuevo tag)
4. **Release title:** `v1.0.1 - Título Descriptivo`
5. **Describe this release:** 

```markdown
# Image Compressor v1.0.1

## 📦 Descargas

### Opción 1: Ejecutable Standalone
- **Archivo:** ImageCompressor.exe
- **Tamaño:** ~25 MB
- **Uso:** Descargar y ejecutar directamente

### Opción 2: Paquete Completo
- **Archivo:** ImageCompressor-v1.0.1-Windows.zip
- **Tamaño:** ~95 MB
- **Incluye:** Ejecutable, documentación, instalador, imágenes de muestra

## ✨ Novedades

- Nueva característica 1
- Nueva característica 2
- Mejora en rendimiento

## 🐛 Correcciones

- Corrección de bug 1
- Corrección de bug 2

## 📥 Instalación

### Método Rápido (Ejecutable):
1. Descargar `ImageCompressor.exe`
2. Ejecutar directamente (sin instalación)

### Método Completo (Recomendado):
1. Descargar `ImageCompressor-v1.0.1-Windows.zip`
2. Extraer el archivo ZIP
3. Ejecutar `install.ps1` como Administrador
4. Buscar en Menú Inicio o acceso directo en Escritorio

## 🔐 Verificación

```powershell
# Verificar integridad del archivo
Get-FileHash ImageCompressor-v1.0.1-Windows.zip -Algorithm SHA256

# Comparar con archivo .sha256 incluido
```

## 🔧 Requisitos

- Windows 10/11 (64-bit)
- Sin dependencias adicionales

## 📚 Documentación

- [README](https://github.com/reyisjones/ImageReducer/blob/master/README.md)
- [Guía Rápida](https://github.com/reyisjones/ImageReducer/blob/master/QUICKSTART.md)
- [Guía de Compilación](https://github.com/reyisjones/ImageReducer/blob/master/BUILD_GUIDE.md)

---

**Creado por:** Reyis Jones  
**Con asistencia de:** GitHub Copilot AI
```

6. **Adjuntar archivos** (arrastra o selecciona):
   - `ImageCompressor.exe`
   - `ImageCompressor-v1.0.1-Windows.zip`
   - `ImageCompressor-v1.0.1-Windows.zip.sha256`

7. ✅ Click en **"Publish release"**

#### Opción B: GitHub CLI

```bash
# Instalar gh CLI primero: https://cli.github.com/

# Crear release con archivos
gh release create v1.0.1 \
    dist/ImageCompressor.exe \
    release/ImageCompressor-v1.0.1-Windows.zip \
    release/ImageCompressor-v1.0.1-Windows.zip.sha256 \
    --title "v1.0.1 - Título Descriptivo" \
    --notes-file release/RELEASE_NOTES.md
```

---

## ✅ Verificación Post-Release

Después de crear el release, verifica:

### 1. URLs Funcionales

```bash
# Página del release
https://github.com/reyisjones/ImageReducer/releases/tag/v1.0.1

# Descarga directa del ejecutable
https://github.com/reyisjones/ImageReducer/releases/download/v1.0.1/ImageCompressor.exe

# Descarga directa del ZIP
https://github.com/reyisjones/ImageReducer/releases/download/v1.0.1/ImageCompressor-v1.0.1-Windows.zip

# Latest release (siempre apunta a la última versión)
https://github.com/reyisjones/ImageReducer/releases/latest
```

### 2. Integridad de Archivos

```powershell
# Descargar archivos
Invoke-WebRequest "https://github.com/reyisjones/ImageReducer/releases/download/v1.0.1/ImageCompressor-v1.0.1-Windows.zip" -OutFile "test-download.zip"

# Verificar checksum
Get-FileHash test-download.zip -Algorithm SHA256

# Comparar con el checksum publicado
```

### 3. Funcionalidad

```powershell
# Descargar ejecutable
Invoke-WebRequest "https://github.com/reyisjones/ImageReducer/releases/download/v1.0.1/ImageCompressor.exe" -OutFile "test-app.exe"

# Probar ejecución
.\test-app.exe

# Verificar que:
# - ✅ La ventana se abre correctamente
# - ✅ El título muestra la versión correcta
# - ✅ El botón Help muestra información de versión
# - ✅ El botón Demo funciona
```

---

## 🔄 Actualizar README

Después de crear el release, actualiza el README si es necesario:

```markdown
## 📦 Download

### Latest Release: [v1.0.1](https://github.com/reyisjones/ImageReducer/releases/latest)

Los usuarios pueden descargar:
- `ImageCompressor.exe` - Ejecutable independiente
- `ImageCompressor-v1.0.1-Windows.zip` - Paquete completo

Consulta [todos los releases](https://github.com/reyisjones/ImageReducer/releases)
```

---

## 📝 Convenciones de Versionado

Seguimos **Semantic Versioning** (semver.org):

- **MAJOR.MINOR.PATCH** (ej: 1.2.3)
- **MAJOR**: Cambios incompatibles con versiones anteriores
- **MINOR**: Nuevas características (compatible con anteriores)
- **PATCH**: Correcciones de bugs (compatible con anteriores)

### Ejemplos:

- `v1.0.0` → Primera versión estable
- `v1.0.1` → Corrección de bugs
- `v1.1.0` → Nueva característica (compatible)
- `v2.0.0` → Cambio importante (incompatible)

---

## 🐛 Solución de Problemas

### El workflow automático falla

1. Revisa los logs: https://github.com/reyisjones/ImageReducer/actions
2. Verifica que los tests pasen localmente: `.\run_tests.ps1`
3. Verifica que el build funcione: `.\build_exe.ps1 -Test`
4. Si persiste, usa el proceso manual

### Error 404 en descargas

- Verifica que el release esté publicado (no borrador)
- Confirma que los archivos estén adjuntos en Assets
- Verifica el nombre del archivo en la URL

### Checksum no coincide

- Regenera el checksum: `Get-FileHash archivo.zip -Algorithm SHA256`
- Vuelve a subir el archivo .sha256 correcto

---

## 📚 Referencias

- [GitHub Releases Documentation](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [GitHub Actions - Releases](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#release)
- [Semantic Versioning](https://semver.org/)

---

**Documento creado por:** Reyis Jones  
**Fecha:** Octubre 2025  
**Última actualización:** 2025-10-16
