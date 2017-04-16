#!/usr/bin/perl
use 5.010;
use strict;
use warnings;

my @test_case = ('hostname', 'name');

map { say "$_ matches" if $_ =~ /(host)*name/ } @test_case;
