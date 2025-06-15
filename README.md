
# SubsetMask (v0)

**SubsetMask** is a lightweight toolkit designed to help researchers subset Spatially Resolved Transcriptomics (SRT) data objects—such as those from **CosMx** and **Xenium** platforms. It can be applied to any transcriptomics dataset that includes spatial coordinate metadata (`x`, `y`), making it broadly useful across SRT technologies.

## Features

* Easy subsetting of transcriptomic data based on spatial coordinates
* Compatible with CosMx, Xenium, or any other SRT dataset with (x, y) coordinates
* Modular and scriptable for integration into spatial analysis workflows
* Designed with reproducibility and simplicity in mind

## Installation

To install the latest development version from GitHub:

```bash
pip install git+https://github.com/yourusername/SubsetMask.git
```

## Usage Example

```python
from subsetmask import apply_mask_to_coordinates

# Example: apply a polygon mask to a dataset
masked_data = apply_mask_to_coordinates(dataframe, polygon_coords)
```

## Requirements

* geopandas==1.1.0
* imageio==2.37.0
* matplotlib==3.10.3
* napari==0.6.1
* numpy==2.3.0
* opencv_python==4.11.0.86
* pandas==2.3.0
* Shapely==2.1.1

## Project Structure

```
SubsetMask/
├── subsetmask/        # Core package code (with __init__.py)
│   ├── core.py
│   ├── utils.py
├── tests/             # Unit tests
├── Tutorial.ipynb     # Example notebook with real-world usage
├── pyproject.toml     # Package configuration
├── README.md
├── LICENSE.txt
```

## Contributing

Contributions, issues, and feature requests are welcome. Please open a pull request or submit an issue on GitHub.

## License

This project is licensed under the MIT License.
