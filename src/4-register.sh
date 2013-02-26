#!/bin/bash

TOP=$(pwd)

export LD_LIBRARY_PATH=${TOP}/lib/Slicer3-3.6.3/lib/Slicer3/Plugins:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${TOP}/lib/Slicer3-3.6.3/lib/InsightToolkit:${LD_LIBRARY_PATH}
export PATH=${TOP}/lib/Slicer3-3.6.3/lib/Slicer3/Plugins:${PATH}

export PATH=${TOP}/lib/splitlabelmap/bin:${PATH}

ATLASDIR=${TOP}/aalatlas

WORKINGDIR=${TOP}/experiment/working_register
mkdir ${WORKINGDIR}

QSUBDIR=${WORKINGDIR}/qsub
mkdir ${QSUBDIR}

for s in $(cat ./experiment/subject_list.txt); do

	qsub -V -v SUBJECT=${s} -v TOP=${TOP} -v ATLASDIR=${ATLASDIR} -e $QSUBDIR -o $QSUBDIR ./src/register.sh

done
