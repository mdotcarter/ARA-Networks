#!/bin/bash

TOP=$PWD

source ${TOP}/build/pythonenv/bin/activate

WORKINGDIR=${TOP}/experiment/working_preprocess
mkdir $WORKINGDIR

QSUBDIR=$WORKINGDIR/qsub
mkdir $QSUBDIR

for s in $(cat experiment/subject_list.txt); do

    qsub -V -v SUBJECT=$s -v TOP=$PWD -e $QSUBDIR -o $QSUBDIR src/preprocess.sh

done
