#!/bin/bash

TOP=$(pwd)

export PATH=${TOP}/build/regionPairMICCalc/bin:${PATH}

QSUBDIR=${TOP}/experiment/working_mic/qsub
mkdir -p ${QSUBDIR}

FIRSTSUBJ=$(head -n 1 ${TOP}/experiment/subject_list.txt)
	
ROICOUNT=$(ls -1 ${TOP}/experiment/data/${FIRSTSUBJ}/masked_fmri | wc -l)

$(ls ${TOP}/experiment/data/${FIRSTSUBJ}/masked_fmri | sed -e s/[^0-9]//g > ${TOP}/experiment/roi_list.txt)

for s in $(cat ./experiment/subject_list.txt); do

	mkdir ${QSUBDIR}/${s}
	mkdir ${TOP}/experiment/data/${s}/micfiles

	for((roi=1;roi<=${ROICOUNT};roi++)); do

		qsub -V -v s=${s} -v TOP=${TOP} -v roi=${roi} -t ${roi}-${ROICOUNT} -e ${QSUBDIR}/${s} -o ${QSUBDIR}/${s} ./src/mic.sh	

	done

done
