#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Test::More;

use lib 'lib';

BEGIN { use_ok 'Build::VM' }

my $bvm = new_ok 'Build::VM' => [
    'base_image_name'   => 'ubuntu-server-13.10-x86_64-base',
    'snap_name'         => '2013-11-13',
    'guest_name'        => 'build_vm_test',
    'guest_memory'      => 4096,
    'storage_disk_size' => 20,
    'rbd_hosts'         => [qw(192.168.0.35 192.168.0.2 192.168.0.40)],
];

#is $bvm->host->, "192.168.0.35192.168.0.2192.168.0.40",
#    "rbd hosts are as expected";

#use Data::Dump;
#print dd $bvm->disk_list;

done_testing;
__END__
use Template;


my $tt = Template->new({

}) || die "$Template::ERROR\n";

my $output = '';
use Build::VM::Guest;
use Build::VM::System;
$tt->process(
    'server-base.tt',    
    {
        guest   =>  Build::VM::Guest->new(
                    name    => 'foo-test',
                    memory  => 2048 * 1024,
                    disk_list   => [qw(foo-test1 foo-test2)],
                    cdrom       => '/media/ubuntu-13.10-server-amd64.iso',
                ),
        system  =>  Build::VM::System->new(
                    rbd_hosts_list   => [qw(192.168.0.2 192.168.0.35 192.168.0.40)],
                ),
    },
    'server-base.out'
);

done_testing;
