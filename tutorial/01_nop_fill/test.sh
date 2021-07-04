#!/bin/sh
BUILD_FOLDER=build

# Echo on
set -x

#display contents of the ROM file
hexdump -C ${BUILD_FOLDER}/01_nop_fill.bin