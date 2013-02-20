# ACE-Networks

Scripts and code to reproduce the results in the ACE Networks Project.

This project is a structural and functional connectivity analysis of the
data in the [Age Related Atrophy](http://www.bsl.ece.vt.edu/index.php?page=ara-dataset)
study.

## Dependencies

The work-flow depends on a Unix tool-chain. It has been tested using Centos5 and Ubuntu 12.04.
There are also several non-standard software dependencies.

* CMake >= 2.8.2
* Python 2.7.x with modules: virtualenv, numpy, nibabel, and pyxnat (optional)
* Chris Rorden's dcm2nii, part of mricron
* FSL 5.0
* Freesurfer 5.1.0
* ITK-3.20.1

A standard computing cluster is needed to replicate this work in its entirety
on any practical time scale. The scripts use a generic qsub that should work
on gridengine and similar systems with some adjustment. We highly recommend
Rocks (rocksclusters.org) for this.

## Build and Python Environment

There are a few utility programs used that must be compiled from source. A
build script is provided to help with this process. From the top-level directory

	chmod +x src/build.sh
	./src/build.sh

This will fetch and build the correct versions of cmake and ITK, then build the
utility programs.

To setup the python virtual environment, in the build directory run

	python2.7 ../src/setup-python.py

This will create a python script devenv-bootstrap.py in the build directory. Running

	python2.7 devenv-bootstrap.py pythonenv

will create the virtual environment and populate it with the required modules. Note the name of the environment (pythonenv) is important as it is used in the processing scripts to invoke the correct python environment (using pythonenv/bin/activate).

To check that the tools are built, the python environment correctly setup, and the external tools all installed you can run the script src/check.sh from the top-level directory.

# Processing Steps

The entire processing pipeline is contained in the src directory.
Scripts are named with a numbering scheme that determines the order
in which they must be run. Scripts with the same number can be run in parallel.

The scripts uses a predefined directory structure, organized as follows:

./experiment/dicom/rest/SUBJECT/ - resting state DICOM
./experiment/dicom/T1/SUBJECT/ - T1w DICOM
./experiment/data/SUBJECT/ - final results of each processing step

Intermediate results of each processing step are stored in ./experiments/working_*.

## 0: Fetch Data

Source: 0-fetch.py

This python script creates the base experiment directory and downloads the
DICOM files for each subject from the [ARA XNAT project](http://xnat.bsl.ece.vt.edu/app/template/XDATScreen_report_xnat_projectData.vm/search_element/xnat:projectData/search_field/xnat:projectData.ID/search_value/ACE) using the information in src/subject\_metadata.txt and urlib2 to dowload the data from xnat directly. This file can be recreated by running src/create\_metadata.py, which uses pyxnat to interrogate the xnat project for the metadata.

## 1: Data conversion and Freesurfer reconstructions

Source: 1-convert.sh

This bash script uses dcm2nii to convert the resting state DICOM to a 4D nifti file
named rest.nii.gz

Source: 1-fsrecon.sh, 2-fsconvert.sh

This bash script sets up the directory structure expected by freesurfer, converts the T1w images to mgz format and submits the segmentation jobs to the cluster. This step can take quite a long time unless you have several cluster nodes. After 1-fsrecon.sh runs and all jobs have completed, 2-fsconvert.sh can be run to convert the labelmaps to nifti and store them in the data directory.

## Functional Connectivity

### Pre-processing

Source: 3-preprocess.sh, roi-extract.cxx, regress.py

The preprocess script drops the first 3 TR, then performs slice timing and motion correction.
It then runs the roi-extract utility on the freesurfer segmentation to create conservative CSF, WM, and global ROI masks. These are used by regress.py to regress out those (average) signals, and then perform bandpass filtering, producing rest_preprocess.nii.gz
