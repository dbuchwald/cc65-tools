#!/bin/sh
BUILD_FOLDER=../build
TEMP_FOLDER=${BUILD_FOLDER}/01_nop_fill

# Echo on
set -x

# Delete temporary files
rm -f ${BUILD_FOLDER}/01_nop_fill.bin ${TEMP_FOLDER}/nop_fill.o ${TEMP_FOLDER}/nop_fill.lst ${TEMP_FOLDER}/01_nop_fill.map