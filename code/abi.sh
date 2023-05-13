#!/usr/bin/env bash

source code/functions.sh

# Directories
RDIR="resources/"
WDIR="work/"

get_resource "http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/average_template/average_template_10.nrrd"
get_resource "http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/annotation/ccf_2017/annotation_10.nrrd"

mkdir -p "${WDIR}"

cp "${RDIR}/average_template_10.nrrd" "${WDIR}/abi_10micron_average.nrrd"
cp "${RDIR}/annotation_10.nrrd" "${WDIR}/abi_10micron_annotation.nrrd"

#Convert to Nifti and reorient data matrix from PIR to RAS
python code/nrrd_to_nifti.py || exit 1
