#!/usr/bin/env bash

source code/functions.sh

# Directories
RDIR="resources/"
WDIR="work/"

#!/bin/bash
get_resource "http://repo.mouseimaging.ca/repo/DSURQE_40micron_nifti/DSURQE_40micron_average.nii"
get_resource "http://repo.mouseimaging.ca/repo/DSURQE_40micron_nifti/DSURQE_40micron_labels.nii"
get_resource "http://repo.mouseimaging.ca/repo/DSURQE_40micron_nifti/DSURQE_40micron_mask.nii"
get_resource "http://resources.chymera.eu/distfiles/dsurqe_labels.csv"

mkdir -p "${WDIR}"

cp "${RDIR}/DSURQE_40micron_average.nii" "${WDIR}/dsurqec_40micron.nii"
cp "${RDIR}/DSURQE_40micron_labels.nii" "${WDIR}/dsurqec_40micron_labels.nii"
cp "${RDIR}/DSURQE_40micron_mask.nii" "${WDIR}/dsurqec_40micron_mask.nii"

# Workaround required due to dataladification :(
# https://github.com/datalad/datalad/issues/7408
chmod 664 "${WDIR}/dsurqec_40micron{,labels,mask}.nii"


# Set FSL Variable
OLD_FSLOUTPUTTYPE=$FSLOUTPUTTYPE
FSLOUTPUTTYPE=NIFTI

pushd "${WDIR}"
	# Set origin to Paxinos Bregma
	fslorient -setsform 0.04 0 0 -6.27 0 0.04 0 -10.6 0 0 0.04 -7.88 0 0 0 1 dsurqec_40micron.nii
	fslorient -copysform2qform dsurqec_40micron.nii
	fslorient -setsform 0.04 0 0 -6.27 0 0.04 0 -10.6 0 0 0.04 -7.88 0 0 0 1 dsurqec_40micron_labels.nii
	fslorient -copysform2qform dsurqec_40micron_labels.nii
	fslorient -setsform 0.04 0 0 -6.27 0 0.04 0 -10.6 0 0 0.04 -7.88 0 0 0 1 dsurqec_40micron_mask.nii
	fslorient -copysform2qform dsurqec_40micron_mask.nii

	# Resize
	# We do not resize the labels image to avoid ROI assignment degradation.
	# Please use the original labels map even with lower resolution data.
	ResampleImage 3 dsurqec_40micron.nii _dsurqec_200micron.nii 0.2x0.2x0.2 0 0 4
	SmoothImage 3 _dsurqec_200micron.nii 0.4 dsurqec_200micron.nii
	fslorient -copyqform2sform dsurqec_200micron.nii
	ResampleImage 3 dsurqec_40micron_mask.nii dsurqec_200micron_mask.nii 0.2x0.2x0.2 0 0 1
	fslorient -copyqform2sform dsurqec_200micron_mask.nii

	# Apply Masks
	fslmaths 'dsurqec_40micron.nii' -mas 'dsurqec_40micron_mask.nii' 'dsurqec_40micron_masked.nii'
	fslmaths 'dsurqec_200micron.nii' -mas 'dsurqec_200micron_mask.nii' 'dsurqec_200micron_masked.nii'

	# Make Legacy AMBMC analogue
	fslswapdim dsurqec_200micron_masked.nii x -y z ldsurqec_200micron_masked.nii
	fslorient -deleteorient ldsurqec_200micron_masked.nii
	fslchpixdim ldsurqec_200micron_masked.nii 2.0 2.0 2.0
	fslorient -copyqform2sform ldsurqec_200micron_masked.nii
	fslswapdim dsurqec_200micron_mask.nii x -y z ldsurqec_200micron_mask.nii
	fslorient -deleteorient ldsurqec_200micron_mask.nii
	fslchpixdim ldsurqec_200micron_mask.nii 2.0 2.0 2.0
	fslorient -copyqform2sform ldsurqec_200micron_mask.nii

	fslswapdim dsurqec_40micron_masked.nii x -y z ldsurqec_40micron_masked.nii
	fslorient -deleteorient ldsurqec_40micron_masked.nii
	fslchpixdim ldsurqec_40micron_masked.nii 0.4 0.4 0.4
	fslorient -copyqform2sform ldsurqec_40micron_masked.nii
	fslswapdim dsurqec_40micron_mask.nii x -y z ldsurqec_40micron_mask.nii
	fslorient -deleteorient ldsurqec_40micron_mask.nii
	fslchpixdim ldsurqec_40micron_mask.nii 0.4 0.4 0.4
	fslorient -copyqform2sform ldsurqec_40micron_mask.nii

	# Cleanup
	rm _dsurqec_200micron.nii
popd

# Reset FSL Variable
FSLOUTPUTTYPE=$OLD_FSLOUTPUTTYPE
