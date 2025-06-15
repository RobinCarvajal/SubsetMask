## 📦 Installation Guide for **SubsetMask**

SubsetMask is a lightweight toolkit for coordinate-based subsetting of spatial transcriptomics datasets, with support for interactive region selection.

---

### 🔧 Option 1: Install from local folder (downloaded or cloned)

#### ✅ Step-by-step

1. **Clone or download the repository**:

```bash
git clone https://github.com/RobinCarvajal/SubsetMask.git
```

Or [download the ZIP](https://github.com/yourusername/SubsetMask/archive/refs/heads/main.zip) and unzip it.

2. **Navigate into the project directory**:

```bash
cd SubsetMask
```

3. **Install the package**:

Regular install:

```bash
pip install .
```

Or editable/development install:

```bash
pip install -e .
```

---

### 📋 Requirements

SubsetMask requires:

* Python 3.11+
* `pandas`, `numpy`, `geopandas`, `shapely`, `opencv-python`, `matplotlib`, `imageio`, `napari`

If not using `pyproject.toml`, you can install dependencies manually:

```bash
pip install -r requirements.txt
```

---

### 🔍 Verifying the installation

After installation, you should be able to run:

```python
from subsetmask import core
```

---

### 📚 Getting Started

Check out `tutorial.ipynb` for example usage.

---

Would you like this as a separate `INSTALL.md` file, or merged into your `README.md` under an “Installation” section?
