import os
from glob import glob
import nrrd
import nibabel
import numpy as np
import sys
import logging as lg

WDIR="work/"

path = os.path.abspath('.')
files = glob(os.path.join(WDIR,'*.nrrd'))


for file in files:
	lg.info(f"Reading \`{file}\`.")
	readnrrd = nrrd.read(file)
	data = readnrrd[0]
	header = readnrrd[1]

	lg.info(f"Converting \`{file}\`.")

	#space = header['space'].split("-")
	affine_matrix = np.array(header["space directions"],dtype=np.cfloat)
	#if space[0] == 'left':
	#affine_matrix[0,0] = affine_matrix[0,0] * (-1)
	#if space[1] == 'posterior':
	#affine_matrix[1,1] = affine_matrix[1,1] * (-1)
	#Units?
	affine_matrix = affine_matrix*0.001

	affine_matrix = np.insert(affine_matrix,3,[0,0,0], axis=1)
	affine_matrix = np.insert(affine_matrix,3,[0,0,0,1], axis=0)

	#Change Orientation from PIR to RAS. Steps: PIR -> RIP -> RPI -> RPS -> RAS
	data.setflags(write=1)
	data = np.swapaxes(data,0,2)
	data = np.swapaxes(data,1,2)
	data = data[:,:,::-1]
	data = data[:,::-1,:]

	img = nibabel.Nifti1Image(data,affine_matrix)
	out_path = os.path.join(WDIR, os.path.basename(file).split(".")[0] + '.nii')
	lg.info(f"Writing file to \`{out_path}\`.")
	nibabel.save(img, out_path)

	##Delete Nrrd-File
	##os.remove(file)
