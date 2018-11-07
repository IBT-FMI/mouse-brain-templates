#!/usr/bin/env bash

#add parent directory to PYTONPATH
D=$(cd ../ && pwd)
export PYTHONPATH="${PYTHONPATH}:$D"

#default
CUT=false
MASK=false
BOUNDARY=false

USAGE="usage:\n\
        'basename $0'  -i <image file> -t <treshhold> [-m <mask-file>] [-c] [-s <size> -a <axis> -d <direction>] [-b]\n\
        -i: Image file name to create mesh from. Nifti format required.
        -t: Treshhold for marching cube algorithm
        -m: Optional mask file to be provided. Will be resampled to resolution of image file. If not specified, mask is created out of Image.
        -c: invokes additional function that trims brain image prior to mesh creation. Identifies image boundaries (non-zero entries) and Need to specify  
        -s: size of cut in voxel
        -a: axis along which to cut (0,1,2)
<<<<<<< HEAD
        -d: {^beginning','end'}.Direction of cut. Trim either from start of axis inwards or from end of axis inwards.
=======
        -d: direction of cut. 0: trim from start of axis inwards 1:trim from end of axis inwards
>>>>>>> 889cda213614b6fb540c76f8ac1b155971ee10d0
        -b: use the given mask as boundary for cut
        -h: displays help message."

#read options
while getopts ':i:t:bcs:a:d:m:h' flag; do
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
<<<<<<< HEAD
                        TRIM_STARTING_FROM="$OPTARG"
=======
                        DIRECTION="$OPTARG"
>>>>>>> 889cda213614b6fb540c76f8ac1b155971ee10d0
                        ;;
                m)  
                        MASK=true
                        MASK_FILE="$OPTARG"
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
<<<<<<< HEAD
        ResampleImage 3 $MASK_FILE $MASK_NAME $RESOLUTION size=1 spacing=0 1
=======

>>>>>>> 889cda213614b6fb540c76f8ac1b155971ee10d0
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
<<<<<<< HEAD
                python -c "import make_mesh; make_mesh.cut_img_mas(\"$IMAGE_NAME\",\"$OUTPUTFILE\",$SIZE,$AXIS,\"$TRIM_STARTING_FROM\",\"$MASK_NAME\")"
                IMAGE_NAME=$OUTPUTFILE
        else
                python -c "import make_mesh; make_mesh.cut_img_mas(\"$IMAGE_NAME\",\"$OUTPUTFILE\",$SIZE,$AXIS,\"$TRIM_STARTING_FROM\")"
=======
                python -c "import make_mesh; make_mesh.cut_img_mas(\"$IMAGE_NAME\",\"$OUTPUTFILE\",$SIZE,$AXIS,$DIRECTION,\"$MASK_NAME\")"
                IMAGE_NAME=$OUTPUTFILE
        else
                python -c "import make_mesh; make_mesh.cut_img_mas(\"$IMAGE_NAME\",\"$OUTPUTFILE\",$SIZE,$AXIS,$DIRECTION)"
>>>>>>> 889cda213614b6fb540c76f8ac1b155971ee10d0
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

#Clean UP
rm $SMOOTHED_MASK
rm $OUTPUTFILE



