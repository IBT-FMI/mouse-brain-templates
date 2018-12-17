#!/usr/bin/env bash

DATE=`date +%Y%m%d`
PN="mouse-brain-atlases"
PV="${1}"

./make_archives.sh -v "${PV}" -n "${PN}" -m || exit 1
rsync -avP ${PN}*${PV}.tar.xz dreamhost:chymera.eu/distfiles/
rsync -avP ${PN}*${PV}.sha512 dreamhost:chymera.eu/distfiles/

if [ $? -eq 0 ]; then
	rm -rf ${PN}*${PV}*
else
	echo "Could not rsync to remote server. Are you authenticated to use it?"
fi
