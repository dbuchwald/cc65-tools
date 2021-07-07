# cc65 utilities used in this example
CA65_BINARY=ca65
CC65_BINARY=cc65
LD65_BINARY=ld65
AR65_BINARY=ar65

VASM_BINARY=vasm6502_oldstyle

CPU_FLAG=--cpu 65C02
ARCH_FLAG=-t none

CC65_FLAGS=$(CPU_FLAG) $(ARCH_FLAG) $(EXTRA_FLAGS) -O
CA65_FLAGS=$(CPU_FLAG) $(EXTRA_FLAGS)
LD65_FLAGS=
AR65_FLAGS=r

VASM_FLAGS=-Fbin -dotdir

# Hexdump is used for "testing" the ROM
HEXDUMP_BINARY=hexdump
HEXDUMP_FLAGS=-C

# Checksum generator
MD5_BINARY=md5sum

# Standard utilities (rm/mkdir)
RM_BINARY=rm
RM_FLAGS=-f
MKDIR_BINARY=mkdir
MKDIR_FLAGS=-p
CP_BINARY=cp
CP_FLAGS=-f
