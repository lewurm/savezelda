/* Copyright 2008-2009  Segher Boessenkool  <segher@kernel.crashing.org>
   This code is licensed to you under the terms of the GNU GPL, version 2;
   see file COPYING or http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt  */

OUTPUT_FORMAT("elf32-powerpc")
OUTPUT_ARCH(powerpc:common)

SECTIONS {
/*	audio_stop = 0x800a3e80;
	video_stop = 0x800b2120;

	main = 0x90000020; */

	.head 0x805a909c :
	{
		head.o(.start)
		*(.text)
		*(.rodata .rodata.*)
		*(.data)
		*(.bss)
	}
}
