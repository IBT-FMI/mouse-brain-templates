#!/usr/bin/env bash

source code/functions.sh

# Directories
RDIR="resources/"
WDIR="work/"

# Download Upstream Template
get_resource "http://resources.chymera.eu/distfiles/ambmc_200micron_roi-dr.nii"
get_resource "http://resources.chymera.eu/distfiles/dsurqec_200micron_roi-dr.nii"
cp "${RDIR}/ambmc_200micron_roi-dr.nii" ${WDIR}
cp "${RDIR}/dsurqec_200micron_roi-dr.nii" ${WDIR}


# Set FSL Variable
OLD_FSLOUTPUTTYPE=$FSLOUTPUTTYPE
FSLOUTPUTTYPE=NIFTI

# Make legacy versions
pushd ${WDIR}
	fslswapdim ambmc_200micron_roi-dr.nii x -y z lambmc_200micron_roi-dr.nii
	echo "A"
	fslorient -deleteorient lambmc_200micron_roi-dr.nii
	echo "B"
	fslchpixdim lambmc_200micron_roi-dr.nii 2.0 2.0 2.0
	echo "C"
	fslswapdim dsurqec_200micron_roi-dr.nii x -y z ldsurqec_200micron_roi-dr.nii
	echo "D"
	fslorient -deleteorient ldsurqec_200micron_roi-dr.nii
	echo "E"
	fslchpixdim ldsurqec_200micron_roi-dr.nii 2.0 2.0 2.0
	echo "F"
popd

FSLOUTPUTTYPE=$OLD_FSLOUTPUTTYPE

## Cleanup
#rm -rf mouse-brain-atlases_rois_source*
