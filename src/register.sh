#$ -S /bin/bash

s=${SUBJECT}

echo ${s}

DATADIR=${TOP}/experiment/data/${s}

WORKINGDIR=${TOP}/experiment/working_register/${s}

mkdir -p ${WORKINGDIR}
cd ${WORKINGDIR}

# skull strip the t1 image
bet ${DATADIR}/t1w.nii ./t1w_ss.nii

# extract 1st image of fmri for registration
mkdir split_dir
cd split_dir

fslsplit ${DATADIR}/rest_preprocess.nii.gz TEMP -t
mv TEMP0000.nii.gz ../fmri0.nii.gz

cd ..
rm -r split_dir

# resample t1w and register to fmri
ResampleVolume2 --Reference ./fmri0.nii.gz --interpolation linear --default_pixel_value 0 ./t1w_ss.nii.gz ./t1w_rs.nii.gz

RigidRegistration --fixedsmoothingfactor 0 --movingsmoothingfactor 0 --histogrambins 30 --spatialsamples 10000 --iterations 1000,1000,500,200 --learningrate 0.01,0.005,0.0005,0.0002 --translationscale 100 --outputtransform ./t1wtofmri_transform.txt --resampledmovingfilename ./t1w_regfmri.nii.gz ./fmri0.nii.gz ./t1w_rs.nii.gz

# register freesurfer labels to fmri
ResampleVolume2 --Reference ./fmri0.nii.gz --transformationFile ./t1wtofmri_transform.txt --transform_order input-to-output --interpolation nn --default_pixel_value 0 ${DATADIR}/fslabels.nii ./fslabels_regfmri.nii.gz

# resample atlas t1w to fmri voxel size
ResampleVolume2 --Reference ./t1w_regfmri.nii.gz --interpolation linear --default_pixel_value 0 ${ATLASDIR}/MNI152_T1_1mm_brain.nii.gz ./atlasbrain_rs.nii.gz

# register atlas to t1w (t1w already registered to fmri)
RigidRegistration --fixedsmoothingfactor 0 --movingsmoothingfactor 0 --histogrambins 30 --spatialsamples 10000 --iterations 1000,1000,500,200 --learningrate 0.01,0.005,0.0005,0.0002 --translationscale 100 --outputtransform ./atlastot1w_rigidtransform.txt ./t1w_regfmri.nii.gz ./atlasbrain_rs.nii.gz

AffineRegistration --fixedsmoothingfactor 0 --movingsmoothingfactor 0 --histogrambins 30 --spatialsamples 10000 --iterations 2000 --translationscale 100 --initialtransform ./atlastot1w_rigidtransform.txt --outputtransform ./atlastot1w_affinetransform.txt --resampledmovingfilename ./atlas_regfMRI.nii.gz ./t1w_regfmri.nii.gz ./atlasbrain_rs.nii.gz

# apply atlas transformation to label map
ResampleVolume2 --Reference ./fmri0.nii.gz --transformationFile ./atlastot1w_affinetransform.txt --transform_order input-to-output --interpolation nn --default_pixel_value 0 ${ATLASDIR}/ROI_MNI_V4.nii ./roi_regfmri.nii.gz

# split registered label map into separate labels
mkdir splitlabels
cd splitlabels

splitlabelmap ../roi_regfmri.nii.gz ROI

cd ..

# mask fmri volume with labels and freesurfer mask
mkdir fmri_masked_roi
mkdir masked_fmri

for l in $(ls splitlabels); do 
	
	fslmaths ${DATADIR}/rest_preprocess.nii.gz -mas ./splitlabels/${l} ./fmri_masked_roi/fmri_${l}
	fslmaths ./fmri_masked_roi/fmri_${l} -mas ./fslabels_regfmri.nii.gz ./masked_fmri/fmri_${l}
	
done

mv ./masked_fmri ${DATADIR}
