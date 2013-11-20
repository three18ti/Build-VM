#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Test::More;
use Test::Output;

use lib 'lib';

BEGIN { use_ok 'Build::VM::Host'};

my $vm_system = new_ok 'Build::VM::Host' => [
    rbd_hosts_list   => [qw(192.168.0.2 192.168.0.35 192.168.0.40)],
];

stdout_is
    sub { say $_ foreach $vm_system->rbd_hosts },
    "192.168.0.2\n192.168.0.35\n192.168.0.40\n", "Got correct hosts";

done_testing;

