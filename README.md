[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.18516798.svg)](https://doi.org/10.5281/zenodo.18516798)

# SubsetMask

**SubsetMask** is a lightweight toolkit designed to help researchers subset Spatially Resolved Transcriptomics (SRT) data objects—such as those from **CosMx** and **Xenium** platforms. It can be applied to any transcriptomics dataset that includes spatial coordinate metadata (`x`, `y`), making it broadly useful across SRT technologies.

## Features

* Easy subsetting of transcriptomic data based on spatial coordinates
* Compatible with CosMx, Xenium, or any other SRT dataset with (x, y) coordinates
* Modular and scriptable for integration into spatial analysis workflows
* Designed with reproducibility and simplicity in mind

## Documentation

You can find detailed documentation at: [https://robincarvajal.github.io/SubsetMask/](https://robincarvajal.github.io/SubsetMask/)


## Installation

To install the latest development version from GitHub:

```bash
pip install git+https://github.com/RobinCarvajal/SubsetMask.git
```

## Usage Example

```python
import pandas as pd
import subsetmask as sm

# Load the metadata CSV file
meta = pd.read_csv("test/metadata.csv", index_col=0, header=0) 

# test
image = sm.Image(metadata_df=meta, 
                  images_col='slide',
                  image_name='slide_1',
                  x_col='x_slide_mm',
                  y_col='y_slide_mm')

# addd store image method
image.store_image(group_col=None, figsize=(30, 50), dpi=300, dot_size=5, cmap='tab20')

# launches napari with the generated image
image.draw_labels()

# without closing napari we run this line to save the annotations
image.save_annotations(ann_col_name="new_col")

# we change our annotations for something more meaningful
map = {
    "label_1": "sample_1",
    "label_2": "sample_2"
}

image.rename_annotations(ann_col_name="new_col", mapping_dict=map)

# we extract the annotated df from the object
annotated_meta = image.annotated_metadata_df

# now just save the annotated metadata
annotated_meta.to_csv("test/metadata_with_labels.csv")

```

## Requirements

* python==3.10
* pyqt5==5.15.11
* geopandas==1.1.0
* imageio==2.37.0
* matplotlib==3.10.3
* napari==0.6.1
* numpy==1.6.0
* opencv_python==4.11.0.86
* pandas==2.3.0
* Shapely==2.0.6

## Project Structure

```

SubsetMask/
├── subsetmask/        # Core package code (with __init__.py)
│   ├── image_class.py
│   ├── image_helpers.py
├── docs/              # Documentation
├── pyproject.toml     # Package configuration
├── README.md
├── LICENSE.txt

```

## Contributing

Contributions, issues, and feature requests are welcome. Please open a pull request or submit an issue on GitHub.

## License

This project is licensed under the GPL-3.0 License.
