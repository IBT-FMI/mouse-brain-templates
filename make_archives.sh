#!/usr/bin/env bash
MAKE_MESH=false

while getopts ':v:n:m' flag; do
     case "${flag}" in
          v)
               PV="$OPTARG"
               ;;
          n)
               PN="$OPTARG"
               ;;
          m)
               MAKE_MESH=true
               ;;
          :)
               echo "Option -$OPTARG requires an argument." >&2
               exit 1
               ;;
     esac
done

if [ -z "$PV" ]; then
     PV=9999
fi

if [ -z "$PN" ]; then
     PN="mouse-brain-atlases"
fi

P="${PN}-${PV}"
PHD="${PN}HD-${PV}"

mkdir ${P}
mkdir ${PHD}
cp FAIRUSE-AND-CITATION ${P}
cp FAIRUSE-AND-CITATION ${PHD}
pushd ${P}
     bash ../ambmc.sh || exit 1
     cp ambmc_COPYING ../${PHD}
     cp ambmc_README ../${PHD}
     bash ../dsurqec.sh || exit 1
     bash ../abi.sh || exit 1
     bash ../abi2dsurqec_40micron.sh || exit 1     
     bash ../roi.sh || exit 1
     rm abi_10micron_average.nii 
     rm abi_10micron_annotation.nii
     mv abi_15micron_average.nii ../${PHD}
     mv ambmc_15micron_mask.nii ../${PHD}
     mv abi_15micron_annotation.nii ../${PHD}
     if $MAKE_MESH ; then
          bash ../ambmc2dsurqec.sh || exit 1
          mv ambmc2dsurqec_15micron.nii ../{$PHD}
     fi
mv ambmc_15micron.nii ../${PHD}
mv lambmc_15micron.nii ../${PHD}
 
popd
tar cfJ "${P}.tar.xz" ${P}
tar cfJ "${PHD}.tar.xz" ${PHD}
