include ../common/tools.mk

ROM_NAME=03_nop_fill

BUILD_ROOT=../build
BUILD_FOLDER=$(BUILD_ROOT)/$(ROM_NAME)
BIN_NAME=$(ROM_NAME).bin
ASM_SOURCES=nop_fill.s
FIRMWARE_CFG=firmware.cfg

ASM_OBJECTS=$(ASM_SOURCES:%.s=$(BUILD_FOLDER)/%.o)

# Compile assembler sources
$(BUILD_FOLDER)/%.o: %.s firmware.cfg
	@$(MKDIR_BINARY) $(MKDIR_FLAGS) $(BUILD_FOLDER)
	$(CA65_BINARY) $(CA65_FLAGS) -o $@ -l $(@:.o=.lst) $<

# Link ROM image
$(BUILD_FOLDER)/$(BIN_NAME): $(ASM_OBJECTS)
	@$(MKDIR_BINARY) $(MKDIR_FLAGS) $(BUILD_FOLDER)
	$(LD65_BINARY) $(LD65_FLAGS) -C $(FIRMWARE_CFG) -o $@ $^

# Default target
all: $(BUILD_FOLDER)/$(BIN_NAME)

# Build and dump output
test: $(BUILD_FOLDER)/$(BIN_NAME)
	$(HEXDUMP_BINARY) $(HEXDUMP_FLAGS) $<

# Clean build artifacts
clean:
	$(RM_BINARY) -f $(BUILD_FOLDER)/$(BIN_NAME) \
	$(ASM_OBJECTS) \
	$(ASM_OBJECTS:%.o=%.lst) 

