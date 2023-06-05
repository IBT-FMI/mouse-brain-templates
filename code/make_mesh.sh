#!/usr/bin/env bash

#add parent directory to PYTONPATH
D=$(cd ../ && pwd)
export PYTHONPATH="${PYTHONPATH}:$D"

#default
CUT=false
MASK=false
BOUNDARY=false

USAGE="usage:\n\
	'basename $0' -i <image file> -t <treshhold> [-m <mask-file>] [-c] [-s <size> -a <axis> -d <direction>] [-b] [-x]\n\
	-i: Image file name to create mesh from. Nifti format required.
	-t: Treshhold for marching cube algorithm
	-m: Optional mask file to be provided. Will be resampled to resolution of image file. If not specified, mask is created out of Image.
	-c: invokes additional function that trims brain image prior to mesh creation. Identifies image boundaries (non-zero entries) and Need to specify
	-s: size of cut in voxel
	-a: axis along which to cut (0,1,2)
	-d: {^beginning','end'}.Direction of cut. Trim either from start of axis inwards or from end of axis inwards.
	-b: use the given mask as boundary for cut
	-x: use Blenders mesh triangulation algorithm to decimate resulting mesh and smooth mesh. Requires working installation of Blender.
	-h: displays help message."

#read options
while getopts ':i:t:bcs:a:d:m:hx' flag; do
	case "${flag}" in
		i)
			IMAGE_NAME="$OPTARG"
			;;
		t)
			TRESHHOLD="$OPTARG"
			;;
		b)
			BOUNDARY=true
			;;
		c)
			CUT=true
			;;
		s)
			SIZE="$OPTARG"
			;;
		a)
			AXIS="$OPTARG"
			;;
		d)
			TRIM_STARTING_FROM="$OPTARG"
			;;
		m)
			MASK=true
			MASK_FILE="$OPTARG"
			;;
		x)
			DECIMATE=true
			;;
		h)
			echo -e "$USAGE"
			exit 0
			;;
	esac
done


if $MASK; then
	RESOLUTION=$(fslinfo $IMAGE_NAME | grep pixdim1)
	RESOLUTION=($(echo $RESOLUTION | tr " " "\n"))
	RESOLUTION=${RESOLUTION[1]}
	CM=x
	RESOLUTION=$RESOLUTION$CM$RESOLUTION$CM$RESOLUTION
	##NAME=($(echo $MASK_FILE | tr "." "\n"))
	PREFIX=${MASK_FILE%%.nii*}
	SUFFIX=_resampled.nii
	MASK_NAME=$PREFIX$SUFFIX
	echo "Resampling \`${MASK_FILE}\` to \`${MASK_NAME}\`."
	ResampleImage 3 $MASK_FILE $MASK_NAME $RESOLUTION 0 0 1
	echo "	✔️ Mask resampled."
fi
if [ "$MASK" == "false" ]; then
	PREFIX=${MASK_FILE%%.nii*}
	SUFFIX=_mask.nii
	MASK_NAME=$PREFIX$SUFFIX
	echo "Creating \`${MASK_NAME}\` mask from hard-coded threshold."
	fslmaths $IMAGE_NAME -thr 10 -bin $MASK_NAME
	echo "	✔️ Created mask."
fi


PREFIX_M=${MASK_NAME%%.nii*}
SUFFIX_M=_smoothed.nii
SMOOTHED_MASK=$PREFIX_M$SUFFIX_M

#smooth one mask
echo "Smoothing \`${MASK_NAME}\` mask."
SmoothImage 3 $MASK_NAME 6 $SMOOTHED_MASK
echo "	✔️ Mask smoothed."

#make mesh using marching cube.
if $CUT; then
	PREFIX_C=${IMAGE_NAME%%.nii*}
	SUFFIX_C="_cut.nii"
	OUTPUTFILE=$PREFIX_C$SUFFIX_C
	echo "Cutting image \`${IMAGE_NAME}\`."
	if $BOUNDARY; then
		python -c "import make_mesh; make_mesh.cut_img_mas(\"$IMAGE_NAME\",\"$OUTPUTFILE\",$SIZE,$AXIS,\"$TRIM_STARTING_FROM\",\"$MASK_NAME\")"
		IMAGE_NAME=$OUTPUTFILE
	else
		python -c "import make_mesh; make_mesh.cut_img_mas(\"$IMAGE_NAME\",\"$OUTPUTFILE\",$SIZE,$AXIS,\"$TRIM_STARTING_FROM\")"
		IMAGE_NAME=$OUTPUTFILE
	fi
	echo "	✔️ Image cut."
fi

OUT_MESHFILE="${IMAGE_NAME%%.nii*}_mesh.obj"
echo "Creating \`${OUT_MESHFILE}\` mesh."
python make_mesh.py -i $IMAGE_NAME -m $SMOOTHED_MASK -t $TRESHHOLD -o "${OUT_MESHFILE}"
echo "	✔️ Medh created."

#Decimate and smooth mesh using Blender
RESULT="$(dirname ${OUT_MESHFILE})/ambmc2dsurqec_15micron_masked.obj"
if $DECIMATE; then
	# Blender may be installed with version number in binary
	BLENDER_EXEC=$(find /usr/bin/ -regex ".*/blender-?[0-9]?\.?[0-9]?" | tail -1)
	echo "Selected mesh \`${OUT_MESHFILE}\` for decimation."
	$BLENDER_EXEC -b -P decimate_mesh_blender.py -- -f "${OUT_MESHFILE}" -r 0.4 -i 2 -n 4 -l 0.5 -o "${RESULT}"
	echo "	✔️ Mesh decimated."
else
	mv "${OUT_MESHFILE}" "${RESULT}"		
fi

#Clean UP
#rm $SMOOTHED_MASK
#rm $OUTPUTFILE
#rm $MASK_NAME
