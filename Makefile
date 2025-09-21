# PLATFORM_WINDOWS, PLATFORM_LINUX, PLATFORM_WEB
PLATFORM ?= PLATFORM_LINUX

# DEBUG, RELEASE
BUILD_MODE ?= DEBUG

# true, false
INCLUDE_CONSOLE ?= true
ifeq ($(INCLUDE_CONSOLE), true)
    MWINDOWS_FLAG =
else
    MWINDOWS_FLAG = -mwindows
endif

PLATFORM_OS ?= $(shell uname)

# Directories
RAYLIB_DIR = $(HOME)/raylib
OUTDIR ?= build/BVHView
INCLUDE_DIR = -I ./ -I ./src/external -I $(RAYLIB_DIR)/raylib/src -I $(RAYLIB_DIR)/raygui/src

# Platform-specific settings
ifeq ($(PLATFORM),PLATFORM_WINDOWS)
    CC = x86_64-w64-mingw32-gcc
    EXT = .exe
    LIBRARY_DIR = -L $(RAYLIB_DIR)/lib/windows
    LIBS = -lraylib -lopengl32 -lgdi32 -lwinmm
else ifeq ($(PLATFORM),PLATFORM_LINUX)
    CC = gcc
    EXT =
    LIBRARY_DIR = -L $(RAYLIB_DIR)/lib/linux
    LIBS = -lraylib -lGL -lm
else ifeq ($(PLATFORM),PLATFORM_WEB)
    CC = emcc
    EXT = .html
    LIBRARY_DIR = -L $(RAYLIB_DIR)/raylib/src
    LIBS =
endif

# Common defines
DEFINES = -D _DEFAULT_SOURCE -D RAYLIB_BUILD_MODE=$(BUILD_MODE) -D $(PLATFORM)

# Build mode flags
ifeq ($(BUILD_MODE),RELEASE)
    CFLAGS_DEBUG = -ggdb -pg
    CFLAGS_RELEASE = -D NDEBUG -O3
else
    CFLAGS_DEBUG = -ggdb -pg
    CFLAGS_RELEASE =
endif

# Platform-specific compilation flags
CFLAGS_PLATFORM := $(DEFINES) $(INCLUDE_DIR) $(LIBRARY_DIR)

# Compilation flags
ifeq ($(PLATFORM),PLATFORM_WINDOWS)
    CFLAGS := ./res/bvhview.res $(CFLAGS_PLATFORM) -Wall $(MWINDOWS_FLAG) $(CFLAGS_$(BUILD_MODE))
else ifeq ($(PLATFORM),PLATFORM_LINUX)
    CFLAGS := $(CFLAGS_PLATFORM) -Wall -Wno-format-truncation $(CFLAGS_$(BUILD_MODE))
else ifeq ($(PLATFORM),PLATFORM_WEB)
    WEB_FLAGS_RELEASE = -Os -s USE_GLFW=3 -s FORCE_FILESYSTEM=1 -s MAX_WEBGL_VERSION=2 -s ALLOW_MEMORY_GROWTH=1 -sMINIFY_HTML=0 -s STACK_SIZE=16777216 --shell-file ./shell.html
    WEB_FLAGS_DEBUG = -Os -s ASSERTIONS=2 -s SAFE_HEAP=1 -s STACK_OVERFLOW_CHECK=2 -s USE_GLFW=3 -s FORCE_FILESYSTEM=1 -s MAX_WEBGL_VERSION=2 -s ALLOW_MEMORY_GROWTH=1 -sMINIFY_HTML=0 -s STACK_SIZE=16777216 -s EXPORTED_RUNTIME_METHODS=["HEAPF32"] --shell-file ./shell.html
    CFLAGS := $(CFLAGS_PLATFORM) $(RAYLIB_DIR)/lib/web/libraylib.web.a $(WEB_FLAGS_$(BUILD_MODE))
endif

.PHONY: all clean

all: bvhview

bvhview: src/bvhview.c src/additions.c src/external/cwalk.c
	mkdir -p $(OUTDIR)
	cp -r assets $(OUTDIR)
	cp wasm-server.py $(OUTDIR)
	cp -r res $(OUTDIR)
	$(CC) -o $(OUTDIR)/$@$(EXT) $^ $(CFLAGS) $(LIBS)

clean:
	rm -f $(OUTDIR)/bvhview$(EXT)
