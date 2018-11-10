#!/usr/bin/env bash

# Set FSL Variable
OLD_FSLOUTPUTTYPE=$FSLOUTPUTTYPE
FSLOUTPUTTYPE=NIFTI

# Download Upstream Template
wget http://chymera.eu/distfiles/mouse-brain-atlases_rois_source.tar.xz
tar xf mouse-brain-atlases_rois_source.tar.xz

# Copy base ROIs
cp mouse-brain-atlases_rois_source/*nii .

# Make legacy versions
fslswapdim ambmc_200micron_roi-dr.nii x -y z lambmc_200micron_roi-dr.nii
fslorient -deleteorient lambmc_200micron_roi-dr.nii
fslchpixdim lambmc_200micron_roi-dr.nii 2.0 2.0 2.0
fslswapdim dsurqec_200micron_roi-dr.nii x -y z ldsurqec_200micron_roi-dr.nii
fslorient -deleteorient ldsurqec_200micron_roi-dr.nii
fslchpixdim ldsurqec_200micron_roi-dr.nii 2.0 2.0 2.0

# Cleanup
rm -rf mouse-brain-atlases_rois_source*
