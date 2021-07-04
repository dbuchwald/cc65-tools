#!/bin/sh
SOURCE_FOLDER=01_nop_fill
BUILD_FOLDER=build
TEMP_FOLDER=build/01_nop_fill

# Echo on
set -x

# Create build folder
mkdir -p ${TEMP_FOLDER}

# Compile source (*.s) to object (*.o)
ca65 --cpu 65C02 -t none -o ${TEMP_FOLDER}/nop_fill.o -l ${TEMP_FOLDER}/nop_fill.lst ${SOURCE_FOLDER}/nop_fill.s

# Link objects (*.o) to binary file (*.bin)
ld65 -C ${SOURCE_FOLDER}/firmware.cfg -o ${BUILD_FOLDER}/01_nop_fill.bin ${TEMP_FOLDER}/nop_fill.o