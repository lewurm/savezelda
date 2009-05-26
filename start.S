// Copyright 2008-2009  Segher Boessenkool  <segher@kernel.crashing.org>
// This code is licensed to you under the terms of the GNU GPL, version 2;
// see file COPYING or http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

#define XSTR(x) #x
#define ISTR(x) XSTR(x)

	.section .start,"ax"

	// Uninteresting stuff.
	.incbin "head.b"

	// "Link".  This is displayed on the load menu, so make it nice.
0:	.ascii ISTR(NAME)
	.fill 17 - (. - 0b)

	// "Epona".  Hungry horse eats the stack.
	.fill 0xe8,1,'3'

	// The return address on the stack.
	.long start

	// Align things properly -- there's code after this.
	.fill 7,1,'S'
	.balign 4,0

start:
	// Set up a stack frame.
	lis 1,0x8080 ; li 0,0 ; stwu 0,-64(1)

	// Pass the address we are called from, to determine region.
	mflr 3

	// Go for it!
	b main
