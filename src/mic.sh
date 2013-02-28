#$ -S /bin/bash

echo ${s}

cd ${TOP}

DATADIR=${TOP}/experiment/data/${s}

WORKINGDIR=${TOP}/experiment/data/${s}/micfiles

SEEDREGION=$(sed -n ${roi}p ${TOP}/experiment/roi_list.txt)
TARGETREGION=$(sed -n ${SGE_TASK_ID}p ${TOP}/experiment/roi_list.txt)

regionPairMICCalc ${DATADIR}/masked_fmri/fmri_ROI_${SEEDREGION}.nii.gz ${DATADIR}/masked_fmri/fmri_ROI_${TARGETREGION}.nii.gz ${WORKINGDIR}/micvalues_${SEEDREGION}_${TARGETREGION}.txt avg
