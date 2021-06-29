#!/bin/sh

# Echo on
set -x

# Compile source (*.s) to object (*.o)
ca65 --cpu 65C02 -t none -o nop_fill.o -l nop_fill.lst nop_fill.s

# Link objects (*.o) to binary file (*.bin)
ld65 -C firmware.cfg -o 01_nop_fill.bin nop_fill.o