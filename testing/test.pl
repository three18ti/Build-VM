#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use lib 'lib';
use Build::VM;

my $base_image_name     = 'ubuntu-server-13.10-x86_64-base';
my $snap_name           = '2013-11-13';
my $guest_name          = 'build_vm_bin';
my $guest_memory        = 4096;
my $storage_disk_size   = 20;
my $rbd_hosts           = [qw(192.168.0.35 192.168.0.2 192.168.0.40)];
#my $hvm_address         = '192.168.0.35';
my $hvm_address         = shift @ARGV || '192.168.0.35';

my $bvm = Build::VM->new(
    base_image_name     => $base_image_name,
    snap_name           => $snap_name,
    guest_name          => $guest_name,
    guest_memory        => $guest_memory,
    storage_disk_size   => $storage_disk_size,
    rbd_hosts           => $rbd_hosts,
    hvm_address         => $hvm_address,
    template_name       => 'server-no-config.tt',
);

$bvm->guest_xml;

my $dom = $bvm->deploy_ephemeral;

say "Checking vm deployed";
system "virsh list";

my $uri = $bvm->hvm->uri;
say $uri;

#my $vmm = Sys::Virt->new( uri => $uri );
#my @domains = $vmm->list_domains();

my @domains = $bvm->hvm->print_vm_list;

#use Data::Dump;
#print dd @domains;

$dom->destroy;

