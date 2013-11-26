#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;


use lib 'lib';
use Build::VM;
use Sys::Guestfs;

my $hvm_address = '192.168.0.35';

my $bvm = Build::VM->new(
    base_image_name   => 'ubuntu-server-13.10-x86_64-base',
    snap_name         => '2013-11-13',
    guest_name        => 'guestfish_test',
    guest_memory      => 4096,
    storage_disk_size => 20,
    rbd_hosts         => [qw(192.168.0.35 192.168.0.2 192.168.0.40)],
    hvm_address       => $hvm_address,
    template_name     => 'server-base.tt',
);

$bvm->build_disks;
#my $dom = $bvm->deploy_ephemeral;
#my $dom = $bvm->deploy_vm;
    $bvm->hvm->print_vm_list;

my $dom;
unless ($bvm->hvm->guest_exists($bvm->guest_name)) {
    $dom = $bvm->define_vm;

}
else {
    $dom = $bvm->hvm->get_dom($bvm->guest_name);
}


#use Data::Dump;
#say dd $disks;
my $disks = $bvm->disk_list;

my $g = Sys::Guestfs->new;
$g->set_trace(1);
$g->set_verbose(1);
#my $nrdisks = $g->add_domain ( $dom );

#my @partitions = $g->list_partitions;
#map { say "Partition: " if $_} @partitions;

my @server_list = map { "$_:6789" } $bvm->host->rbd_hosts;

$g->add_drive ( 
                "/libvirt-pool/" . $disks->[0][0], 
                format => 'raw', 
                protocol => 'rbd',
                server => \@server_list,
);

#$g->add_drive ( './foo.img', format => 'raw' );

$g->launch;
my @devices = $g->list_devices;
map { say } @devices;
map { say } $g->list_filesystems;
$g->mount('/dev/sda1', '/');
$g->touch('/hello');
$g->shutdown;
$g->close;

$dom->create;

eval { $dom->destroy };
$dom->undefine;

#$bvm->remove_disks;

$bvm->hvm->print_vm_list;
