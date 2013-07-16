#!/bin/bash

TOP=$(pwd)

QSUBDIR=${TOP}/experiment/working_matrices_pca
mkdir ${QSUBDIR}

for s in $(cat ./experiment/subject_list.txt); do

	qsub -V -v s=${s} -v TOP=${TOP} -e ${QSUBDIR} -o ${QSUBDIR} ${TOP}/src/pca/matrices.sh

done
