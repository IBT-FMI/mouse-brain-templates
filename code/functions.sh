#!/usr/bin/env bash

RDIR="resources/"

get_resource () {
	mkdir -p "${RDIR}"
	RESOURCE_NAME=${1##*/}
	RESOURCE_PATH="${RDIR}${RESOURCE_NAME}"
	echo ${RESOURCE_PATH}
	if [[ ! -f  ${RESOURCE_PATH} ]]; then
		if datalad get "${RESOURCE_PATH}" ; then
			echo "Datalad fetch of ${RESOURCE_NAME} succeeded."
		else
			echo "Datalad fetch of ${RESOURCE_NAME} failed."
			echo "Downloading directly from source, \`${1}\`"
			wget ${1} -O "${RESOURCE_PATH}"
		fi
	fi
}
