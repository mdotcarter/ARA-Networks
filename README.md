# ACE-Networks

Scripts and code to reproduce the results in the ACE Networks Project.

This project is a structural and functional connectivity analysis of the
data in the [Age Related Atropy](http://www.bsl.ece.vt.edu/index.php?page=ara-dataset)
study.

## Dependencies

There are several software dependencies. The easiest way to setup the system
is to use [neurodebian](http://neuro.debian.net/).

* Python 2.7.x with modules: numpy, scipy, pyxnat, nibabel
* Chris Rorden's dcm2nii
* FSL 5.0
* Freesurfer 5.1.0
* ITK-3.2.0

A standard computing cluster is needed to replicate this work in its entirety
on any practical time scale. The scripts use a generic qsub that should work
on Sungrid, Torque, and similar systems with some adjustment.

## Build

There are a few programs used that must be compiled from source.

* wm-roi-extract.cxx
* split-labelmaps.cxx

# Steps

The entire processing pipline is contained in the src directory.
Scripts are named with a numbering scheme that determines the order
in which they must be run. Scripts with the same number can be run in parallel.

## Fetch Data

Source: 0-fetch.py

This python script creates the base experiement directory and downloads the
DICOM files for each subject from the [ARA XNAT project](http://xnat.bsl.ece.vt.edu/app/template/XDATScreen_report_xnat_projectData.vm/search_element/xnat:projectData/search_field/xnat:projectData.ID/search_value/ACE) using pyxnat.

## Freesurfer reconstructions

Source: 1-fsrecon.sh

This bash script sets up the directory structure expected by freesurfer, converts the T1w images to mgz format and submits the segmentation jobs to the cluster. This step can take quite a long time unless you have several cluster nodes.

## Functional Connectivity

### Pre-processing

Source: 1-convert.sh

The bash script converts the rest DICOM to a 4D NIFTI file.

Source: 2-preprocess.sh, wm-roi-extract.cxx, regress.py

The preprocess script drops the first 3 TR, then performs slice timing and motion correction.
It then does registration of the structural image to the average 4D image, carrying the WM, CSF, and brain mask ROIs through the same transformation. It then uses wm-roi-extract to create a ROI labelmap in the left and right WM,
