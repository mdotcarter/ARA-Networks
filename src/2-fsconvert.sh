#!/usr/bin/env bash
source $FREESURFER_HOME/SetUpFreeSurfer.sh
RECON=$FREESURFER_HOME/bin/recon-all
CONVERT=$FREESURFER_HOME/bin/mri_convert

TOP=$PWD

SUBJECTS_DIR=${TOP}/experiment/working_fsrecon
DATADIR=${TOP}/experiment/data

for s in $(cat experiment/subject_list.txt); do

    $CONVERT $SUBJECTS_DIR/$s/mri/orig/001.mgz $DATADIR/$s/t1w.nii
    $CONVERT $SUBJECTS_DIR/$s/mri/aparc+aseg.mgz $DATADIR/$s/fslabels.nii

done
