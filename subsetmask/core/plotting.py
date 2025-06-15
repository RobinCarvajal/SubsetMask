import matplotlib.pyplot as plt

def save_image(metadata_df, images_col, image_name, x_col, y_col, output_path,
               group_col=None, figsize=(30, 50), dpi=1200, dot_size=1, cmap='tab20'):
    """
    Plot a dot map from spatial coordinates, optionally colored by a group column, and save to file.

    Parameters:
    - metadata_df: DataFrame with spatial metadata.
    - images_col: Column indicating the image name.
    - image_name: Specific image to plot.
    - x_col: Name of x-coordinate column.
    - y_col: Name of y-coordinate column.
    - group_col: Optional column to color dots by (categorical). If None, dots are black.
    - output_path: Path to save the image.
    - figsize: Figure size in inches.
    - dpi: Dots per inch (resolution).
    - dot_size: Dot size for scatter.
    - cmap: Matplotlib colormap (used only if group_col is provided).
    """
    # Filter for specific image
    image_metadata_df = metadata_df[metadata_df[images_col] == image_name]

    fig, ax = plt.subplots(figsize=figsize, dpi=dpi)

    if group_col is not None and group_col in image_metadata_df.columns:
        # Color by group
        color_values = image_metadata_df[group_col].astype('category').cat.codes
        scatter_kwargs = dict(c=color_values, cmap=cmap)
    else:
        # Plot all black
        scatter_kwargs = dict(c='black')

    # Plot dots
    ax.scatter(
        image_metadata_df[x_col],
        image_metadata_df[y_col],
        s=dot_size,
        marker='.',
        alpha=1,
        **scatter_kwargs
    )

    ax.set_xlim(image_metadata_df[x_col].min(), image_metadata_df[x_col].max())
    ax.set_ylim(image_metadata_df[y_col].min(), image_metadata_df[y_col].max())
    ax.axis("off")
    plt.margins(0)
    plt.subplots_adjust(left=0, right=1, top=1, bottom=0)

    plt.savefig(output_path, bbox_inches='tight', pad_inches=0, dpi=300)
    plt.close()
