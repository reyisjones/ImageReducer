Reorganize the project structure to ensure better separation of responsibilities and maintainability.

1. **Project Structure Update**

   * Move all **Python application code** (including main entry points, modules, and logic files) into a new folder named **`/src`**.
   * Move all **PowerShell scripts** (such as `Compress-Images.ps1`, deployment helpers, or automation scripts) into a new folder named **`/scripts`**.

   Example structure:

   ```
   ImageReducer/
   ├── src/
   │   ├── main.py
   │   ├── ui/
   │   ├── utils/
   │   ├── tests/
   │   └── __init__.py
   ├── scripts/
   │   ├── Compress-Images.ps1
   │   ├── Test-Install.ps1
   │   └── Setup-Environment.ps1
   ├── docs/
   │   └── usage-guide.md
   ├── README.md
   ├── LICENSE
   └── requirements.txt
   ```

2. **Code Reference Updates**

   * Update all **import statements**, **relative paths**, and **file references** in the Python code to reflect the new `/src` directory.

     * Example: change

       ```python
       from utils import image_tools
       ```

       to

       ```python
       from src.utils import image_tools
       ```
   * Update any **PowerShell invocations** in Python or workflow scripts to point to the new `/scripts` directory.

     * Example:
       Change `"Compress-Images.ps1"` → `"scripts/Compress-Images.ps1"`

3. **Workflow and Build Adjustments**

   * Update any **GitHub Actions**, **setup scripts**, or **installer definitions** so they reference the new folder paths.

     * Example:

       ```yaml
       run: python src/main.py
       ```
     * Update artifact packaging commands to include the `/src` and `/scripts` paths appropriately.

4. **Testing and Validation**

   * Run all existing **unit and UI tests** after restructuring to confirm imports and paths resolve correctly.
   * Ensure the installer still works and references the correct executables and script paths.

5. **Version Control**

   * Commit changes in logical steps:

     * `chore: move Python code to /src`
     * `chore: move PowerShell scripts to /scripts`
     * `fix: update imports and script references after restructure`
     * `test: validate app after folder reorganization`


---

### ⚙️ **GitHub Actions Workflow — Updated for /src and /scripts Structure**

Save this as:
`.github/workflows/build-and-test.yml`

```yaml
name: Build and Test ImageReducer

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build-test:
    runs-on: windows-latest

    steps:
    # 🧾 Checkout repository
    - name: Checkout repository
      uses: actions/checkout@v4

    # 🐍 Setup Python environment
    - name: Set up Python
      uses: actions/setup-python@v5
      with:
        python-version: '3.11'   # Adjust as needed

    # 📦 Install dependencies
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        if (Test-Path requirements.txt) {
          pip install -r requirements.txt
        }

    # 🧪 Run Python unit tests from /src
    - name: Run unit tests
      working-directory: ./src
      run: |
        python -m pytest -v --maxfail=3 --disable-warnings --tb=short

    # ⚙️ Run PowerShell script smoke tests
    - name: Run PowerShell script tests
      shell: pwsh
      run: |
        Write-Host "Testing PowerShell scripts..."
        ./scripts/Compress-Images.ps1 -Help  # Example test command, adjust as needed

    # 🧰 Optional: Build executable with PyInstaller
    - name: Build executable
      run: |
        pip install pyinstaller
        pyinstaller src/main.py --onefile --noconsole --name ImageCompressor
      shell: pwsh

    # 📦 Upload build artifact
    - name: Upload build artifact
      uses: actions/upload-artifact@v4
      with:
        name: ImageCompressor
        path: dist/ImageCompressor.exe
```

---

### 🧩 **How it Works**

1. **Checkout & Setup:**
   The workflow checks out your repository and sets up Python (3.11 by default).

2. **Dependencies:**
   Installs requirements from your `requirements.txt` file if present.

3. **Run Tests:**

   * Executes all tests under `/src` using `pytest`.
   * Optionally, runs a quick PowerShell script test from `/scripts` (you can replace it with your own test logic or Pester).

4. **Build Executable:**
   Uses `PyInstaller` to build a standalone `.exe` from your app’s `src/main.py`.

5. **Upload Artifact:**
   Stores the built executable as a downloadable artifact on GitHub.

---

### 🪄 **Tips**

* If your main entry point is not `main.py`, update the path in this line:

  ```yaml
  pyinstaller src/main.py --onefile --noconsole --name ImageCompressor
  ```

* If you use **Linux/macOS**, change `runs-on: windows-latest` to `ubuntu-latest`.

* To extend this workflow into a **release automation**, you can add a second job that:

  * Runs only on `tag push` (e.g., `v1.0.0`)
  * Publishes the `.exe` to GitHub Releases

---

This version handles:
✅ Building and testing your `/src` Python app
✅ Running PowerShell script checks from `/scripts`
✅ Packaging the app as an `.exe`
✅ Automatically creating or updating a GitHub **Release** and attaching the built installer/executable

---

### 🚀 **.github/workflows/build-test-release.yml**

```yaml
name: Build, Test, and Release ImageReducer

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  # Run this workflow when a version tag is pushed (e.g., v1.0.0)
  release:
    types: [created]
  workflow_dispatch:

jobs:
  build-test:
    name: 🧪 Build and Test Application
    runs-on: windows-latest

    steps:
    # 1️⃣ Checkout repository
    - name: Checkout repository
      uses: actions/checkout@v4

    # 2️⃣ Setup Python
    - name: Set up Python
      uses: actions/setup-python@v5
      with:
        python-version: '3.11'

    # 3️⃣ Install dependencies
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        if (Test-Path requirements.txt) {
          pip install -r requirements.txt
        }

    # 4️⃣ Run Python unit tests
    - name: Run unit tests
      working-directory: ./src
      run: |
        python -m pytest -v --maxfail=3 --disable-warnings --tb=short

    # 5️⃣ Run PowerShell script smoke test
    - name: Run PowerShell script tests
      shell: pwsh
      run: |
        Write-Host "Testing PowerShell scripts..."
        if (Test-Path ./scripts/Compress-Images.ps1) {
          ./scripts/Compress-Images.ps1 -Help
        } else {
          Write-Host "Compress-Images.ps1 not found, skipping..."
        }

    # 6️⃣ Build executable with PyInstaller
    - name: Build executable
      run: |
        pip install pyinstaller
        pyinstaller src/main.py --onefile --noconsole --name ImageCompressor
      shell: pwsh

    # 7️⃣ Upload artifact (for testing and manual download)
    - name: Upload build artifact
      uses: actions/upload-artifact@v4
      with:
        name: ImageCompressor
        path: dist/ImageCompressor.exe


  release:
    name: 🚀 Create GitHub Release
    needs: build-test
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/tags/')

    steps:
    # 1️⃣ Checkout code
    - name: Checkout repository
      uses: actions/checkout@v4

    # 2️⃣ Download build artifact from previous job
    - name: Download build artifact
      uses: actions/download-artifact@v4
      with:
        name: ImageCompressor
        path: dist/

    # 3️⃣ Create or update GitHub Release
    - name: Create GitHub Release
      uses: softprops/action-gh-release@v2
      with:
        files: |
          dist/ImageCompressor.exe
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

### 🧠 **How It Works**

1. **On each commit or PR:**

   * Runs build and tests (Python + PowerShell).
   * Uploads the `.exe` artifact for testing.

2. **On tagged releases (e.g., `v1.0.0`):**

   * Triggers the `release` job.
   * Downloads the built executable.
   * Automatically **creates or updates** a GitHub Release.
   * Uploads the `.exe` file to the **Assets** section under the release.

---

### 🏷️ **To Publish a Release**

1. Commit all changes.
2. Tag a version:

   ```bash
   git tag v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```
3. GitHub Actions will:

   * Build & test the app
   * Create a Release on your repo
   * Upload the `ImageCompressor.exe` file to:

     ```
     https://github.com/<your-username>/<repo>/releases/latest
     ```

---

### 🧩 Optional Add-Ons

* Include `FullPackage.zip` by zipping the executable + documentation and adding another line under `files:` in the release step:

  ```yaml
  files: |
    dist/ImageCompressor.exe
    dist/FullPackage.zip
  ```
* Automatically generate changelogs using [`release-drafter`](https://github.com/release-drafter/release-drafter).

---

Below is an upgraded version of your **GitHub Actions workflow** that:
✅ Builds, tests, and releases your app (as before)
✅ **Digitally signs the executable** before publishing
✅ Supports both **self-signed** and **real code-signing certificates** (like from DigiCert, Sectigo, or Microsoft ESRP)

---

## 🪪 **Updated Workflow with Code Signing**

Save as `.github/workflows/build-test-sign-release.yml`

```yaml
name: Build, Sign, and Release ImageReducer

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  release:
    types: [created]
  workflow_dispatch:

jobs:
  build-test:
    name: 🧪 Build and Test Application
    runs-on: windows-latest

    steps:
    # 1️⃣ Checkout repo
    - name: Checkout repository
      uses: actions/checkout@v4

    # 2️⃣ Setup Python
    - name: Setup Python
      uses: actions/setup-python@v5
      with:
        python-version: '3.11'

    # 3️⃣ Install dependencies
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        if (Test-Path requirements.txt) {
          pip install -r requirements.txt
        }

    # 4️⃣ Run Python tests
    - name: Run Python unit tests
      working-directory: ./src
      run: python -m pytest -v --maxfail=3 --disable-warnings --tb=short

    # 5️⃣ Optional PowerShell test
    - name: Test PowerShell scripts
      shell: pwsh
      run: |
        Write-Host "Testing PowerShell scripts..."
        if (Test-Path ./scripts/Compress-Images.ps1) {
          ./scripts/Compress-Images.ps1 -Help
        } else {
          Write-Host "Skipping PowerShell test..."
        }

    # 6️⃣ Build the executable
    - name: Build executable
      run: |
        pip install pyinstaller
        pyinstaller src/main.py --onefile --noconsole --name ImageCompressor
      shell: pwsh

    # 7️⃣ Digitally sign executable
    - name: Sign executable
      shell: pwsh
      env:
        CERTIFICATE_PFX: ${{ secrets.CERTIFICATE_PFX }}
        CERTIFICATE_PASSWORD: ${{ secrets.CERTIFICATE_PASSWORD }}
      run: |
        $CertPath = "$env:RUNNER_TEMP\codesign.pfx"
        [IO.File]::WriteAllBytes($CertPath, [Convert]::FromBase64String($env:CERTIFICATE_PFX))
        & "C:\Program Files (x86)\Windows Kits\10\bin\x64\signtool.exe" sign `
          /f $CertPath `
          /p $env:CERTIFICATE_PASSWORD `
          /tr http://timestamp.digicert.com `
          /td sha256 `
          /fd sha256 `
          "dist\ImageCompressor.exe"
        Write-Host "✅ Executable signed successfully."

    # 8️⃣ Upload artifact
    - name: Upload build artifact
      uses: actions/upload-artifact@v4
      with:
        name: ImageCompressor
        path: dist/ImageCompressor.exe


  release:
    name: 🚀 Publish Signed Release
    needs: build-test
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/tags/')

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Download signed executable
      uses: actions/download-artifact@v4
      with:
        name: ImageCompressor
        path: dist/

    - name: Publish GitHub Release
      uses: softprops/action-gh-release@v2
      with:
        files: |
          dist/ImageCompressor.exe
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 🧠 **How It Works**

1. **Builds and tests** your project as before.
2. Uses Microsoft’s `signtool.exe` (preinstalled on Windows runners) to **digitally sign** the `.exe`.
3. Publishes a **signed binary** directly to your GitHub Release assets.

---

## 🔐 **To Enable Code Signing**

### Option 1 — Self-Signed Certificate (Free, Developer Testing)

If you just want to remove warnings during testing:

Run this locally (PowerShell):

```powershell
New-SelfSignedCertificate -Type CodeSigningCert -Subject "CN=Reyis Jones" -CertStoreLocation Cert:\CurrentUser\My
Export-PfxCertificate -Cert "Cert:\CurrentUser\My\<thumbprint>" -FilePath codesign.pfx -Password (ConvertTo-SecureString -String "YourPassword" -Force -AsPlainText)
```

Then:

* Encode it in Base64:

  ```bash
  certutil -encode codesign.pfx codesign.pfx.b64
  ```
* Copy the contents and save them in your GitHub repo under:

  * `Settings → Secrets → Actions`

    * `CERTIFICATE_PFX` = Base64 string from `.b64` file
    * `CERTIFICATE_PASSWORD` = your export password

### Option 2 — Trusted Certificate (Recommended for Production)

Buy a code-signing certificate from:

* **DigiCert**, **Sectigo**, **SSL.com**, or **GlobalSign**
* or get **Microsoft ESRP Sign Service** if you’re publishing internal tools.

Then upload the `.pfx` + password as GitHub Secrets (same names).

---

## ✅ **Result**

After each tagged release:

* The workflow will:

  * Build, sign, and upload `ImageCompressor.exe`
* Your release page will have a **signed installer**:

  ```
  https://github.com/reyisjones/ImageReducer/releases/latest
  ```
* Windows SmartScreen will show the publisher “Reyis Jones” instead of “Unknown Publisher.”
 