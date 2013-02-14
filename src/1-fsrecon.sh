#!/usr/bin/env bash
source $FREESURFER_HOME/SetUpFreeSurfer.sh
RECON=$FREESURFER_HOME/bin/recon-all
CONVERT=$FREESURFER_HOME/bin/mri_convert

TOP=$PWD

WORKINGDIR=${TOP}/experiment/working_fsrecon
DATADIR=${TOP}/experiment/data/$s

# prepare working directory
mkdir -p $WORKINGDIR

# create qsub scripts folder
QSUBDIR=$WORKINGDIR/qsub
mkdir -p $QSUBDIR

# tell FS to use working dir as subject dir
export SUBJECTS_DIR=$WORKINGDIR

for s in $(cat experiment/subject_list.txt); do

    echo $s

    DICOMDIR=${TOP}/experiment/dicom/T1/$s
    DICOMFILE=$(ls $DICOMDIR | head -1)
    mkdir -p $SUBJECTS_DIR/$s/mri/orig
    $CONVERT $DICOMDIR/$DICOMFILE -it dicom  $SUBJECTS_DIR/$s/mri/orig/001.mgz

    QSUBSCRIPT=$QSUBDIR/recon-$s.sh
    echo ""#!/bin/bash"" > $QSUBSCRIPT
    echo "$RECON -subject $s -all" >> $QSUBSCRIPT

    qsub -V -e $QSUBDIR -o $QSUBDIR $QSUBSCRIPT

done
