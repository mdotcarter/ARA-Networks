#!/bin/bash

TOP=$(pwd)

export PATH=${TOP}/build/createpca/bin:${PATH}

export LD_LIBRARY_PATH=${TOP}/lib/armadillo-3.0.2/build:${TOP}/lib/lapack/build/lib:${LD_LIBRARY_PATH}

QSUBDIR=${TOP}/experiment/working_pca/qsub
mkdir -p ${QSUBDIR}

FIRSTSUBJ=$(head -n 1 ${TOP}/experiment/subject_list.txt)
	
ROICOUNT=$(ls -1 ${TOP}/experiment/data/${FIRSTSUBJ}/masked_fmri | wc -l)

$(ls ${TOP}/experiment/data/${FIRSTSUBJ}/masked_fmri | sed -e s/[^0-9]//g > ${TOP}/experiment/roi_list.txt)

for s in $(cat ./experiment/subject_list.txt); do

	mkdir ${QSUBDIR}/${s}
	WORKINGDIR=${TOP}/experiment/data/${s}/pcafiles
	mkdir ${WORKINGDIR}

	qsub -V -v s=${s} -v TOP=${TOP} -v WORKINGDIR=${WORKINGDIR} -t 1-${ROICOUNT} -e ${QSUBDIR}/${s} -o ${QSUBDIR}/${s} ./src/pca/pca.sh	

done
