#!/usr/bin/env bash

OUTDIR = mouse-brain-templates/

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
	cd code; bash make_mesh.sh -i "${WDIR}/ambmc2dsurqec_15micron.nii" -t 640000 -m "${WDIR}/dsurqec_40micron_mask.nii" -c -s 20 -a 1 -d beginning -b -x

all: ambmc dsurqec abi abi2dsurqec ambmc2dsurqued mesh

publish: all
	@mkdir -p $(OUTDIR)
	cp code/FAIRUSE-AND-CITATION $(OUTDIR)
	cp work/abi2dsurqec_40micron*.nii $(OUTDIR)
	cp work/abi2dsurqec_Composite.h5 $(OUTDIR)
	cp work/abi_{200,40}micron*nii $(OUTDIR)
	cp work/ambmc_{200,40}micron*nii $(OUTDIR)
	cp work/ambmc_{COPYING,README} $(OUTDIR)
	cp work/ambmc_200micron_roi-dr.nii $(OUTDIR)
	cp resources/dsurqe_labels.csv $(OUTDIR)
	cp dsurqec_40micron_labels.nii $(OUTDIR)
	cp dsurqec_{200,40}micron.nii $(OUTDIR)
	cp dsurqec_{200,40}micron_mask.nii $(OUTDIR)
	cp dsurqec_{200,40}micron_masked.nii $(OUTDIR)
	cp work/dsurqec_200micron_roi-dr.nii $(OUTDIR)
	cp work/lambmc_{200,40}micron.nii $(OUTDIR)
	cp work/lambmc_{200,40}micron_mask.nii $(OUTDIR)
	cp work/lambmc_200micron_roi-dr.nii $(OUTDIR)
	cp work/ldsurqec_{200,40}micron_mask.nii $(OUTDIR)
	cp work/ldsurqec_{200.40}micron_masked.nii $(OUTDIR)
	cp work/ldsurqec_200micron_roi-dr.nii $(OUTDIR)

release: code/versioncheck.sh
	$(if $(VERSION),,$(error VERSION is not defined))
	@code/versioncheck.sh $(VERSION)
	tar cJf releases/mouse-brain-templates-${VERSION}.tar.xz mouse-brain-templates/

