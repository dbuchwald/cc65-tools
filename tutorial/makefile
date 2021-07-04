include common/tools.mk

BUILD_FOLDER=build

PROJECTS=01_nop_fill \
         02_nop_fill \
         03_nop_fill

ROM_BINARIES=$(PROJECTS:%=$(BUILD_FOLDER)/%.bin)

$(BUILD_FOLDER)/01_nop_fill.bin:
	01_nop_fill/build.sh

$(BUILD_FOLDER)/%.bin:
	$(MAKE) -C $(@:$(BUILD_FOLDER)/%.bin=%) all

all: $(ROM_BINARIES)
	echo $(BUILD_FOLDERS)
	echo $(ROM_BINARIES)

test: $(ROM_BINARIES)
	@$(MD5_BINARY) $^ 

clean:
	$(RM_BINARY) $(RM_FLAGS) $(ROM_BINARIES) $(ROM_BINARIES:%.bin=%/*.o) $(ROM_BINARIES:%.bin=%/*.lst)
