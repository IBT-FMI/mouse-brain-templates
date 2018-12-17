import bpy
import os
import sys
import argparse

## Example call from commandline: blender -b -P decimate_mesh_blender.py -- -f mesh.obj -o mesh_dec.obj -r 0.5 -i 2 -n 4 -l 0.5
## Blender will ignore all options after -- so parameters can be passed to python script.

# get the args passed to blender after "--", all of which are ignored by
# blender so scripts may receive their own arguments
argv = sys.argv
if "--" not in argv:
	argv = [] # as if no args are passed
else:
	argv = argv[argv.index("--") + 1:] # get all args after "--"

path = os.path.abspath('.')
path = path + '/'

parser = argparse.ArgumentParser(description="Mesh Decimation",formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('--filename','-f',type=str)
parser.add_argument('--output_filename','-o',type=str,default="")
parser.add_argument('--decimate_ratio','-r',type=float,default=0.4)
parser.add_argument('--decimate_iterations','-i',type=int,default=2)
parser.add_argument('--smooth_iterations','-n',type=int,default=4)
parser.add_argument('--smooth_lambda','-l',type=float,default=0.5)
parser.add_argument('--decimate','-d',type=bool,default=True)
parser.add_argument('--smooth','-s',type=bool,default=True)

args = parser.parse_args(argv)

#Get rid of blender default objects
for o in bpy.data.objects:
	o.select=True
bpy.ops.object.delete()

#Import Mesh
bpy.ops.import_scene.obj(filepath= path + args.filename)
Mesh = bpy.context.selected_objects[0]

if (args.decimate):
	#add mesh decimate modifier
	modifierName='DecimateMod'
	for i in range(0,args.decimate_iterations):
		modifier=Mesh.modifiers.new(modifierName,'DECIMATE')
		modifier.ratio=1-args.decimate_ratio*(i+1)
		modifier.use_collapse_triangulate=True

#add smooth modifier
if (args.smooth):
	Mesh.select = True
	modifier_s = Mesh.modifiers.new("laplacesmooth",'LAPLACIANSMOOTH')
	modifier_s.iterations = args.smooth_iterations
	modifier_s.lambda_factor = args.smooth_lambda

#Export as .obj file
Mesh.select = True

if (args.output_filename == ""):
	print(args.filename)
	output_filename = path + str.split(args.filename,".obj")[0] + "_decimated.obj"
	print( str.split(args.filename,".obj")[0])
	print(output_filename)
else:
	output_filename = path + args.output_filename

#Save file as .obj
bpy.ops.export_scene.obj(filepath=output_filename,use_materials=False)

