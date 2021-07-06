#!/bin/sh
BUILD_FOLDER=../build
TEMP_FOLDER=${BUILD_FOLDER}/01_nop_fill

# Echo on
set -x

# Create build folder
mkdir -p ${TEMP_FOLDER}

# Compile source (*.s) to object (*.o)
ca65 --cpu 65C02 -t none -o ${TEMP_FOLDER}/nop_fill.o -l ${TEMP_FOLDER}/nop_fill.lst nop_fill.s

# Link objects (*.o) to binary file (*.bin)
ld65 -C firmware.cfg -o ${BUILD_FOLDER}/01_nop_fill.bin -m ${TEMP_FOLDER}/01_nop_fill.map ${TEMP_FOLDER}/nop_fill.o