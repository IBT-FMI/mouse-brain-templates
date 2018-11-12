#!/bin/sh

#Resize to same size as dsurqec  atlases
ResampleImage 3 abi_10micron_average.nii.gz abi_15micron_average.nii.gz 0.015x0.015x0.015 size=1 spacing=0 4
fslorient -copyqform2sform abi_15micron_average.nii.gz
ResampleImage 3 abi_10micron_average.nii.gz abi_40_average.nii.gz 0.04x0.04x0.04 size=1 spacing=0 4
fslorient -copyqform2sform abi_40_average.nii.gz
ResampleImage 3 abi_10micron_average.nii.gz abi_200_average.nii.gz 0.2x0.2x0.2 size=1 spacing=0 4
fslorient -copyqform2sform abi_200_average.nii.gz

#Correct resamoling of the annotation files: Use antsAppyTransform with Identity matrix. Multilabel interpolation can be used which is not possible in ResampleImage
antsApplyTransforms -d 3 -e 0 -i abi_10micron_annotation.nii.gz -r abi_15micron_average.nii.gz -o abi_15micron_annotation.nii.gz -n MultiLabel -t Identity
fslorient -copyqform2sform abi_15micron_annotation.nii.gz
antsApplyTransforms -d 3 -e 0 -i abi_10micron_annotation.nii.gz -r abi_40_average.nii.gz -o abi_40_annotation.nii.gz -n MultiLabel -t Identity
fslorient -copyqform2sform abi_40_annotation.nii.gz

# Registration call
antsRegistration \
        --float 1 \
        --collapse-output-transforms 1 \
        --dimensionality 3 \
        --initial-moving-transform [dsurqec_40micron_masked.nii,abi_40_average.nii.gz, 1 ] \
        --initialize-transforms-per-stage 0 --interpolation Linear --output [ abi2dsurqec_, abi2dsurqec_40micron_masked.nii ] \
        --interpolation Linear \
         \
         --transform Rigid[ 0.5 ] \
         --metric MI[dsurqec_40micron_masked.nii,abi_40_average.nii.gz, 1, 64, Random, 0.3 ] \
         --convergence [ 400x400x400x200, 1e-9, 10 ] \
         --smoothing-sigmas 3.0x2.0x1.0x0.0vox \
         --shrink-factors 10x4x2x1 \
         --use-estimate-learning-rate-once 0 \
         --use-histogram-matching 1 \
          \
          --transform Affine[ 0.1 ] \
          --metric MI[dsurqec_40micron_masked.nii,abi_40_average.nii.gz, 1, 64, Regular, 0.3 ] \
          --convergence [ 400x200, 1e-10, 10 ] \
          --smoothing-sigmas 1.0x0.0vox \
          --shrink-factors 2x1 \
          --use-estimate-learning-rate-once 0 \
          --use-histogram-matching 1 \
          \
          --transform SyN[0.1,3,0] \
          --metric CC[dsurqec_40micron_masked.nii,abi_40_average.nii.gz,1,4] \
          --convergence [100x70x50x20,1e-6,10] \
          --shrink-factors 8x4x2x1 \
          --smoothing-sigmas 3x2x1x0vox \
           \
          --winsorize-image-intensities [ 0.05, 0.95 ] \
          --write-composite-transform 1 \
          --verbose

fslorient -copyqform2sform abi2dsurqec_40micron_masked.nii

#Use the composite to transform annotation file
CompositeTransformUtil --disassemble abi2dsurqec_Composite.h5 Dissasembled
WarpImageMultiTransform 3 abi_10micron_annotation.nii.gz abi2dsurqec_40_annotation.nii.gz 01_Dissasembled_DisplacementFieldTransform.nii.gz 00_Dissasembled_AffineTransform.mat -R dsurqec_40micron_masked.nii.gz --use-ML 0.4mm
fslorient -copyqform2sform abi2dsurqec_40_annotation.nii.gz
