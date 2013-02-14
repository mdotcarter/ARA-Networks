#!/bin/sh

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
fslroi $DATADIR/rest raw_roi 3 -1

# slice timing correction
slicetimer -i raw_roi -o raw_roi_timecorr -r 2

# motion correction
mcflirt -in raw_roi_timecorr -mats

# extract wm, csf, and global rois
${TOP}/build/bin/roi-extract $DATADIR/fslabels.nii

# compute average image
fslmaths  raw_roi_timecorr_mcf -Tmean raw_roi_timecorr_mcf_avg

# resample rois into epi space
flirt -in $DATADIR/t1w.nii -ref raw_roi_timecorr_mcf_avg -omat t1_2_epi.mat
flirt -in wm-roi.nii.gz -ref raw_roi_timecorr_mcf_avg -init t1_2_epi.mat -applyxfm -interp nearestneighbour -o  wm-roi-epi
flirt -in csf-roi.nii.gz -ref raw_roi_timecorr_mcf_avg -init t1_2_epi.mat -applyxfm -interp nearestneighbour -o  csf-roi-epi
flirt -in global-roi.nii.gz -ref raw_roi_timecorr_mcf_avg -init t1_2_epi.mat -applyxfm -interp nearestneighbour -o  global-roi-epi

# perform regression
python ${TOP}/src/regress.py

mv raw_roi_timecorr_mcf_res.nii.gz $DATADIR/rest_preprocess.nii.gz

cd $TOP

done
