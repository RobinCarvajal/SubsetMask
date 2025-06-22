###-- IMPORTS --###
import pandas as pd
from subsetmask.image_helpers import store_image_as_array
from subsetmask.image_helpers import draw_labels
from subsetmask.image_helpers import labels_to_masks_dict
from subsetmask.image_helpers import get_mask_coords_from_dict
from subsetmask.image_helpers import get_cell_names
from subsetmask.image_helpers import annotate_metadata

###--- CLASS --###
class Image:
    def __init__(self, metadata_df, images_col, image_name, x_col, y_col):
        self._metadata_df = metadata_df
        self._images_col = images_col
        self._image_name = image_name
        self._x_col = x_col
        self._y_col = y_col

        self._image_metadata = metadata_df[metadata_df[images_col] == image_name].copy()
        self._image_coords = self._image_metadata[[x_col, y_col]].copy()
        self._image_dims = self._image_metadata[[x_col, y_col]].agg(['min', 'max']).to_dict(orient='list')
        self._image_array = None  # Will be set by get_image_array()
        self._labels_layer = None
        self._masks_dict = {}

    @property
    def image_metadata(self):
        return self._image_metadata

    @property
    def image_coords(self):
        return self._image_coords

    @property
    def image_array(self):
        return self._image_array
    
    @property
    def masks_dict(self):
        return self._masks_dict
    @property
    def coords_dict(self):
        return self._coords_dict
    @property
    def subset_cells(self):
        return self._subset_cells
    @property
    def annotated_metadata_df(self):
        return self._annotated_metadata_df

    def __repr__(self):
        return f"ImageData(n={len(self._image_metadata)}, columns={list(self._image_metadata.columns)})"

    def store_image(self, group_col=None, figsize=(30, 50), dpi=300, dot_size=5, cmap='tab20'):
        """
        Generate and store the image array based on the current state of the object.
        """
        self._image_array = store_image_as_array(
            metadata_df=self._metadata_df,
            images_col=self._images_col,
            image_name=self._image_name,
            x_col=self._x_col,
            y_col=self._y_col,
            group_col=group_col,
            figsize=figsize,
            dpi=dpi,
            dot_size=dot_size,
            cmap=cmap
        )
        return self._image_array

    def draw_labels(self):
        
        self._labels_layer = draw_labels(self._image_array)

        return self._labels_layer
    
    def save_annotations(self, ann_col_name="label"):

        if self._labels_layer is None:
            raise ValueError("No labels to save. Run draw_labels() first.")

        # convert the labels layer to a dictionary of masks
        self._masks_dict = labels_to_masks_dict(labels_layer=self._labels_layer)
    
        # get the coordinates from the masks
        mask_coords = get_mask_coords_from_dict(
            mask_dict=self._masks_dict,
            x_min=self._image_dims[self._x_col][0],
            x_max=self._image_dims[self._x_col][1],
            y_min=self._image_dims[self._y_col][0],
            y_max=self._image_dims[self._y_col][1]
        )

        # get the cell names from the image coordinates and mask coordinates
        subset_cells = get_cell_names(
            image_coords=self._image_coords,
            x_name=self._x_col,
            y_name=self._y_col,
            mask_coords_dict=mask_coords
        )

        # annotate the metadata DataFrame with the cell names
        self._annotated_metadata_df = annotate_metadata(
            cell_names_dict=subset_cells,
            #metadata_df=self._image_metadata,
            metadata_df=self._metadata_df,
            ann_col_name=ann_col_name
        )
        return self._annotated_metadata_df

    def rename_annotations(self, ann_col_name, mapping_dict):
        
        if ann_col_name in self._annotated_metadata_df.columns:
            self._annotated_metadata_df[ann_col_name] = self._annotated_metadata_df[ann_col_name].replace(mapping_dict)
        return self._annotated_metadata_df
