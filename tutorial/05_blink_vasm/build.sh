#!/bin/sh
SOURCE_FOLDER=05_blink_vasm
BUILD_FOLDER=build
TEMP_FOLDER=build/05_blink_vasm

# Echo on
set -x

# Create build folder
mkdir -p ${TEMP_FOLDER}

# Compile source (*.s) to bin with VASM (*.bin)
vasm6502_oldstyle -Fbin -dotdir ${SOURCE_FOLDER}/blink.s -o ${BUILD_FOLDER}/05_blink_vasm.bin -L ${TEMP_FOLDER}/blink.lst
