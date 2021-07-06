#!/bin/sh
BUILD_FOLDER=../build

# Echo on
set -x

# Display contents of the ROM file
hexdump -C ${BUILD_FOLDER}/05_blink_vasm.bin

# Display also MD5 sum of the binary
md5sum ${BUILD_FOLDER}/05_blink_vasm.bin