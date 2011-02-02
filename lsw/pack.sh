#!/bin/bash
TARGET=$1; shift
cat $* /dev/zero | dd bs=1024 count=128 2>/dev/null > $TARGET
