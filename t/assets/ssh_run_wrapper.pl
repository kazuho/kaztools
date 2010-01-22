#! /usr/bin/perl

use strict;
use warnings;

exit 0
    unless @ARGV;
eval join ' ', @ARGV;
die $@
    if $@;

