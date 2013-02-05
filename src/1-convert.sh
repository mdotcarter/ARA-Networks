#!/bin/sh

for s in $(cat experiment/subject_list.txt); do

echo $s

DICOMDIR=experiment/dicom/$s
DATADIR=experiment/data/$s

# prepare output and working directory
mkdir -p $DATADIR

# convert DICOM to nifti
dcm2nii $DICOMDIR
find $DICOMDIR -name "*.nii.gz" -print | head -1 | xargs -IREP mv REP $DATADIR/raw.nii.gz

done
