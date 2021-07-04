BUILD_FOLDER = ../build
TEMP_FOLDER = $(BUILD_FOLDER)/02_nop_fill

$(TEMP_FOLDER)/nop_fill.o: nop_fill.s firmware.cfg
	mkdir -p $(TEMP_FOLDER)
	ca65 --cpu 65C02 -t none -o $(TEMP_FOLDER)/nop_fill.o -l $(TEMP_FOLDER)/nop_fill.lst nop_fill.s

$(BUILD_FOLDER)/02_nop_fill.bin: $(TEMP_FOLDER)/nop_fill.o
	ld65 -C firmware.cfg -o $(BUILD_FOLDER)/02_nop_fill.bin $(TEMP_FOLDER)/nop_fill.o

all: $(BUILD_FOLDER)/02_nop_fill.bin

test: $(BUILD_FOLDER)/02_nop_fill.bin
	hexdump -C $(BUILD_FOLDER)/02_nop_fill.bin

clean:
	rm -f $(BUILD_FOLDER)/02_nop_fill.bin $(TEMP_FOLDER)/nop_fill.o $(TEMP_FOLDER)/nop_fill.lst