#!/bin/sh

# Directories
WDIR="work/"

pushd ${WDIR}
	#Resize to same size as dsurqec templates
	#ResampleImage 3 abi_10micron_average.nii abi_15micron_average.nii 0.015x0.015x0.015 size=1 spacing=0 4
	ResampleImage 3 abi_10micron_average.nii abi_15micron_average.nii 0.015x0.015x0.015 0 0 4
	fslorient -copyqform2sform abi_15micron_average.nii
	#ResampleImage 3 abi_10micron_average.nii abi_40micron_average.nii 0.04x0.04x0.04 size=1 spacing=0 4
	ResampleImage 3 abi_10micron_average.nii abi_40micron_average.nii 0.04x0.04x0.04 0 0 4
	fslorient -copyqform2sform abi_40micron_average.nii
	#ResampleImage 3 abi_10micron_average.nii abi_200micron_average.nii 0.2x0.2x0.2 size=1 spacing=0 4
	ResampleImage 3 abi_10micron_average.nii abi_200micron_average.nii 0.2x0.2x0.2 0 0 4
	fslorient -copyqform2sform abi_200micron_average.nii

	#Correct resamoling of the annotation files: Use antsAppyTransform with Identity matrix. Multilabel interpolation can be used which is not possible in ResampleImage
	echo "lala"
	antsApplyTransforms -d 3 -e 0 -i abi_10micron_annotation.nii -r abi_15micron_average.nii -o abi_15micron_annotation.nii -n MultiLabel -t Identity
	echo "lele"
	fslorient -copyqform2sform abi_15micron_annotation.nii
	echo "lili"
	antsApplyTransforms -d 3 -e 0 -i abi_10micron_annotation.nii -r abi_40micron_average.nii -o abi_40micron_annotation.nii -n MultiLabel -t Identity
	echo "lolo"
	fslorient -copyqform2sform abi_40micron_annotation.nii

	# Registration call
	antsRegistration \
		--float 1 \
		--collapse-output-transforms 1 \
		--dimensionality 3 \
		--initial-moving-transform [dsurqec_40micron_masked.nii,abi_40micron_average.nii, 1 ] \
		--initialize-transforms-per-stage 0 --interpolation Linear --output [ abi2dsurqec_, abi2dsurqec_40micron_masked.nii ] \
		--interpolation Linear \
		\
		--transform Rigid[ 0.5 ] \
		--metric MI[dsurqec_40micron_masked.nii,abi_40micron_average.nii, 1, 64, Random, 0.3 ] \
		--convergence [ 400x400x400x200, 1e-9, 10 ] \
		--smoothing-sigmas 3.0x2.0x1.0x0.0vox \
		--shrink-factors 10x4x2x1 \
		--use-histogram-matching 1 \
		\
		--transform Affine[ 0.1 ] \
		--metric MI[dsurqec_40micron_masked.nii,abi_40micron_average.nii, 1, 64, Regular, 0.3 ] \
		--convergence [ 400x200, 1e-10, 10 ] \
		--smoothing-sigmas 1.0x0.0vox \
		--shrink-factors 2x1 \
		--use-histogram-matching 1 \
		\
		--transform SyN[0.1,3,0] \
		--metric CC[dsurqec_40micron_masked.nii,abi_40micron_average.nii,1,4] \
		--convergence [100x70x50x20,1e-6,10] \
		--shrink-factors 8x4x2x1 \
		--smoothing-sigmas 3x2x1x0vox \
		\
		--winsorize-image-intensities [ 0.05, 0.95 ] \
		--write-composite-transform 1 \
		--verbose

	fslorient -copyqform2sform abi2dsurqec_40micron_masked.nii

	#Use the composite to transform annotation file

	antsApplyTransforms -d 3 -i abi_10micron_annotation.nii -r dsurqec_40micron_masked.nii -o abi2dsurqec_40_annotation.nii -t abi2dsurqec_Composite.h5 -n MultiLabel
	fslorient -copyqform2sform abi2dsurqec_40_annotation.nii

	### Cleanup
	## rm abi2dsurqec_InverseComposite.h5
popd
