# There potential problem with common source files 
# they need to be build for each platform independetly
# as a workaround use `make clean` before each build

# TODO: return back debug build (with -DSGIP_DEBUG)

# Lib version 0.4.2 

TARGET ?= ARM9

# Toolchain
CC = arm-none-eabi-gcc
AR = arm-none-eabi-gcc-ar

ARCHFLAGS = -mthumb \
  			-mthumb-interwork
ARFLAGS = -rcs
INCLUDE_FLAGS = -Iinclude

COMMON_SRC_DIR = source
COMMON_SRC_FILES = $(wildcard $(COMMON_SRC_DIR)/*.c) $(wildcard $(COMMON_SRC_DIR)/*.s)

ifeq ($(TARGET),ARM9)
	BIN_NAME = libdswifi9.a

	ARM9_SRC_DIR = source/arm9

	SRC_FILES = $(wildcard $(ARM9_SRC_DIR)/*.c)

	ARCHFLAGS += -march=armv5te \
				 -mtune=arm946e-s \
				 -DARM9
else
	BIN_NAME = libdswifi7.a

	ARM7_SRC_DIR = source/arm7
	SRC_FILES = $(wildcard $(ARM7_SRC_DIR)/*.c)

	ARCHFLAGS += -mcpu=arm7tdmi \
				 -mtune=arm7tdmi \
				 -DARM7
endif

OBJ_FILES += $(patsubst %.s,%.o, $(patsubst %.c,%.o, $(COMMON_SRC_FILES) $(SRC_FILES)))

CFLAGS = -Wall -Os \
		 -ffunction-sections \
		 -fdata-sections \
		 -fomit-frame-pointer \
		 -ffast-math \
		 $(ARCHFLAGS) \
		 $(INCLUDE_FLAGS)

ASFLAGS = -x assembler-with-cpp \
		  $(ARCHFLAGS) \
		  $(INCLUDE_FLAGS)

# Build rules
$(BIN_NAME): $(OBJ_FILES)
	$(AR) $(ARFLAGS) $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(CC) $(ASFLAGS) -c $< -o $@

# General rules
.PHONY: all clean rebuild install

all: $(BIN_NAME)

clean:
	rm -rf $(OBJ_FILES) $(BIN_NAME)

rebuild: clean all

PREFIX ?= /usr/lib

install: $(INCLUDE_PATHES)
	install -d $(DESTDIR)$(PREFIX)/arm-none-eabi/include/dswifi
	cp -fr include/* $(DESTDIR)$(PREFIX)/arm-none-eabi/include/dswifi
	chmod -R 644 $(DESTDIR)$(PREFIX)/arm-none-eabi/include/dswifi
	install -d $(DESTDIR)$(PREFIX)/arm-none-eabi/lib
	install -m 644 $(BIN_NAME) $(DESTDIR)$(PREFIX)/arm-none-eabi/lib
