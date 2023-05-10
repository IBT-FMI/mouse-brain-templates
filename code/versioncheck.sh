#!/usr/bin/env bash

RDIR="releases/"

LAST_VER_PATH=$(ls ${RDIR}mouse-brain-templates-*.tar.xz | sort -V | tail -n1)
LAST_VER=$(echo ${LAST_VER_PATH} | sed "s:${RDIR}mouse-brain-templates-::" | sed "s:\.tar\.xz::")

LATEST=$(echo -e "${1}\n${LAST_VER}" | sort -V | tail -n1)

if [ "${LATEST}" != "${1}" ]; then
	echo "The selected version (\`${VERSION}\`) appears to be lower than that of the highest release archive (\`${LAST_VER_PATH}\`)."
	exit 1
fi
