/* Copyright 2008-2009  Segher Boessenkool  <segher@kernel.crashing.org>
   This code is licensed to you under the terms of the GNU GPL, version 2;
   see file COPYING or http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt  */

OUTPUT_FORMAT("elf32-powerpc")
OUTPUT_ARCH(powerpc:common)

SECTIONS {
	gecko_print = 0x802facf0;

	nand_open_E0 = 0x80371f50;
	nand_read_E0 = 0x80371710;
	audio_stop_E0 = 0x8034607c;
	graphics_stop_E0 = 0x8035c930;

	nand_open_E2 = 0x8035c988;
	nand_read_E2 = 0x8035c148;
	audio_stop_E2 = 0x80330a4c;
	graphics_stop_E2 = 0x80347368;

	nand_open_P0 = 0x8035cdb8;
	nand_read_P0 = 0x8035c578;
	audio_stop_P0 = 0x80330e7c;
	graphics_stop_P0 = 0x80347798;

	nand_open_J0 = 0x8035e440;
	nand_read_J0 = 0x8035dc00;
	audio_stop_J0 = 0x8033256c;
	graphics_stop_J0 = 0x80348e20;

	.twilight baddr :
	{
		rzd*.o(.start)
		*(.text)
		*(.rodata .rodata.*)
		*(.data)
		*(.bss)
		. = 0x0a94;
	}
}
