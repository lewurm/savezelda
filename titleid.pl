#!/usr/bin/perl
print "00010000", map { sprintf "%02x", ord uc } split //, $ARGV[0];
