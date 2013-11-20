#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Test::More;

use lib 'lib';

BEGIN { use_ok 'Build::VM::Guest' };

my $vm_guest = new_ok 'Build::VM::Guest' => [
    'name'    => 'foo-test',
    'memory'  => 2048 * 1024,
    'disk_list'   => [[qw(foo-test1 vda)], [qw(foo-test2 vbd)]],
];

say $vm_guest->disks;

done_testing;
