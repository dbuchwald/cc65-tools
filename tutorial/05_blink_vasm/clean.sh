#!/bin/sh
BUILD_FOLDER=build
TEMP_FOLDER=build/05_blink_vasm

# Echo on
set -x

# Delete temporary files
rm -f ${BUILD_FOLDER}/05_blink_vasm.bin ${TEMP_FOLDER}/blink.lst