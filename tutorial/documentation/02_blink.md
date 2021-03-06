# First CC65 example

In last section I presented how `make` and `vasm` can be used to build Ben Eater's `blink.s` code. Now I want to demonstrate iteratively how to port the code to be compatible with CC65. The assumption (for now) is that the resulting ROM is identical to the one created by `vasm` from Ben's source, and this can be verified using the `make test` command for each of the subprojects.

Let's start with explaining few concepts first. Sorry for the lengthy introductions, but the idea is to make this tutorial accessible to everyone, even at the cost of increased verbosity.

## Some issues with `vasm` compilation

If you have ever used any proper development toolchain you might have noticed (even if that was hidden from you), that there are three distinct phases of building each binary (or other build product):

1. Preprocessing - this is where your sources are initially parsed and all macros are replaced by their definitions, literals are replaced by their values and so on,
2. Compilation - raw sources (with all the macros expanded, literals replaced and so forth) are being compiled to machine code that is "location independent", meaning the resulting objects don't use specific addresses or direct references, but instead use "symbols" as placeholders for these entities. Please note: the target system architecture (Intel x86, 6502/65C02) is now fixed in this step,
3. Linking - objects generated by compiler are collected together, aligned in provided memory map according to target architecture specification and symbols are replaced by actual values calculated during this process.

Now, if this is first time you are reading about this, it might seem like gross overcomplication of things, but in fact there is a reason for all this.

Most notably you want your code to be compiled and linked separately, and there are two reasons for it:

1. For complex systems you might want to write different parts of your software in different programming languages, so you want each of these compiled by different compiler. In CC65 case you can use both 6502 assembly and C,
2. You might want to link various binaries from the same set of objects without the necessity to recompile them each time. Sure, for software built for 6502 CPU you can't expect too much gain in terms of compilation speed (after all, it will never take too long to compile code to fit in 64KB of memory), but this separation of concerns gives you much more security in building portable code.

Now, `vasm` is a good compiler targeting various architectures, but its macro processor is much less powerful than the one in CC65, linker is tied to compiler and it doesn't provide support for C code interoperability.

And this is just a very short list of problems I have with `vasm`...

## Firmware definition file

Now, I didn't include the above ramblings just to show off my (rather limited, to be honest) knowledge of compilers construction. The point was to explain why certain details we have to bother next are important, and where do they fit into the broader picture.

The first new thing you have to provide when building your code with CC65 is creating the firmware configuration file. You will find the simplest example in `cc65-tools-main/tutorial/02_blink` folder:

````
MEMORY
{
  ROM:       start=$8000, size=$8000, type=ro, define=yes, fill=yes,   fillval=$00, file=%O;
}

SEGMENTS
{
  CODE:      load=ROM,       type=ro,  define=yes;
  VECTORS:   load=ROM,       type=ro,  define=yes,   offset=$7ffa, optional=yes;
}
````

This is configuration file that describes your actual hardware build, and it already shows great concept behind CC65 - you don't need to change the code if you want to build and run your software on a different hardware configuration with different memory or I/O map. Your address decoder is different than mine? Grab the code, change firmware configuration file and link the ROM again. You don't even have to recompile anything!

That being said, the above file might be intimidating with all the parameters and all. Don't worry, I will explain these in detail.

First section covers memory areas. For now, since we don't intend to use RAM for anything at all, simple ROM location definition will suffice. The following parameters are used in `ROM` definition (please note: this is just a name, it has no meaning whatsoever):

- `start=$8000` is the starting address (hexadecimal) of the ROM space,
- `size=$8000` is the total size of this memory location. Linker will verify at link time if all the stuff you want to store there can fit in provided space,
- `type=ro` defines ROM space as read-only. Attempt to write to memory address represented by symbol located in that memory area will cause error at link time,
- `define=yes` will cause the linker to generate set of symbols representing various properties of this memory area like `__ROM_START__` or `__ROM_SIZE__`,
- `fill=yes` will cause the linker to fill unused part of this memory area with value specified in `fillval` option,
- `fillval=$00` defines value that will be used to fill unused memory areas,
- `file=%O` tells the linker to save the generated memory area to linked binary file.

Second section defines segments - actual usable, addressable areas, where the code and variables will be defined. There are some standard segments (like CODE, ZEROPAGE and BSS) which are to be used for specific purposes, but you can go ahead and change the names as you wish.

Let's look at the parameters used in segment definitions:

- `load=ROM` means that all the code and variables defined in that segment are to be located in ROM memory, and this `ROM` is the memory area defined above,
- `type=ro` means that all the data stored in this segment is read-only and any attempt to write to it should be treated as an error,
- `define=yes` will cause the linker to define set of symbols, like described above,
- `offset=$fffa` means that this particular segment is to be placed at byte 0xFFFA in `ROM` memory,
- `optional=yes` suppresses error if particular segment is not used in your sources. Sometimes you might want to skip certain segments and it's all fine.

To summarize, our firmware configuration file states that:

1. We have one memory area, starting at address `0x8000` of 32KB continuous read-only space that will be filled with `0x00` and saved to output file,
2. In that memory area we will have two read-only segments: first one will be called `code`, and linker itself will decide where to put it, and the second will be called `vectors` and placed at fixed offset of `0xFFFA`,
3. Linker will generate symbols for all memory areas and segments.

## Actual source code

Having the firmware configuration complete, we can go ahead and write the actual source code. You will find it in `cc65-tools-main/tutorial/02_blink/blink.s`:

````assembly
  .code

reset:
  lda #$ff
  sta $6002

  lda #$50
  sta $6000

loop:
  ror
  sta $6000

  jmp loop

  .segment "VECTORS"
  .word $0000
  .word reset
  .word $0000
````

As you can probably see, it's very similar to the code from Ben's example to be built by `vasm`. There are literally just two differences here. Instead of

```assembly
  .org $8000
```

We have now:

```assembly
  .code
```

The difference is obvious. In Ben's example we are telling the compiler exactly where in the memory should the code be located. For CC65 we are using different syntax - we are just simply telling the compiler that whatever machine code is generated here should be put in `CODE` segment, but it's up to linker to determine actual location.

Just for consistency, second difference is very similar, instead of:

```assembly
  .org $fffc
```

We have:

```assembly
  .segment "VECTORS"
```

And that's just it. Compiler will generate code (referring to undetermined value of `reset` label at this point), and linker will calculate actual `reset` location in memory after placing all objects in `code` segment.

Again, all this fun and games with segments definition might seem excessive for the purpose, but there is a reason to do it that way. Specifying arbitrary addresses in your code will make it much less portable and much less reusable. While it doesn't matter when you have single assembly source, it gets more and more important the more files you want to include in your build. Proper software development practices require certain level of "separation of concerns", so you don't want your LCD routines to depend on variables or location of functions for ACIA operation.

Basically: this is how big boys do it, so grow up and follow :)

## Building the code

Obviously we need to compile the code and link the ROM binary. For this purpose we are going to use pretty familiar `makefile`:

```makefile
ROM_NAME=02_blink

ASM_SOURCES=blink.s
FIRMWARE_CFG=firmware.cfg

include ../common/cc65.rules.mk
```

Compared to previous example, there are two changes. First one is the addition of the new file, `firmware.cfg` that will be used in linking our ROM image. The other is more important and it is inclusion of the `common/cc65.rules.mk` file which is specific to CC65-based builds.

Let's take a short look at the shared `cc65.rules.mk` file:

```makefile
include ../common/tools.mk

BUILD_FOLDER=../build
TEMP_FOLDER=$(BUILD_FOLDER)/$(ROM_NAME)
ROM_FILE=$(BUILD_FOLDER)/$(ROM_NAME).bin
MAP_FILE=$(TEMP_FOLDER)/$(ROM_NAME).map

ASM_OBJECTS=$(ASM_SOURCES:%.s=$(TEMP_FOLDER)/%.o)

# Compile assembler sources
$(TEMP_FOLDER)/%.o: %.s
	@$(MKDIR_BINARY) $(MKDIR_FLAGS) $(TEMP_FOLDER)
	$(CA65_BINARY) $(CA65_FLAGS) -o $@ -l $(@:.o=.lst) $<

# Link ROM image
$(ROM_FILE): $(ASM_OBJECTS) $(FIRMWARE_CFG)
	@$(MKDIR_BINARY) $(MKDIR_FLAGS) $(BUILD_FOLDER)
	$(LD65_BINARY) $(LD65_FLAGS) -C $(FIRMWARE_CFG) -o $@ -m $(MAP_FILE) $(ASM_OBJECTS)

# Default target
all: $(ROM_FILE)

# Build and dump output
test: $(ROM_FILE)
	$(HEXDUMP_BINARY) $(HEXDUMP_FLAGS) $<
	$(MD5_BINARY) $<

# Clean build artifacts
clean:
	$(RM_BINARY) -f $(ROM_FILE) \
	$(MAP_FILE) \
	$(ASM_OBJECTS) \
	$(ASM_OBJECTS:%.o=%.lst)
```

Starting from the bottom, you can see the familiar `all`, `test` and `clean` targets. Nothing new there, so let's focus on the first half.

We have new file definition (`MAP_FILE`) - it will be generated at link time and it will provide all the information about memory areas, segments, symbols and addresses established at link time.

Next line can be pretty confusing, but this is important, as this is one of the most powerful features of `make`:

```makefile
ASM_OBJECTS=$(ASM_SOURCES:%.s=$(TEMP_FOLDER)/%.o)
```

This line will result of building list of object files (which will be created by compiler and used as input by linker) based on the list of assembly files using pattern replacement. Literally it means "build ASM_OBJECTS list that will contain all entries in ASM_SOURCES list matching pattern %.s and replace each %.s name with value of TEMP_FOLDER/%.o". In our case it will take the single item (`blink.s`) and replace it by `../build/02_blink/blink.o`.

This kind of pattern substitution is very powerful in `make` and it allows you to generate lists of dependencies for instance.

Now that we have a list of object files, generated from list of sources to be compiled, we can tell make how to compile each and every file:

```makefile
$(TEMP_FOLDER)/%.o: %.s
	@$(MKDIR_BINARY) $(MKDIR_FLAGS) $(TEMP_FOLDER)
	$(CA65_BINARY) $(CA65_FLAGS) -o $@ -l $(@:.o=.lst) $<
```

This means: if you need some object file (any name whatsoever) in TEMP_FOLDER location, it can be created using this recipe, depending on assembly file with identical name (with .s extension). The recipe consists of two commands:

1. `mkdir -p ../build/02_blink` - create directory in which the object file will be saved,
2. `ca65 --cpu 65C02 -o ../build/02_blink/blink.o -l ../build/02_blink/blink.lst blink.s` - compile `blink.s` file using 65C02 opcode set and generate object file (`blink.o`) and listning file (`blink.lst`) in `../build/02_blink/` folder.

Note how listning file is generated from the recipe target name: `$(@:.o=.lst)` means take the target name (`@`) and replace `.o` by `.lst`. Simple, efficient and once you get used to it, also pretty convenient.

Obviously, this target isn't very useful on it's own, but combined with recipe for ROM binary file creation it makes sense:

```makefile
$(ROM_FILE): $(ASM_OBJECTS) $(FIRMWARE_CFG)
	@$(MKDIR_BINARY) $(MKDIR_FLAGS) $(BUILD_FOLDER)
	$(LD65_BINARY) $(LD65_FLAGS) -C $(FIRMWARE_CFG) -o $@ -m $(MAP_FILE) $(ASM_OBJECTS)
```

Here we define how to build ROM file. First, it depends on two things - list of object files (`ASM_OBJECTS`) and the `firmware.cfg` file. Each time any of the object files or firmware configuration changes, it forces linking ROM binary again.

The recipe contains of two commands. First one is simply building the target directory (`../build`) where the target ROM will be saved.

Second part is invoking the linker with the following command:

`ld65 -C firmware.cfg -o ../build/02_blink.bin -m ../build/02_blink/02_blink.map ../build/02_blink/blink.o`

It means: build the bin file with accompanying map file using this firmware configuration file and linking the following objects (listed at the end).

Simple, isn't it?

Build it as you did before, take a look at map and lst files. Read the `makefile` again, make sure all the dependencies are clear and the desired flow makes sense and when ready, move on to next section.