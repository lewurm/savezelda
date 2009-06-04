#!/bin/bash
out=$1; shift
dd if=/dev/zero bs=1 count=$((0x4000)) of=$out 2>/dev/null
start=0
for save in $@; do
       dd if=$save of=$out bs=1 seek=$start conv=notrunc  2>/dev/null
       start=$((start+0xa94))
done
