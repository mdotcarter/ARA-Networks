#$ -S /bin/bash

echo ${s}

cd ${TOP}

DATADIR=${TOP}/experiment/data/${s}

roi=${SGE_TASK_ID}
REGION=$(sed -n ${roi}p ${TOP}/experiment/roi_list.txt)

echo "Region: ${REGION}"

createPCA ${DATADIR}/masked_fmri/fmri_ROI_${REGION}.nii.gz ${WORKINGDIR}/pca_${REGION}.txt
