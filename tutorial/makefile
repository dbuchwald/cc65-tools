include common/tools.mk

BUILD_FOLDER=build

PROJECTS=01_nop_fill   \
         02_nop_fill   \
         03_nop_fill   \
         04_reset      \
         05_blink_vasm 

TOP_TARGETS=all clean

ROM_BINARIES=$(PROJECTS:%=$(BUILD_FOLDER)/%.bin)

$(BUILD_FOLDER)/%.bin: FORCE
	$(MAKE) -C $(@:$(BUILD_FOLDER)/%.bin=%) all

$(TOP_TARGETS): $(PROJECTS) FORCE
$(PROJECTS): FORCE
	$(MAKE) -C $@ $(MAKECMDGOALS)

test: $(ROM_BINARIES)
	@$(MD5_BINARY) $^ 

FORCE: