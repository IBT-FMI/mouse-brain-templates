#!/usr/bin/env bash

# Set FSL Variable
OLD_FSLOUTPUTTYPE=(echo $FSLOUTPUTTYPE)
FSLOUTPUTTYPE=NIFTI

# Download Upstream Template
wget http://imaging.org.au/uploads/AMBMC/ambmc-c57bl6-model-symmet_v0.8-nii.tar.gz
tar xvzf ambmc-c57bl6-model-symmet_v0.8-nii.tar.gz
cp ambmc-c57bl6-model-symmet_v0.8-nii/ambmc-c57bl6-model-symmet_v0.8.nii ambmc_15micron.nii
cp ambmc-c57bl6-model-symmet_v0.8-nii/COPYING ambmc_COPYING
cp ambmc-c57bl6-model-symmet_v0.8-nii/README ambmc_README

# Multiple Sizes
ResampleImage 3 ambmc_15micron.nii _ambmc_40micron.nii 0.04x0.04x0.04 size=1 spacing=0 4
SmoothImage 3 _ambmc_40micron.nii 0.16 ambmc_40micron.nii
rm _ambmc_40micron.nii
ResampleImage 3 ambmc_15micron.nii _ambmc_200micron.nii 0.2x0.2x0.2 size=1 spacing=0 4
SmoothImage 3 _ambmc_200micron.nii 0.8 ambmc_200micron.nii
fslmaths ambmc_200micron.nii -thr $(fslstats ambmc_200micron.nii -P 77) -bin _ambmc_200micron_mask.nii
fslmaths 'ambmc_200micron.nii' -mas '_ambmc_200micron_mask.nii' ambmc_200micron.nii
rm _ambmc_200micron.nii
rm _ambmc_200micron_mask.nii

# Legacy Header Manipulation
cp ambmc_15micron.nii lambmc_15micron.nii
fslorient -deleteorient lambmc_15micron.nii
fslchpixdim lambmc_15micron.nii 0.15 0.15 0.15
cp ambmc_40micron.nii lambmc_40micron.nii
fslorient -deleteorient lambmc_40micron.nii
fslchpixdim lambmc_40micron.nii 0.4 0.4 0.4
cp ambmc_200micron.nii lambmc_200micron.nii
fslorient -deleteorient lambmc_200micron.nii
fslchpixdim lambmc_200micron.nii 2 2 2

# Cleanup
rm -rf ambmc-c57bl6-model-symmet_v0.8-nii*
