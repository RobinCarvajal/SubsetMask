import pandas as pd

def get_image_coords(metadata_df, images_col, image_name, x_col, y_col):
    """
    Get the coordinates of a specific image from the metadata DataFrame.
    
    Parameters:
    - metadata_df: DataFrame containing metadata with image names and coordinates.
    - images_col: Column name in the DataFrame that contains image names.
    - image_name: The name of the image to look for.
    - x_col: Column name for x coordinates.
    - y_col: Column name for y coordinates.
    
    Returns:
    - A tuple of (x, y) coordinates if found, otherwise None.
    """
    image_coords_df = metadata_df[metadata_df[images_col] == image_name][[x_col, y_col]]
    
    return image_coords_df

def get_image_dims(metadata_df, images_col, image_name, x_col, y_col):
    """
    Get the coordinates of a specific image from the metadata DataFrame.
    
    Parameters:
    - metadata_df: DataFrame containing metadata with image names and coordinates.
    - images_col: Column name in the DataFrame that contains image names.
    - image_name: The name of the image to look for.
    - x_col: Column name for x coordinates.
    - y_col: Column name for y coordinates.
    
    Returns:
    - A tuple of (x, y) coordinates if found, otherwise None.
    """
    image_coords_df = metadata_df[metadata_df[images_col] == image_name][[x_col, y_col]]

    x_min = image_coords_df[x_col].min()
    y_min = image_coords_df[y_col].min()
    x_max = image_coords_df[x_col].max()
    y_max = image_coords_df[y_col].max()

    if not image_coords_df.empty:
        image_dims_df = {
            "x_min": x_min,
            "y_min": y_min,
            "x_max": x_max,
            "y_max": y_max
        }

    return image_dims_df




def rename_keys(original_dict, key_mapping):
    """
    Rename one or more keys in a dictionary.

    Parameters:
    - original_dict (dict): The original dictionary.
    - key_mapping (dict): Mapping of old_key -> new_key.

    Returns:
    - dict: A new dictionary with renamed keys.

    Raises:
    - KeyError: If any key in key_mapping is not found in original_dict.
    """
    missing_keys = [key for key in key_mapping if key not in original_dict]
    if missing_keys:
        raise KeyError(f"The following keys are not in the original dictionary: {missing_keys}")

    renamed_dict = {}
    for old_key, value in original_dict.items():
        new_key = key_mapping.get(old_key, old_key)
        renamed_dict[new_key] = value

    return renamed_dict



def make_mask_coords_dict(mask_coords_dir):
    mask_coords_dict = {}
    for mask_path in mask_coords_dir.glob("*.csv"):
        if mask_path.name.startswith("._"):
            continue  # Skip macOS invisible files
        mask_name = mask_path.stem  # Get the file name without extension
        coords = pd.read_csv(mask_path)
        mask_coords_dict[mask_name] = coords
    return mask_coords_dict


def save_annotated_metadata(annotated_meta, output_path, keep_cols=None, full_metadata=False):
    """
    Export the annotated metadata DataFrame to a CSV file.
    
    Parameters:
    - annotated_meta: DataFrame containing the annotated metadata.
    - output_path: Path where the CSV file will be saved.
    - keep_cols: String or list of column names to include in the export.
    - full_metadata: Boolean. Must be explicitly True or False.
    """
    if not isinstance(full_metadata, bool):
        raise TypeError("full_metadata must be a boolean (True or False)")

    if full_metadata:
        export_df = annotated_meta
    else:
        if keep_cols is None:
            raise ValueError("keep_cols must be provided when full_metadata is False")

        # Handle string input as a single column
        if isinstance(keep_cols, str):
            if keep_cols not in annotated_meta.columns:
                raise ValueError(f"The column '{keep_cols}' is not in the annotated metadata.")
            keep_cols = [keep_cols]

        # Handle list input
        elif isinstance(keep_cols, list):
            missing_cols = [col for col in keep_cols if col not in annotated_meta.columns]
            if missing_cols:
                raise ValueError(f"The following columns are not in the annotated metadata: {missing_cols}")
        else:
            raise TypeError("keep_cols must be a string or a list of strings.")

        export_df = annotated_meta[keep_cols].copy()

    export_df.to_csv(output_path, index=True)
    print(f"Annotated metadata exported to {output_path}")
