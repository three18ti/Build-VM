#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Data::Dump;
use Test::More;# tests => 5;

use lib 'lib';

BEGIN { use_ok 'Build::VM' }

my $hvm_address = '192.168.15.35';

my $bvm = new_ok 'Build::VM' => [
    'base_image_name'   => 'ubuntu-server-13.10-x86_64-base',
    'snap_name'         => '2013-11-13',
    'guest_name'        => '01_test_vm_migrate',
    'guest_memory'      => 4096,
    'storage_disk_size' => 20,
    'rbd_hosts'         => [qw(192.168.0.35 192.168.0.2 192.168.0.40)],
    'hvm_address_list'  => [
        [shepard    => '192.168.15.2'], 
        [red6       => '192.168.15.40'],
        [kitt       => '192.168.15.35'], 
    ],
    'hvm_target'        => '192.168.15.35',
    'template_name'     => 'server-base.tt',
];

$bvm->build_disks unless $bvm->guest_exists($bvm->guest_name);
$bvm->deploy_ephemeral unless $bvm->guest_exists($bvm->guest_name);

#say $bvm->isa('Build::VM');
#say ref $bvm;

#my $dom = $bvm->get_dom($bvm->guest_name);
my $dom = $bvm->find_dom($bvm->guest_name);
say ref $dom;
#dd $dom;

$bvm->select_hvm('192.168.15.2')->print_vm_list;

$bvm->hvm_cluster->_dump_doms($bvm->select_hvm('192.168.15.35'), $bvm->select_hvm('192.168.15.2'));

#my $ddom = $dom->migrate( $bvm->select_hvm('192.168.15.35')->vmm, Sys::Virt::Domain::MIGRATE_LIVE);

#$dom = $bvm->migrate_dom($dom, $bvm->select_hvm('192.168.15.2'));
#$dom = $bvm->migrate_dom($dom, $bvm->select_hvm('192.168.15.35'));
#$dom = $bvm->migrate_dom($dom, $bvm->select_hvm('192.168.15.40'));
#$dom = $bvm->migrate_dom($dom, $bvm->select_hvm('192.168.15.35'));

$bvm->select_hvm('192.168.15.2')->print_vm_list;

#$dom->destroy;
#$bvm->remove_disks;
done_testing;
