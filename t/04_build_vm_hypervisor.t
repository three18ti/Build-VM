#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Test::More;
use Test::Output;

use lib 'lib';

BEGIN { use_ok 'Build::VM::Hypervisor'};

my $hv = new_ok 'Build::VM::Hypervisor' => [
                    'address'   => '192.168.0.35',
                ];
is $hv->uri, 'qemu+ssh://192.168.0.35/session?socket=/var/run/libvirt/libvirt-sock',
    "uri is as expected";
is $hv->guest_exists('asdf'), '0', "Guest asdf doesn't exist";

my $vm_name = $hv->vm_list_active->[0]->get_name;
is $hv->guest_exists($vm_name), '1',
    "Guest $vm_name Exists";

done_testing

__END__
stdout_is
    sub { say $_ foreach $vm_system->rbd_hosts },
    "192.168.0.2\n192.168.0.35\n192.168.0.40\n", "Got correct hosts";

done_testing;

