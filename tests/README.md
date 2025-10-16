# Test Suite - Image Compressor

This directory contains the complete test suite for the Image Compressor application.

## 📁 Test Structure

```
tests/
├── test_compression.py      # Core compression algorithm tests
├── test_ui.py               # UI component tests (if applicable)
├── test_integration.py      # End-to-end integration tests
└── conftest.py              # Shared pytest fixtures
```

## 🧪 Running Tests

### Quick Start

```powershell
# Run all tests
.\run_tests.ps1

# Run with coverage
.\run_tests.ps1 -Coverage

# Run specific test types
.\run_tests.ps1 -Unit
.\run_tests.ps1 -Integration

# Verbose output
.\run_tests.ps1 -Verbose -Coverage
```

### Using pytest directly

```bash
# Run all tests
pytest tests/ -v

# Run specific test file
pytest tests/test_compression.py -v

# Run tests with coverage
pytest tests/ --cov=. --cov-report=html

# Run specific test
pytest tests/test_compression.py::TestCompressionCore::test_image_compression_below_1mb -v
```

## 📊 Test Categories

### Unit Tests (`test_compression.py`)

Tests individual functions and components in isolation:

- ✅ Image compression below 1 MB target
- ✅ PNG to JPEG conversion
- ✅ Aspect ratio preservation
- ✅ Quality adjustment algorithm
- ✅ File size reduction
- ✅ Error handling for corrupted files
- ✅ Configuration validation

**Run:** `pytest tests/test_compression.py -v`

### Integration Tests (`test_integration.py`)

Tests complete workflows and feature interactions:

- ✅ Full compression workflow
- ✅ Batch processing multiple images
- ✅ Output folder creation
- ✅ File naming conflicts
- ✅ Demo functionality
- ✅ Sample image generation

**Run:** `pytest tests/test_integration.py -v`

### UI Tests (`test_ui.py`)

Tests user interface components (if applicable):

- Button actions
- Dialog behaviors
- Progress updates
- Input validation

**Note:** UI tests require additional dependencies (pytest-qt for tkinter testing)

## 🎯 Test Coverage Goals

Target coverage: **80%+**

Current coverage areas:
- Core compression algorithm: 95%+
- File handling: 90%+
- Error handling: 85%+
- Configuration: 90%+

## 📝 Writing New Tests

### Test Template

```python
import pytest
from pathlib import Path
import tempfile

class TestFeatureName:
    """Test description"""
    
    @pytest.fixture
    def test_data(self):
        """Setup test data"""
        # Create test resources
        yield data
        # Cleanup
    
    def test_specific_behavior(self, test_data):
        """Test that specific behavior works correctly"""
        # Arrange
        input_data = test_data
        
        # Act
        result = function_to_test(input_data)
        
        # Assert
        assert result is not None
        assert result.value == expected_value
```

### Markers

Use pytest markers to categorize tests:

```python
@pytest.mark.unit
def test_unit_function():
    """Unit test"""
    pass

@pytest.mark.integration
def test_integration_workflow():
    """Integration test"""
    pass

@pytest.mark.slow
def test_slow_operation():
    """Slow test"""
    pass
```

Run specific markers:
```bash
pytest -m unit           # Run only unit tests
pytest -m integration    # Run only integration tests
pytest -m "not slow"     # Skip slow tests
```

## 🔧 Test Configuration

### pytest.ini

Located in project root, configures pytest behavior:

```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
```

### requirements-test.txt

Test dependencies:

```
pytest>=7.4.0
pytest-cov>=4.1.0
Pillow>=10.0.0
pytest-timeout>=2.1.0
```

Install with:
```bash
pip install -r requirements-test.txt
```

## 📊 Coverage Reports

### Generate Coverage

```bash
pytest tests/ --cov=. --cov-report=html --cov-report=term
```

### View Coverage

- **HTML Report:** Open `htmlcov/index.html` in browser
- **Terminal:** Displayed after test run
- **XML:** Generated for CI/CD integration

### Coverage Configuration

In `pytest.ini`:

```ini
[coverage:run]
source = .
omit = 
    tests/*
    */site-packages/*

[coverage:report]
exclude_lines =
    pragma: no cover
    def __repr__
    if __name__ == .__main__.:
```

## 🐛 Debugging Tests

### Run Single Test

```bash
pytest tests/test_compression.py::TestCompressionCore::test_image_compression_below_1mb -v
```

### Show Print Statements

```bash
pytest tests/ -v -s
```

### Drop into Debugger on Failure

```bash
pytest tests/ --pdb
```

### Show Locals on Failure

```bash
pytest tests/ -l
```

## ✅ Test Checklist

Before committing code, ensure:

- [ ] All existing tests pass
- [ ] New features have tests
- [ ] Coverage remains above 80%
- [ ] No commented-out tests
- [ ] Test names are descriptive
- [ ] Fixtures are properly cleaned up
- [ ] No hardcoded paths or values

## 🚀 Continuous Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install -r requirements-test.txt
    
    - name: Run tests
      run: pytest tests/ -v --cov=. --cov-report=xml
    
    - name: Upload coverage
      uses: codecov/codecov-action@v2
```

## 📞 Troubleshooting

### "ModuleNotFoundError: No module named 'pytest'"

Install test dependencies:
```bash
pip install -r requirements-test.txt
```

### "No tests ran"

Check test discovery:
```bash
pytest --collect-only tests/
```

### Tests Failing on Image Operations

Ensure Pillow is installed:
```bash
pip install Pillow
```

### Permission Errors

Run as administrator or check folder permissions.

## 📚 Resources

- [pytest Documentation](https://docs.pytest.org/)
- [pytest-cov Documentation](https://pytest-cov.readthedocs.io/)
- [Pillow Documentation](https://pillow.readthedocs.io/)

---

**Test-Driven Development:** Write tests first, then implement features!

**Keep tests fast:** Aim for < 1 second per test

**Mock external dependencies:** Don't rely on network or filesystem when possible

**Test edge cases:** Empty inputs, very large values, invalid data
