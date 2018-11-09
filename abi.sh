#!/usr/bin/env bash

#donwload average template from  ABI Website
wget -O abi_10_average.nrrd http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/average_template/average_template_10.nrrd

#download annotation
wget -O abi_10_annotation.nrrd http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/annotation/ccf_2017/annotation_10.nrrd

#Convert to Nifti and reorient data matrix from PIR to RAS
python ../nrrd_to_nifti.py

