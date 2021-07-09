# Introducing `make` utility

To make your transition to CC65 toolchain easier, I decided to start with something familiar, something that you have already had some experience with. When you open `01_blink_vasm` folder in `cc65-tools-main/tutorial` in Visual Studio Code, you will notice two files there. `blink.s` is the original source code from [Ben Eater's website](https://eater.net/downloads/blink.s), but I want to focus first on the second one: `makefile`.

As you probably remember, to generate ROM file from `blink.s` you had to invoke the following command:

`vasm6502_oldstyle -Fbin -dotdir blink.s`

As a result you will get `a.out` file containing ROM contents. Very simple indeed, but there are two other options you might want to add to is for your convenience:

`vasm6502_oldstyle -Fbin -dotdir -o blink.bin -L blink.lst blink.s`

You might remember the meaning of these parameters, but just to recap:

- `-Fbin` means to generate binary file format suitable for ROM flashing,
- `-dotdir` means that the assembler directives are to be prepended with dot (like `.word` or `.org`),
- `-o blink.bin` specifies output file name (instead of default `a.out`),
- `-L blink.lst` causes listing file to be created with `blink.lst` name. This file will contain information compiled during assembly,
- `blink.s` is a source file name to be compiled.

For some of the newer languages there are some other build management tools, like Gradle, Maven and so forth, but in the area of low level languages (asm, C/C++ and the like) `make` in the _de facto_ standard. Unlike the newer tools, it's pretty simple in its philosophy and as such it is extremely flexible and versatile.

## What does `make` do

Contrary to popular belief, `make` has nothing to do with compilation or linking, it's not a build utility either. The concept behind the tool is simple - to provide easy to define, manage and share recipes for generating one file from the others. Each "recipe" consists of three main components:

1. Name of the file to be created (the expected result of the recipe),
2. List of files that the expected result depends on,
3. List of commands to be executed to generate the expected result from the dependencies.

Looking back at the simple compilation example above, these are the components in this particular case:

1. Target file of the recipe is `blink.bin` - this is the ROM file we expect to receive,
2. `blink.s` is the only dependency that the target depends on,
3. The recipe is: `vasm6502_oldstyle -Fbin -dotdir -o <TARGET_NAME> -L <LISTING_NAME> <SOURCE_NAME>`

Whenever you invoke `make` with the target file name it will first check if the target file exists. If it doesn't, it will invoke the defined recipe. Otherwise, if the target already exists, it will check the timestamp of the dependencies and the target file. If any of the dependencies is newer than the target it will invoke the recipe again to rebuild the target with the new dependency. If target is newer than all the dependencies, the recipe will not be invoked.

And that's all. Simple, yet powerful enough, as you will soon learn. For `vasm` builds it doesn't seem very useful, but with all the extra features of CC65 you will see how helpful all that is.

## Look at sample `makefile`

By default, when you invoke `make`, it will look for recipes in file called `makefile` in current directory, and one is available in `tutorial/01_blink_vasm` folder, with the following contents:

````makefile
ROM_NAME=01_blink_vasm

ASM_SOURCES=blink.s

include ../common/vasm.rules.mk
````

As you can see, it's very simple, defining only two variables: `ROM_NAME` is the target bin file name and `blink.s` is the name of source file to be used during compilation. Last line refers to common rules file containing all the `vasm` recipes that use the above variables in compilation process. Let's take a look there:

````makefile
include ../common/tools.mk

BUILD_FOLDER=../build
TEMP_FOLDER=$(BUILD_FOLDER)/$(ROM_NAME)
ROM_FILE=$(BUILD_FOLDER)/$(ROM_NAME).bin
LST_FILE=$(TEMP_FOLDER)/$(ROM_NAME).lst

# Link ROM image
$(ROM_FILE): $(ASM_SOURCES)
	@$(MKDIR_BINARY) $(MKDIR_FLAGS) $(BUILD_FOLDER)
	@$(MKDIR_BINARY) $(MKDIR_FLAGS) $(TEMP_FOLDER)
	$(VASM_BINARY) $(VASM_FLAGS) -o $@ -L $(LST_FILE) $(ASM_SOURCES)

# Default target
all: $(ROM_FILE)

# Build and dump output
test: $(ROM_FILE)
	$(HEXDUMP_BINARY) $(HEXDUMP_FLAGS) $<
	$(MD5_BINARY) $<

# Clean build artifacts
clean:
	$(RM_BINARY) -f $(ROM_FILE) \
	$(LST_FILE) 
````

It uses another common file (`tools.mk`) that defines all the tool names and standard parameters. Let's take a look there for a second:

````makefile
VASM_BINARY=vasm6502_oldstyle

VASM_FLAGS=-Fbin -dotdir

HEXDUMP_BINARY=hexdump
HEXDUMP_FLAGS=-C

MD5_BINARY=md5sum

RM_BINARY=rm
RM_FLAGS=-f
MKDIR_BINARY=mkdir
MKDIR_FLAGS=-p
CP_BINARY=cp
CP_FLAGS=-f
````

There are other tools defined there, to be used in CC65 based compilation, but these are relevant to `vasm` builds, and as you can see, these are pretty simple. The point is to be able to change the tools  or flags globally if needed.

Going back to the `common/vasm.rules.mk`, there are four variables defines defined:

````makefile
BUILD_FOLDER=../build
TEMP_FOLDER=$(BUILD_FOLDER)/$(ROM_NAME)
ROM_FILE=$(BUILD_FOLDER)/$(ROM_NAME).bin
LST_FILE=$(TEMP_FOLDER)/$(ROM_NAME).lst
````

The point of these is that you don't want to mix your source files (`blink.s`) with temporary ones (`01_blink_vasm.lst`) or target ones (`01_blink_vasm.bin`), so these atrifacts are to be kept in separate folder (located in `tutorial/build`). Also, all the temporary files are to be kept in dedicated folder (`tutorial/build/01_blink_vasm`). At this point it might seem excessive to have such a deep folder structure, but as we go on you will understand the rationale behind it.

Anyway, having these variables defines, let's look at the target recipe:

````makefile
$(ROM_FILE): $(ASM_SOURCES)
	@$(MKDIR_BINARY) $(MKDIR_FLAGS) $(BUILD_FOLDER)
	@$(MKDIR_BINARY) $(MKDIR_FLAGS) $(TEMP_FOLDER)
	$(VASM_BINARY) $(VASM_FLAGS) -o $@ -L $(LST_FILE) $(ASM_SOURCES)
````

Format of a standard `make` recipe is as follows:

````makefile
TARGET_NAME: DEPENDENCY1 DEPENDENCY2 DEPENDENCY3 ...
	RECIPE_COMMAND1
	RECIPE_COMMAND2
	RECIPE_COMMAND3
	...
````

In this case, target name is defined in `ROM_FILE` variable (in this particular case `tutorial/build/01_build_vasm.bin`), list of dependencies is stored in variable`ASM_SOURCES` (containing single entry `blink.s`) and there are three commands in this recipe:

- `mkdir -p ../build` (see variable definitions above) will create `tutorial/build` folder for target ROM file,
- `mkdir -p ../build/01_blink_vasm` will create `tutorial/build/01_blink_vasm`  folder for temporary listning file,
- `vasm6502_oldstyle -Fbin -dotdir -o ../build/01_blink_vasm.bin -L ../build/01_blink_vasm/01_blink_vasm.lst blink.s` will compile `blink.s` file and generate resulting ROM file in bin format in target directory.

There are three things you might notice which are a bit hard to read:

1. Before each `mkdir` invocation there is `@` character - this is done to prevent `make` from printing this specific command to the output (it's optional, I made it only for clarity),
2. Instead of `ROM_FILE` variable, we pass `$@` as a value to `-o` parameter. This is one of built-in `make` variables and it contains current target name. It's pretty convenient shortcut, and as you will soon learn, there are quite a few like those which can be used in various scenarios,
3. Last but not least, there is another convention required for `make` to understand your recipes correctly: each line containing recipe command must start with `tab` character. Lines starting with spaces will not be interpreted properly!

This is not the end of the `makefile` though, so what else is there? If we omit the rest of the file, it will not be easy to use. In order to build the ROM file you would have to invoke `make ../build/01_blink_vasm.bin` command, and this wouldn't be very convenient, would it?

This is why we can define custom targets, which are not files itself, but act as one.

````makefile
all: $(ROM_FILE)
````

This convenience target means: invoking `make all` depends on `tutorial/build/01_blink_vasm.bin` file, and as a result it will be built using other recipes. This is how you can define complex build toolchains using file dependencies and ensure that only required files are rebuilt whenever change in the source code is introduced. Please note: there are no commands for this recipe defined, and it's fine, as soon as the ROM file is built we are done, there is nothing more to do.

Another target is `test`:

````makefile
test: $(ROM_FILE)
	$(HEXDUMP_BINARY) $(HEXDUMP_FLAGS) $<
	$(MD5_BINARY) $<
````

This target depends on ROM file, so when invoked, it will check if the file exists. If it doesn't, it will be created using other recipes. Unlike `all` target it doesn't stop here. When built is completed successfully, it will invoke two commands:

1. `hexdump -C ../build/01_blink_vasm.bin` will dump ROM contents to terminal, just like Ben does in his video to verify the build result,
2. `md5sum ../build/01_blink_vasm.bin` will compute and print MD5 checksum for the binary file - this is very useful for comparing different versions of the same file. Identical MD5 sum means that the files are most probably identical.

