#!/usr/bin/env bash

# Set FSL Variable
OLD_FSLOUTPUTTYPE=$FSLOUTPUTTYPE
FSLOUTPUTTYPE=NIFTI

# Download Upstream Template
wget http://imaging.org.au/uploads/AMBMC/ambmc-c57bl6-model-symmet_v0.8-nii.tar.gz
tar xvzf ambmc-c57bl6-model-symmet_v0.8-nii.tar.gz
cp ambmc-c57bl6-model-symmet_v0.8-nii/ambmc-c57bl6-model-symmet_v0.8.nii _ambmc_15micron.nii
cp ambmc-c57bl6-model-symmet_v0.8-nii/COPYING ambmc_COPYING
cp ambmc-c57bl6-model-symmet_v0.8-nii/README ambmc_README
THRESHOLD=$(fslstats _ambmc_15micron.nii -P 77)

# Multiple Sizes
ResampleImage 3 _ambmc_15micron.nii __ambmc_40micron.nii 0.04x0.04x0.04 size=1 spacing=0 4
SmoothImage 3 __ambmc_40micron.nii 0.08 _ambmc_40micron.nii
rm __ambmc_40micron.nii
ResampleImage 3 _ambmc_15micron.nii __ambmc_200micron.nii 0.2x0.2x0.2 size=1 spacing=0 4
SmoothImage 3 __ambmc_200micron.nii 0.4 _ambmc_200micron.nii
fslmaths _ambmc_200micron.nii -thr ${THRESHOLD} -bin __ambmc_200micron_mask.nii
fslmaths '_ambmc_200micron.nii' -mas '__ambmc_200micron_mask.nii' _ambmc_200micron.nii

# Legacy Header Manipulation
cp _ambmc_15micron.nii lambmc_15micron.nii
fslorient -deleteorient lambmc_15micron.nii
fslchpixdim lambmc_15micron.nii 0.15 0.15 0.15
cp _ambmc_40micron.nii lambmc_40micron.nii
fslorient -deleteorient lambmc_40micron.nii
fslchpixdim lambmc_40micron.nii 0.4 0.4 0.4
cp _ambmc_200micron.nii lambmc_200micron.nii
fslorient -deleteorient lambmc_200micron.nii
fslchpixdim lambmc_200micron.nii 2 2 2

# Make RAS
fslswapdim _ambmc_15micron.nii x -y z ambmc_15micron.nii
fslorient -setsform 0.015 0 0 -5.094 0 0.015 0 -9.8355 0 0 0.015 -3.726 0 0 0 1 ambmc_15micron.nii
fslorient -copysform2qform ambmc_15micron.nii
fslswapdim _ambmc_40micron.nii x -y z ambmc_40micron.nii
fslorient -setsform 0.04 0 0 -5.094 0 0.04 0 -9.8355 0 0 0.04 -3.726 0 0 0 1 ambmc_40micron.nii
fslorient -copysform2qform ambmc_40micron.nii
fslswapdim _ambmc_200micron.nii x -y z ambmc_200micron.nii
fslorient -setsform 0.2 0 0 -5.0944 0 0.2 0 -9.8355 0 0 0.2 -3.726 0 0 0 1 ambmc_200micron.nii
fslorient -copysform2qform ambmc_200micron.nii

# Make Masks, with atlas specific threshold (background is 191919).
# This does not include ambmc_200micron.nii, as this was masked earlier.
mv __ambmc_200micron_mask.nii ambmc_200micron_mask.nii
fslmaths ambmc_40micron.nii -thr ${THRESHOLD} -bin ambmc_40micron_mask.nii
fslmaths ambmc_15micron.nii -thr ${THRESHOLD} -bin ambmc_15micron_mask.nii
fslmaths lambmc_200micron.nii -thr ${THRESHOLD} -bin lambmc_200micron_mask.nii
fslmaths lambmc_40micron.nii -thr ${THRESHOLD} -bin lambmc_40micron_mask.nii
fslmaths lambmc_15micron.nii -thr ${THRESHOLD} -bin lambmc_15micron_mask.nii

# Cleanup
rm -rf ambmc-c57bl6-model-symmet_v0.8-nii*
rm -rf _*ambmc*nii*
