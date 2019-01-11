import os
from glob import glob
import nrrd
import nibabel
import numpy as np
import sys

#path = os.path.dirname(sys.argv[0])
path = os.path.abspath('.')
files = glob(os.path.join(path,'*.nrrd'))


for file in files:
	print("Reading " + file)
	readnrrd = nrrd.read(file)
	data = readnrrd[0]
	header = readnrrd[1]

	print("Converting " + file)

	#space = header['space'].split("-")
	affine_matrix = np.array(header["space directions"],dtype=np.float)
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
	nibabel.save(img,os.path.join(path, os.path.basename(file).split(".")[0] + '.nii'))

	#Delete Nrrd-File
	os.remove(file)
