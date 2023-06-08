#!/usr/bin/env bash

RDIR="releases/"

VERSION=${1}

LAST_VER_PATH=$(ls ${RDIR}mouse-brain-templates-*.tar.xz | sort -V | tail -n1)
LAST_VER=$(echo ${LAST_VER_PATH} | sed "s:${RDIR}mouse-brain-templates-::" | sed "s:\.tar\.xz::")

LATEST=$(echo -e "${VERSION}\n${LAST_VER}" | sort -V | tail -n1)

if [ "${LATEST}" != "${VERSION}" ]; then
	echo "The selected version (\`${VERSION}\`) appears to be lower than that of the highest release archive (\`${LAST_VER_PATH}\`)."
	exit 1
elif [ "${LATEST}" == "${LAST_VER}" ]; then
	echo "The selected version (\`${VERSION}\`) appears to be identical to the highest release archive (\`${LAST_VER_PATH}\`)."
	exit 1
fi
