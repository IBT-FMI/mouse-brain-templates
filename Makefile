#!/usr/bin/env bash

# This makefile will reexecute targets even if the output workfiles exist.
# Given how time-consuming the ANTs parts are in particular this leads to a lot of wasted time.
# The efficiency of the code could be improved by using pattern rules:
# https://www.cmcrossroads.com/article/rules-multiple-outputs-gnu-make

OUTDIR = mouse-brain-templates/
WDIR = work/

ambmc: code/ambmc.sh
	bash code/ambmc.sh

dsurqec: code/dsurqec.sh
	bash code/dsurqec.sh

abi: code/abi.sh
	bash code/abi.sh

abi2dsurqec: abi dsurqec code/abi2dsurqec_40micron.sh
	bash code/abi2dsurqec_40micron.sh

ambmc2dsurqec: ambmc dsurqec code/abi2dsurqec_40micron.sh
	bash code/ambmc2dsurqec.sh

roi: code/roi.sh
	bash code/roi.sh

mesh: ambmc2dsurqec code/make_mesh.sh code/make_mesh.py code/decimate_mesh_blender.py
	cd code; bash make_mesh.sh -i "../${WDIR}ambmc2dsurqec_15micron.nii" -t 640000 -m "../${WDIR}dsurqec_40micron_mask.nii" -c -s 20 -a 1 -d beginning -b -x

all: ambmc dsurqec abi abi2dsurqec ambmc2dsurqec roi mesh

copy:
	@mkdir -p $(OUTDIR)
	rm mouse-brain-templates/* -rf
	cp code/FAIRUSE-AND-CITATION $(OUTDIR)
	cp work/abi2dsurqec_40micron*.nii $(OUTDIR)
	cp work/abi2dsurqec_Composite.h5 $(OUTDIR)
	cp work/abi_{200,40}micron*nii $(OUTDIR)
	cp work/ambmc_{200,40}micron{_mask,}.nii $(OUTDIR)
	cp work/ambmc_{COPYING,README} $(OUTDIR)
	cp work/ambmc_200micron_roi-dr.nii $(OUTDIR)
	cp resources/dsurqe_labels.csv $(OUTDIR)
	cp work/dsurqec_40micron_labels.nii $(OUTDIR)
	cp work/dsurqec_{200,40}micron.nii $(OUTDIR)
	cp work/dsurqec_{200,40}micron_mask.nii $(OUTDIR)
	cp work/dsurqec_{200,40}micron_masked.nii $(OUTDIR)
	cp work/dsurqec_200micron_roi-dr.nii $(OUTDIR)
	cp work/lambmc_{200,40}micron.nii $(OUTDIR)
	cp work/lambmc_{200,40}micron_mask.nii $(OUTDIR)
	cp work/lambmc_200micron_roi-dr.nii $(OUTDIR)
	cp work/ldsurqec_{200,40}micron_mask.nii $(OUTDIR)
	cp work/ldsurqec_{200,40}micron_masked.nii $(OUTDIR)
	cp work/ldsurqec_200micron_roi-dr.nii $(OUTDIR)
	cp work/ambmc2dsurqec_15micron_masked.obj $(OUTDIR)
	cp work/abi_15micron_annotation.nii $(OUTDIR)
	cp work/abi_15micron_average.nii $(OUTDIR)
	cp work/ambmc2dsurqec_15micron_masked.nii $(OUTDIR)
	cp work/ambmc_15micron.nii $(OUTDIR)
	cp work/ambmc_15micron_mask.nii $(OUTDIR)
	cp work/lambmc_15micron.nii $(OUTDIR)
	cp work/lambmc_15micron_mask.nii $(OUTDIR)
	@chmod -R 664 mouse-brain-templates/*

publish: all copy

release: code/versioncheck.sh
	$(if $(VERSION),,$(error VERSION is not defined))
	@code/versioncheck.sh $(VERSION)
	tar cJf releases/mouse-brain-templates-${VERSION}.tar.xz mouse-brain-templates/

clean:
	rm work/ -rf
