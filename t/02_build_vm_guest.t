#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Test::More;

use lib 'lib';

BEGIN { use_ok 'Build::VM::Guest' };

my $vm_guest = Build::VM::Guest->new(
    name    => 'foo-test',
    memory  => 2048 * 1024,
    disk_list   => [qw(foo-test1 foo-test2)],
);

say $vm_guest->disks;

done_testing;
