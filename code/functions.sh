#!/usr/bin/env bash

get_resource () {
	RESOURCE_NAME=${1##*/}
	echo ${RESOURCE_NAME}
	RESOURCE_PATH="resources/${RESOURCE_NAME}"
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
