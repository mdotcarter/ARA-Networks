#$ -S /bin/bash


s=$SUBJECT

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

# compute average image
fslmaths  raw_roi_timecorr_mcf -Tmean raw_roi_timecorr_mcf_avg

# extract wm, csf, and global rois in epi space
${TOP}/build/bin/roi-extract $DATADIR/fslabels.nii raw_roi_timecorr_mcf_avg

# perform regression
python ${TOP}/src/regress.py

mv raw_roi_timecorr_mcf_res.nii.gz $DATADIR/rest_preprocess.nii.gz
