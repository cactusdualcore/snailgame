# Adopted from https://makefiletutorial.com/#makefile-cookbook

# Thanks to Job Vranish (https://spin.atomicobject.com/2016/08/26/makefile-c-projects/)
TARGET_EXEC := snailgame

BUILD_DIR := ./target
SRC_DIRS := ./src

# Adopted from https://gist.github.com/sighingnow/deee806603ec9274fd47
OS := Unknown
ifeq ($(OS),Windows_NT)
	OS := Windows
else
	UNAME := $(shell uname -s)
	ifeq ($(UNAME),Linux)
		OS := Linux
	endif
	ifeq ($(UNAME),Darwin)
		OS := OSX
	endif
endif

# Find all the C and C++ files we want to compile
# Note the single quotes around the * expressions. The shell will incorrectly expand these otherwise, but we want to send the * directly to the find command.
SRCS := $(shell find $(SRC_DIRS) -name '*.cpp' -or -name '*.c' -or -name '*.s')

# Prepends BUILD_DIR and appends .o to every src file
# As an example, ./your_dir/hello.cpp turns into ./build/./your_dir/hello.cpp.o
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

# String substitution (suffix version without %).
# As an example, ./build/hello.cpp.o turns into ./build/hello.cpp.d
DEPS := $(OBJS:.o=.d)

# Every folder in ./src will need to be passed to GCC so that it can find header files
INC_DIRS := $(shell find $(SRC_DIRS) -type d)
# Add a prefix to INC_DIRS. So moduleA would become -ImoduleA. GCC understands this -I flag
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# The -MMD and -MP flags together generate Makefiles for us!
# These files will have .d instead of .o as the output.
CPPFLAGS := $(INC_FLAGS) -MMD -MP

# Link all necessary libraries. Honestly, you're on your own with checking that these are installed
# and working.
LIB_FLAGS :=
ifeq ($(OS), Linux)
# Also, this won't work on wayland. You probably have to link against libwayland instead of libx11.
	LIB_FLAGS := -lraylib -lGL -lm -lpthread -ldl -lrt -lX11
endif
ifeq ($(OS), OSX)
	OBJS += libraylib.a
	LIB_FLAGS := -framework CoreVideo -framework IOKit -framework Cocoa -framework GLUT -framework OpenGL
endif

# The final build step.
$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS)
	$(CXX) $(OBJS) $(LIB_FLAGS) -o $@ $(LDFLAGS)

# Build step for C source
$(BUILD_DIR)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# Build step for C++ source
$(BUILD_DIR)/%.cpp.o: %.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@


.PHONY: clean run
clean:
	rm -r $(BUILD_DIR)

run: $(BUILD_DIR)/$(TARGET_EXEC)
	@$(BUILD_DIR)/$(TARGET_EXEC)

# Include the .d makefiles. The - at the front suppresses the errors of missing
# Makefiles. Initially, all the .d files will be missing, and we don't want those
# errors to show up.
-include $(DEPS)
