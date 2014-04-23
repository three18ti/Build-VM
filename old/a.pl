#!/usr/bin/perl
use 5.010;
use strict;
use warnings;

my @array = ('a', 'b', 'c', 'd',);

my $arrayref = [qw(a b c d)];

my %hash = ( 'foo' => 'bar');

my $hashref = { foo => 'bar' };

say "Array: " . ref @array;

say "ArrayRef: " . ref $arrayref;

say "Hash: " . ref %hash;

say "HashRef: " . ref $hashref;
