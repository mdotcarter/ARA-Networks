#!/bin/bash

TOP=$(pwd)

export PATH=${TOP}/build/regionPairMICCalc/bin:${PATH}

QSUBDIR=${TOP}/experiment/working_mic_avg/qsub
mkdir -p ${QSUBDIR}

FIRSTSUBJ=$(head -n 1 ${TOP}/experiment/subject_list.txt)
	
ROICOUNT=$(ls -1 ${TOP}/experiment/data/${FIRSTSUBJ}/masked_fmri | wc -l)

$(ls ${TOP}/experiment/data/${FIRSTSUBJ}/masked_fmri | sed -e s/[^0-9]//g > ${TOP}/experiment/roi_list.txt)

for s in $(cat ./experiment/subject_list.txt); do

	mkdir ${QSUBDIR}/${s}
	WORKINGDIR=${TOP}/experiment/data/${s}/micfiles_avg
	mkdir ${WORKINGDIR}

	for((roi=1;roi<=${ROICOUNT};roi++)); do

		qsub -V -v s=${s} -v TOP=${TOP} -v roi=${roi} -v WORKINGDIR=${WORKINGDIR} -t ${roi}-${ROICOUNT} -e ${QSUBDIR}/${s} -o ${QSUBDIR}/${s} ./src/avg/mic.sh	

	done

done