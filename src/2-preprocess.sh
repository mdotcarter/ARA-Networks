#!/bin/sh

# template and atlas locations
ATLAS=/usr/share/fsl/data/standard/MNI152_T1_2mm_brain
BRAIN=/usr/share/fsl/data/standard/tissuepriors/avg152T1_brain.img
CSF=/usr/share/fsl/data/standard/tissuepriors/avg152T1_csf.img
WM=/usr/share/fsl/data/standard/tissuepriors/avg152T1_white.img

TOP=$PWD

for s in $(cat experiment/subject_list.txt); do

echo $s

DICOMDIR=experiment/dicom/$s
DATADIR=experiment/data/$s
WORKINGDIR=experiment/working_preprocess/$s

# prepare working directory
mkdir -p $WORKING_DIR

# move to working dir
cd $WORKINGDIR

# drop the first 3TR
fsl5.0-fslroi raw raw_roi 3 -1

# slice timing correction
fsl5.0-slicetimer -i raw_roi -o raw_roi_timecorr -r 2

# motion correction
fsl5.0-mcflirt -in raw_roi_timecorr -mats

# compute average image
fsl5.0-fslmaths  raw_roi_timecorr_mcf -Tmean raw_roi_timecorr_mcf_avg

# register atlas to the average
fsl5.0-flirt -in $ATLAS -ref raw_roi_timecorr_mcf_avg -omat raw_roi_atlas.mat

# apply transformation to atlas tissue priors

fsl5.0-flirt -in $BRAIN -ref raw_roi_timecorr_mcf_avg -applyxfm -init raw_roi_atlas.mat -interp nearestneighbour -out raw_roi_timecorr_mcf_avg_brain

fsl5.0-flirt -in $CSF -ref raw_roi_timecorr_mcf_avg -applyxfm -init raw_roi_atlas.mat -interp nearestneighbour -out raw_roi_timecorr_mcf_avg_csf

fsl5.0-flirt -in $WM -ref raw_roi_timecorr_mcf_avg -applyxfm -init raw_roi_atlas.mat -interp nearestneighbour -out raw_roi_timecorr_mcf_avg_wm

# threshold the registered brain mask and tissue priors
fsl5.0-fslmaths raw_roi_timecorr_mcf_avg_brain -thr 1 raw_roi_timecorr_mcf_avg_brain_thr
fsl5.0-fslmaths raw_roi_timecorr_mcf_avg_csf -thr 150 raw_roi_timecorr_mcf_avg_csf_thr
fsl5.0-fslmaths raw_roi_timecorr_mcf_avg_wm -thr 150 raw_roi_timecorr_mcf_avg_wm_thr

python ${TOP}/src/regress.py

cd $TOP

done
