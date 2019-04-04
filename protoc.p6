#!/usr/bin/env perl6

use lib '.';
use protobuf;

my $file = slurp;
say protobuf.new.parse($file);

