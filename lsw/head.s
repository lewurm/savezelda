# Copyright      2011  roto <roto@mozy.org>
# This code is licensed to you under the terms of the GNU GPL, version 2;
# see file COPYING or http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

	bptr = 0x91178ea0

0:
	# Part of the savefile
	.long 0x00000001, 0x00000000, 0x00000000, 0x00000000
	.long 0x00000000, 0x00000013, 0x0000000d, 0x00000000
	.long 0x00000002, 0x00000000, 0x000007db, 0x00000000
	.long 0x00000001, 0x0000029e, 0x0000019d, 0x00050000
	.long 0x01010008, 0x060a0100, 0x00000001, 0x00000000
	.long 0x00000000, 0x00000000, 0x00000000, 0x00000000

	# Filler
	 .fill 0xF60 - (. - 0b)

exploitv2:
	# This is necessary for the 2nd exploit  (first release) of LSW
	.include "exploit2.s"

	# More filler
	.fill 0x7860 - (. - 0b)	

	# Insert rest of the save
	.incbin "head.b"

	# Smack the stack.
	.long 0x11111111, 0x11111111, 0x11111111, 0x11111111
	.long 0x11111111, 0x11111111, 0x11111111, 0x11111111
	.long 0x11111111, 0x11111111, 0x11111111, 0x11111111
	.long 0x11111111, 0x11111111, 0x11111111, 0x11111111
	.long 0x11111111, 0x11111111, 0x11111111, 0x11111111
	.long 0x11111111, 0x11111111, 0x11111111, 0x11111111
	.long 0x11111111, 0x11111111, 0x11111111, 0x11111111
	.long 0x11111111, 0x11111111, 0x11111111, 0x11111111
	.long 0x11111111

	# Depending on the version we jump now to exploit.s or to "exploit2v:"
	.long 0x11111111,       bptr, 0x11111111, 0x11111111

	.fill 0x10000 - (. - 0b)
