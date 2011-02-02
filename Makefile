# Copyright 2008-2009  Segher Boessenkool  <segher@kernel.crashing.org>
# This code is licensed to you under the terms of the GNU GPL, version 2;
# see file COPYING or http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt


# Configuration:

# What toolchain prefix should we use
CROSS ?= broadway-

# Where are the tools (http://git.infradead.org/users/segher/wii.git)
TOOLS ?= $(HOME)/wii/segher

# End of configuration.



# Set CC, LD, OBJCOPY based on CROSS, unless they are set already

ifeq ($(origin CC), default)
	CC := $(CROSS)gcc -m32
endif
ifeq ($(origin LD), default)
	LD := $(CROSS)ld
endif
OBJCOPY ?= $(CROSS)objcopy


# The compiler flags we need.

CFLAGS := -Wall -W -Os -ffreestanding -mno-eabi -mno-sdata -mcpu=750


# Build with "V=1" to see the commands executed; be quiet otherwise.

ifeq ($(V),1)
	Q :=
else
	Q := @
	MAKEFLAGS += --no-print-directory
endif


all:

.version: FORCE
	$(Q)./describe.sh > .$@-tmp
	$(Q)cmp -s $@ .$@-tmp || cp .$@-tmp $@
	$(Q)rm .$@-tmp

all: FORCE .version
	$(Q)$(MAKE) -C loader
	$(Q)$(MAKE) -C twilight
	$(Q)$(MAKE) -C lego
	$(Q)$(MAKE) -C batman
	$(Q)$(MAKE) -C lsw

FORCE:

clean:
	-rm -f .version
	$(MAKE) -C loader clean
	$(MAKE) -C twilight clean
	$(MAKE) -C lego clean
	$(MAKE) -C batman clean
	$(MAKE) -C lsw clean
