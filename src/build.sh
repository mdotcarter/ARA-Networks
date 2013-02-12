#!/bin/sh
# This script automates the building of the dependencies
# and applications

TOPDIR=$PWD

# get the cononical path to the source directory using the path
# to this script
SCRIPTHOME=$(
cd -P -- "$(dirname -- "$0")" && pwd -P
)
SOURCE=$SCRIPTHOME

# parse options
if [ $1 = "release" ]
then
    BUILD_TYPE=Release
else
    echo "Defaulting to Debug build type"
    BUILD_TYPE=Debug
fi

# make directories if they do not exist
if [ -e lib ]
then
  echo "Directory lib exists. Halting."
  exit
fi
mkdir lib;
cd lib

##########################
# CMake
##########################
echo "Downloading CMake"
curl --location http://www.cmake.org/files/v2.8/cmake-2.8.2.tar.gz | tar -zxf -
echo "Building Cmake"
mkdir cmake-build; cd cmake-build;
../cmake-2.8.2/configure >> make.log 2>&1
make -j5 >> make.log 2>&1
CMAKE=${TOPDIR}/lib/cmake-build/bin/cmake
cd $TOPDIR
cd lib;

##########################
# InsightToolkit Library
##########################
echo "Downloading ITK"
curl --location http://voxel.dl.sourceforge.net/sourceforge/itk/InsightToolkit-3.20.1.tar.gz | tar -zxf -
echo "Building ITK"
ITKBUILDDIR=ITK-build
mkdir $ITKBUILDDIR
cd $ITKBUILDDIR

$CMAKE -D BUILD_EXAMPLES=OFF -D BUILD_TESTING=OFF -D CMAKE_BUILD_TYPE=$BUILD_TYPE -D ITK_USE_REVIEW=ON ../InsightToolkit-3.20.1/ >> make.log 2>&1
make -j5 >> make.log 2>&1

export ITK_DIR=$PWD

cd $TOPDIR
echo "Building ACENET"
# make directory if they do not exist
if [ -e build ]
then
  echo "Directory build exists. Halting."
  exit
fi
mkdir build
cd build
echo $CMAKE
$CMAKE -D CMAKE_BUILD_TYPE=$BUILD_TYPE ${SOURCE} >> make.log 2>&1
make >> make.log 2>&1

cd $TOPDIR
