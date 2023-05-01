#!/usr/bin/env bash

ambmc: code/ambmc.sh
	bash code/ambmc.sh

dsurqec: code/dsurqec.sh
	bash code/dsurqec.sh

abi: code/abi.sh
	bash code/abi.sh

abi2dsurqec: abi dsurqec code/abi2dsurqec_40micron.sh
	bash code/abi2dsurqec_40micron.sh

mesh: ambmc dsurqec code/abi2dsurqec_40micron.sh
	bash code/ambmc2dsurqec.sh
