#!/bin/sh

# template and atlas locations
ATLAS=/usr/share/fsl/data/standard/MNI152_T1_2mm_brain
BRAIN=/usr/share/fsl/data/standard/tissuepriors/avg152T1_brain.img
CSF=/usr/share/fsl/data/standard/tissuepriors/avg152T1_csf.img
WM=/usr/share/fsl/data/standard/tissuepriors/avg152T1_white.img

TOP=$PWD

for s in $(cat experiment/subject_list.txt); do

echo $s

DATADIR=${TOP}/experiment/data/$s
WORKINGDIR=${TOP}/experiment/working_preprocess/$s

# prepare working directory
mkdir -p $WORKINGDIR

# move to working dir
cd $WORKINGDIR

# drop the first 3TR
fsl5.0-fslroi $DATADIR/rest raw_roi 3 -1

# slice timing correction
fsl5.0-slicetimer -i raw_roi -o raw_roi_timecorr -r 2

# motion correction
fsl5.0-mcflirt -in raw_roi_timecorr -mats

# extract wm, csf, and global rois
${TOP}/build/bin/roi-extract $DATADIR/fslabels.nii

# compute average image
fsl5.0-fslmaths  raw_roi_timecorr_mcf -Tmean raw_roi_timecorr_mcf_avg

# resample rois into epi space
fsl5.0-flirt -in $DATADIR/t1w.nii -ref raw_roi_timecorr_mcf_avg -omat t1_2_epi.mat
fsl5.0-flirt -in wm-roi.nii.gz -ref raw_roi_timecorr_mcf_avg -init t1_2_epi.mat -applyxfm -interp nearestneighbour -o  wm-roi-epi
fsl5.0-flirt -in csf-roi.nii.gz -ref raw_roi_timecorr_mcf_avg -init t1_2_epi.mat -applyxfm -interp nearestneighbour -o  csf-roi-epi
fsl5.0-flirt -in global-roi.nii.gz -ref raw_roi_timecorr_mcf_avg -init t1_2_epi.mat -applyxfm -interp nearestneighbour -o  global-roi-epi

# perform regression
python ${TOP}/src/regress.py

mv raw_roi_timecorr_mcf_res.nii.gz $DATADIR/rest_preprocess.nii.gz

cd $TOP

done
