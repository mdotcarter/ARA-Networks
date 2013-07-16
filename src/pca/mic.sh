#$ -S /bin/bash

echo ${s}

cd ${TOP}

DATADIR=${TOP}/experiment/data/${s}

SEEDREGION=$(sed -n ${roi}p ${TOP}/experiment/roi_list.txt)
TARGETREGION=$(sed -n ${SGE_TASK_ID}p ${TOP}/experiment/roi_list.txt)

regionPairMICCalc ${DATADIR}/pcafiles/pca_${SEEDREGION}.txt ${DATADIR}/pcafiles/pca_${TARGETREGION}.txt ${WORKINGDIR}/micvalues_${SEEDREGION}_${TARGETREGION}.txt pca
