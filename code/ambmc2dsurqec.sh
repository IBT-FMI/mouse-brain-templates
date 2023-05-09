#!/bin/bash

# Directories
WDIR="work/"

pushd ${WDIR}
	# Resize
	#ResampleImage 3 dsurqec_40micron_masked.nii _dsurqec_15micron_masked.nii 0.015x0.015x0.015 size=1 spacing=0 4
	ResampleImage 3 dsurqec_40micron_masked.nii _dsurqec_15micron_masked.nii 0.015x0.015x0.015 0 0 4
	SmoothImage 3 _dsurqec_15micron_masked.nii 0.4 dsurqec_15micron_masked.nii
	fslorient -copyqform2sform dsurqec_15micron_masked.nii
	rm _dsurqec_15micron_masked.nii

	#Run AntsRegisatr
	antsAI -d 3 -v \
			--transform Rigid[ 0.5 ] \
			--metric MI[dsurqec_15micron_masked.nii,ambmc_15micron.nii, 1, 64, Random, 0.1 ] \
			exit 1

	# Registration call

	#SyN registration restricted to 3 Levels and never at full resolution (shrink factor 1, smooothing sigmas 0). This will not affect size of output file,
	#but the final displacement field (.h5 file) will not be the correct size. If needed, add a token iteration at full resolution. This will increase memory consumption considerably.
	antsRegistration \
		--float 1 \
		--collapse-output-transforms 1 \
		--dimensionality 3 \
		--initial-moving-transform [dsurqec_15micron_masked.nii,ambmc_15micron.nii, 1 ] \
		--initialize-transforms-per-stage 0 --interpolation Linear --output [ ambmc2dsurqec_, ambmc2dsurqec_15micron.nii ] \
		--interpolation Linear \
		\
		--transform Rigid[ 0.5 ] \
		--metric MI[dsurqec_15micron_masked.nii,ambmc_15micron.nii, 1, 64, Random, 0.1 ] \
		--convergence [ 400x400x400x200, 1e-9, 10 ] \
		--smoothing-sigmas 3.0x2.0x1.0x0.0vox \
		--shrink-factors 10x4x2x1 \
		--use-histogram-matching 1 \
		\
		--transform Affine[ 0.1 ]\
		--metric MI[dsurqec_15micron_masked.nii,ambmc_15micron.nii, 1, 64, Regular, 0.1 ] \
		--convergence [ 400x200, 1e-10, 10 ] \
		--smoothing-sigmas 1.0x0.0vox \
		--shrink-factors 2x1 \
		--use-histogram-matching 1 \
		\
		--transform SyN[0.25,3,0] \
		--metric CC[dsurqec_15micron_masked.nii,ambmc_15micron.nii,1,4] \
		--convergence [100x70x50,1e-6,10] \
		--shrink-factors 8x4x2 \
		--smoothing-sigmas 3x2x1vox \
		\
		--winsorize-image-intensities [ 0.05, 0.95 ] \
		--write-composite-transform 1 \
		--verbose

	fslorient -copyqform2sform ambmc2dsurqec_15micron.nii

	#apply mask
	#ResampleImage 3 dsurqec_40micron_mask.nii dsurqec_15micron_mask.nii 0.015x0.015x0.015 size=1 spacing=0 1
	ResampleImage 3 dsurqec_40micron_mask.nii dsurqec_15micron_mask.nii 0.015x0.015x0.015 0 0 1
	fslmaths ambmc2dsurqec_15micron.nii -mas dsurqec_15micron_mask.nii ambmc2dsurqec_15micron_masked.nii
	gunzip ambmc2dsurqec_15micron_masked.nii.gz

	# Remove files
	#rm dsurqec_15micron_mask.nii
	#rm ambmc2dsurqec_15micron.nii
	#rm ambmc2dsurqec_Composite.h5
	#rm ambmc2dsurqec_InverseComposite.h5
popd


