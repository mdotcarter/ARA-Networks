#!/usr/bin/env bash

# check for external tools
command -v python2.7 >/dev/null 2>&1 || { echo >&2 "Error: python 2.7 is not installed."; }
command -v dcm2nii >/dev/null 2>&1 || { echo >&2 "Error: dcm2nii is not installed."; }
command -v fslroi >/dev/null 2>&1 || { echo >&2 "Error: fslroi is not installed."; }
command -v slicetimer >/dev/null 2>&1 || { echo >&2 "Error: slicetimer is not installed."; }
command -v mcflirt >/dev/null 2>&1 || { echo >&2 "Error: mcflirt is not installed."; }
command -v fslmaths >/dev/null 2>&1 || { echo >&2 "Error: fslmaths is not installed."; }
command -v $FREESURFER_HOME/bin/mri_convert >/dev/null 2>&1 || { echo >&2 "Error: mri_convert is not installed or the environment variable FREESURFER_HOME is not set."; }
command -v $FREESURFER_HOME/bin/recon-all >/dev/null 2>&1 || { echo >&2 "Error: recon-all is not installed or the environment variable FREESURFER_HOME is not set."; }

# check for locally built exe's
command -v ${PWD}/build/bin/roi-extract >/dev/null 2>&1 || { echo >&2 "Error: roi-extract is not built."; }

# check python environment
if [ ! -d ${PWD}/build/pythonenv ]; then
    echo >&2 "Error: expected python virtual environment not present."
fi
