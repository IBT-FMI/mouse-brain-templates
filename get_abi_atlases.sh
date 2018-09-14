#!/usr/bin/env bash

#donwload average template from  ABI Website
wget -O abi_10_average.nrrd http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/average_template/average_template_10.nrrd
wget -O abi_25_average.nrrd http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/average_template/average_template_25.nrrd
wget -O abi_50_average.nrrd http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/average_template/average_template_50.nrrd
wget -O abi_100_average.nrrd http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/average_template/average_template_100.nrrd

#download annotation
wget -O abi_10_annotation.nrrd http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/annotation/ccf_2017/annotation_10.nrrd
wget -O abi_25_annotation.nrrd http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/annotation/ccf_2017/annotation_25.nrrd
wget -O abi_50_annotation.nrrd http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/annotation/ccf_2017/annotation_50.nrrd
get -O abi_100_annotation.nrrd http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/annotation/ccf_2017/annotation_100.nrrd

#Convert Nrrd files to Nifti and reorient Atlas: call Nrrd_Nii.py
python nrrd_to_nifti.py

#Get dsurqec atlases
###wget http://chymera.eu/distfiles/mouse-brain-atlases-0.2.20180719.tar.xz
#:tar xf mouse-brain-atlases-0.2.20180719.tar.xz

#Registration with Ants
#sh AntsReg.sh

