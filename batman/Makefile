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


targets := rlbp.bin rlbj.bin rlbe.bin

ppms := $(targets:%.bin=%-icon.ppm) rlb-banner.ppm
assets := title.bin $(ppms)

loader := ../loader/loader.bin


titleid = $(shell perl titleid.pl $(1))


define twintig
	D=$(call titleid,$(1));				\
	$(TOOLS)/twintig $$D $@ toc-$1
endef


all: $(targets)

$(targets): %.bin: toc-% FILE_V28 $(assets)
	@echo "  TWINTIG   $@"
	$(Q)$(call twintig,$*)

FILE_V28: head.bin exploit.bin $(loader)
	@echo "  LEGOSTACK $@"
	$(Q)./pack.sh $@ $^
	$(Q)$(TOOLS)/lego-cksum $@

head.bin: head.elf
	@echo "  OBJCOPY   $@"
	$(Q)$(OBJCOPY) -Obinary $< $@

exploit.bin: exploit.elf
	@echo "  OBJCOPY   $@"
	$(Q)$(OBJCOPY) -Obinary $< $@

exploit.elf: lego.lds exploit.o
	@echo "  LINK      $@"
	$(Q)$(LD) -T $^ -o $@

head.elf: head.o
	@echo "  LINK      $@"
	$(Q)$(LD) -e 0 $< -o $@

exploit.o: exploit.s
	@echo "  ASSEMBLE  $@"
	$(Q)$(CC) $(CFLAGS) -c $< -o $@

head.o: head.s head.b
	@echo "  ASSEMBLE  $@"
	$(Q)$(CC) $(CFLAGS) -c $< -o $@

title.bin: ../.version
	@echo "  TITLEBIN  $@"
	$(Q)perl make-title-bin.pl > $@

../.version: FORCE
	$(Q)$(MAKE) -C .. .version

$(ppms): %.ppm: %.png
	@echo "  PPM       $@"
	$(Q)convert $< $@

$(loader): FORCE
	$(Q)$(MAKE) -C ../loader

FORCE:

clean:
	-rm -f $(targets) FILE_V28
	-rm -f exploit.bin exploit.elf exploit.o
	-rm -f head.bin head.elf head.o
	-rm -f title.bin
