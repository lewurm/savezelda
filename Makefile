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


targets := rzde-3.2.bin rzde-3.3.bin rzde-3.4.bin
targets += rzdj-3.2.bin rzdj-3.3.bin rzdj-3.4.bin
targets += rzdp-3.2.bin rzdp-3.3.bin rzdp-3.4.bin
targets-short := rzde rzdj rzdp

objs := twilight.o

ppms := $(targets-short:%=%-icon.ppm) generic-banner.ppm
assets := title.bin $(ppms)

loader := loader/loader.bin


titleid = $(shell perl titleid.pl $(1))


# System menu 3.3 checks for the exploit, when a) you copy a save from SD,
# and b) when the menu starts up; but for a) it only looks at the first
# zeldaTp.dat file, and for b) it allows any file of non-aligned length.
#
# System menu 3.4 only looks at the last file in the wad when installing.
#
# System menu 4.0 finally avoids such silly bugs.

define twintig
	D=$(call titleid,$(1));				\
	$(TOOLS)/twintig $$D $@ toc-$1
endef


all: $(targets)

$(filter %-3.2.bin,$(targets)): %-3.2.bin: %.data
$(filter %-3.3.bin,$(targets)): %-3.3.bin: %.data zero16k
$(filter %-3.4.bin,$(targets)): %-3.4.bin: %.data FAILURE
$(targets): %.bin: toc-% $(assets)
	@echo "  TWINTIG   $@"
	$(Q)$(call twintig,$*)

saves := $(targets-short:%=%.data)

rzde.data: rzde0.slot rzde2.slot
rzdp.data: rzdp0.slot
rzdj.data: rzdj0.slot
$(saves): $(loader)
	@echo "  ZELDAPACK $@"
	$(Q)./pack.sh $@ $(filter %.slot,$^)
	$(Q)$(TOOLS)/zelda-cksum $@
	$(Q)cat $(loader) >> $@
	$(Q)printf '\0' >> $@

slots := rzde0.slot rzde2.slot rzdj0.slot rzdp0.slot

$(slots): %.slot: %.elf
	@echo "  OBJCOPY   $@"
	$(Q)$(OBJCOPY) -Obinary $< $@

elfs := $(slots:.slot=.elf)

rzde0.elf: baddr := 0x8046a3e0+0
rzde2.elf: baddr := 0x804519e0+0x0a94
rzdj0.elf: baddr := 0x8044f860+0
rzdp0.elf: baddr := 0x804522e0+0
$(elfs): %.elf: twilight.lds %.o $(objs)
	@echo "  LINK      $@"
	$(Q)$(LD) --defsym baddr=$(baddr) -T $^ -o $@

exploit-objs := $(elfs:.elf=.o)

$(exploit-objs): slot-name := Twilight Hack
rzde0.o: slot-name := TwilightHack0
rzde2.o: slot-name := TwilightHack2
$(exploit-objs): %.o: start.S head.b
	@echo "  ASSEMBLE  $@"
	$(Q)$(CC) $(CFLAGS) -D NAME="$(slot-name)" -c $< -o $@

%.o: %.c
	@echo "  COMPILE   $@"
	$(Q)$(CC) $(CFLAGS) -c $< -o $@

title.bin: .version
	@echo "  TITLEBIN  $@"
	$(Q)perl make-title-bin.pl > $@

.version: FORCE
	$(Q)./describe.sh > .$@-tmp
	$(Q)cmp -s $@ .$@-tmp || cp .$@-tmp $@
	$(Q)rm .$@-tmp

$(ppms): %.ppm: %.png
	@echo "  PPM       $@"
	$(Q)convert $< $@

zero16k:
	$(Q)dd if=/dev/zero bs=16384 count=1 2>/dev/null > $@

FAILURE:
	$(Q)echo FAILURE > $@

$(loader): FORCE .version
	$(Q)$(MAKE) -C loader

FORCE:

clean:
	-rm -f $(targets) $(saves) $(elfs) $(exploit-objs) $(objs) $(slots)
	-rm -f .version title.bin zero16k FAILURE
	$(MAKE) -C loader clean
