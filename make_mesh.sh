#!/usr/bin/env bash

#add parent directory to PYTONPATH
D=$(cd ../ && pwd)
export PYTHONPATH="${PYTHONPATH}:$D"

#default
CUT=false
MASK=false
BOUNDARY=false

USAGE="usage:\n\
        'basename $0'  -i <image file> -t <treshhold> [-m <mask-file>] [-c] [-s <size> -a <axis> -d <direction>] [-b] [-x]\n\
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
                  
                t)      TRESHHOLD="$OPTARG"
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
        NAME=($(echo $MASK_FILE | tr "." "\n"))
        PREFIX=${NAME[0]}
        SUFFIX=_resampled.nii.gz
        MASK_NAME=$PREFIX$SUFFIX
        echo ResampleImage 3 $MASK_FILE $MASK_NAME $RESOLUTION size=1 spacing=0 1
        ResampleImage 3 $MASK_FILE $MASK_NAME $RESOLUTION size=1 spacing=0 1
fi
if [ "$MASK" == "false" ]; then
        NAME=($(echo $IMAGE_NAME | tr "." "\n"))
        PREFIX=${NAME[0]}
        SUFFIX=_mask.nii.gz
        MASK_NAME=$PREFIX$SUFFIX
        fslmaths $IMAGE_NAME -thr 10 -bin $MASK_NAME
fi

echo mask created

NAME_M=($(echo $MASK_NAME | tr "." "\n"))
PREFIX_M=${NAME_M[0]}
SUFFIX_M=_smoothed.nii.gz
SMOOTHED_MASK=$PREFIX_M$SUFFIX_M


#smooth one mask 
SmoothImage 3 $MASK_NAME 6 $SMOOTHED_MASK

#make mesh using marching cube. 
echo mask smoothed

if $CUT; then
        NAME_C=($(echo $IMAGE_NAME | tr "." "\n"))
        PREFIX_C=${NAME_C[0]}
        SUFFIX_C="_cut.nii.gz"
        OUTPUTFILE=$PREFIX_C$SUFFIX_C
        if $BOUNDARY; then
                python -c "import make_mesh; make_mesh.cut_img_mas(\"$IMAGE_NAME\",\"$OUTPUTFILE\",$SIZE,$AXIS,\"$TRIM_STARTING_FROM\",\"$MASK_NAME\")"
                IMAGE_NAME=$OUTPUTFILE
        else
                python -c "import make_mesh; make_mesh.cut_img_mas(\"$IMAGE_NAME\",\"$OUTPUTFILE\",$SIZE,$AXIS,\"$TRIM_STARTING_FROM\")"
                IMAGE_NAME=$OUTPUTFILE
        fi
        echo Image cut
        

fi

if [ -f make_mesh.py ]; then
        python make_mesh.py -i $IMAGE_NAME -m $SMOOTHED_MASK -t $TRESHHOLD
else
        python ../make_mesh.py -i $IMAGE_NAME -m $SMOOTHED_MASK -t $TRESHHOLD
fi

echo mesh created


#Decimate and smooth mesh using Blender 
if $DECIMATE; then
        MESH_NAME=$(find . -name '*.obj')
        NAMES=($(echo $MESH_NAME | tr "\n" "\n"))

        if [ -f decimate_mesh_blender.py ]; then
                for NAME in "${NAMES[@]}"
                do
                        blender -b -P decimate_mesh_blender.py -- -f $NAME -r 0.4 -i 2 -n 4 -l 0.5
                done
        else
                for NAME in "${NAMES[@]}"
                do
                        blender -b -P ../decimate_mesh_blender.py -- -f $NAME -r 0.4 -i 2 -n 4 -l 0.5
                done
        fi

        echo mesh processed
fi

#Clean UP
rm $SMOOTHED_MASK
rm $OUTPUTFILE
rm $MASK_NAME




