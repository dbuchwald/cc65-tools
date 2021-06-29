nop_fill.o: nop_fill.s firmware.cfg
	ca65 --cpu 65C02 -t none -o nop_fill.o -l nop_fill.lst nop_fill.s

02_nop_fill.bin: nop_fill.o
	ld65 -C firmware.cfg -o 02_nop_fill.bin nop_fill.o

all: 02_nop_fill.bin

test: 02_nop_fill.bin
	hexdump -C 02_nop_fill.bin

clean:
	rm -f 02_nop_fill.bin nop_fill.o nop_fill.lst