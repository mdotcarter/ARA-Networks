# Toplevel CMakeLists.txt
PROJECT(ACENET)
cmake_minimum_required(VERSION 2.8)
cmake_policy(VERSION 2.8)

#-----------------------------------------------------------------
# Libraries

# ITK, required
FIND_PACKAGE(ITK)
IF(ITK_FOUND)
   INCLUDE(${ITK_USE_FILE})
ELSE(ITK_FOUND)
   MESSAGE(FATAL_ERROR "ITK not found. Please set ITK_DIR.")
ENDIF(ITK_FOUND)

SET (EXECUTABLE_OUTPUT_PATH ${ACENET_BINARY_DIR}/bin CACHE INTERNAL
"Single output directory for building all executables.")

MARK_AS_ADVANCED (EXECUTABLE_OUTPUT_PATH ITK_DIR)

INCLUDE_DIRECTORIES(${ACENET_SOURCE_DIR}/vul)

SUBDIRS(vul)

# build tools
ADD_EXECUTABLE( roi-extract  roi-extract.cxx )
TARGET_LINK_LIBRARIES ( roi-extract vul ITKBasicFilters ITKIO )
