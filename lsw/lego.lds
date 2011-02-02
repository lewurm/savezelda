/* Copyright 2008-2009  Segher Boessenkool  <segher@kernel.crashing.org>
   This code is licensed to you under the terms of the GNU GPL, version 2;
   see file COPYING or http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt  */

OUTPUT_FORMAT("elf32-powerpc")
OUTPUT_ARCH(powerpc:common)

SECTIONS {
	audio_stop = 0x8038ce90;
	video_stop = 0x80399708;

	save = 0x91168ea0;
	bptr = 0x91178ea0;
	
	main = 0x90000020;

	.twilight save :
	{
		rli*.o(.start)
		*(.text)
		*(.rodata .rodata.*)
		*(.data)
		*(.bss)
		/* . = 0x0a94; */
	}
}
