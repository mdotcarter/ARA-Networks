#!/usr/bin/env bash
export FREESURFER_HOME=/opt/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh
RECON=$FREESURFER_HOME/bin/recon-all
CONVERT=$FREESURFER_HOME/bin/mri_convert

TOP=$PWD

WORKINGDIR=${TOP}/experiment/working_fsrecon

# prepare working directory
mkdir -p $WORKINGDIR

# tell FS to use working dir as subject dir
export SUBJECTS_DIR=$WORKINGDIR

for s in $(cat experiment/subject_list.txt); do

    echo $s

    DICOMDIR=${TOP}/experiment/dicom/T1/$s
    DICOMFILE=$(ls $DICOMDIR | head -1)
    mkdir -p $SUBJECTS_DIR/$s/mri/orig
    $CONVERT $DICOMFILE -it dicom  $SUBJECTS_DIR/$s/mri/orig/001.mgz

    $RECON -subject $s -all

done
