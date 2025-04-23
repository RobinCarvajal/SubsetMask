# SubsetMask
SubsetMask is a lightweight tool designed to subset spatial transcriptomics data using image masks. It enables researchers to select regions of interest directly from tissue images and integrate these selections into Seurat objects for downstream spatial analysis in R.

Features
Extract spatial coordinates from high-resolution tissue images and masks

Subset Seurat spatial transcriptomics objects based on masked regions

Works independently of cell types or clusters—subset based on visual regions of interest

Simple, reproducible protocol for integrating image-based selections into R workflows

# Use Case
Instead of subsetting spatial transcriptomics data by cell type or cluster, SubsetMask allows users to subset based on specific anatomical zones or regions of interest defined directly on the tissue image (e.g., masked cortical layers, tumor margins, inflammatory zones).

# Workflow Overview
Provide a high-resolution tissue image and an associated binary mask (e.g., a segmented region of interest).

SubsetMask extracts the spatial coordinates within the masked region.

These coordinates are used to subset a Seurat spatial object, enabling targeted analysis of selected areas.

# Installation
Pending

# Use Case
Pending

# Requirements
R >= 4.2.0
Seurat >= 4.3.0
Python >= 3.0
OpenCV (python) >= 4.11.0

# License
This project is currently unlicensed. All rights reserved.
