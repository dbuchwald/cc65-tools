include common/tools.mk

BUILD_FOLDER=build

PROJECTS=01_blink_vasm \
         02_blink      \
         03_blink      \
         04_reset      

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