#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Sys::Virt;
use File::ShareDir qw(dist_dir);

use Template;
use Getopt::Long::Descriptive;

use Ceph::RBD::CLI;

use lib 'lib';
use Build::VM::Host;
use Build::VM::Guest;

#my $base_image = 'libvirt-pool/ubuntu-server-13.10-x86_64-base@2013-11-13';
my $base_image_name = 'ubuntu-server-13.10-x86_64-base';
my $snapshot_name = '2013-11-13';
my $rbd = Ceph::RBD::CLI->new(
    image_name  => $base_image_name,
    snap_name   => $snapshot_name,
);

my $guest_name = 'ubuntu-server-13.10-buildvm-test';
my $disk1_name = $guest_name . 'os';
my $disk2_name = $guest_name . 'storage';
$rbd->image_clone($disk1_name);
$rbd->image_create($disk2_name, 20 * 1024);

my $disk_list = [[$disk1_name, 'vda'], [$disk2_name, 'vdb']];
#my $disk_list = [[$guest_name,, 'hda']];

# 
my $memory_mb = '4096';
my $rbd_host_list = [qw(192.168.0.2 192.168.0.35 192.168.0.40)];
my $guest_config_name = $guest_name . '.tmpl';
my $guest_xml = '';

# virsh -c qemu+ssh://192.168.0.35/session list
my $host_uri = 'qemu+ssh://192.168.0.35/session?socket=/var/run/libvirt/libvirt-sock';

my $guest = Build::VM::Guest->new(
                    name    => $guest_name,
                    memory  => $memory_mb * 1024,
                    disk_list   => $disk_list,
);
#$guest->add_cdrom(['/media/ubuntu-13.10-server-amd64.iso', 'hdc']);

my $host  =  Build::VM::Host->new(
    rbd_hosts_list   => $rbd_host_list,
);

my $tt = Template->new({

}) || die "$Template::ERROR\n";

$tt->process(
    'server-base.tt',
    {
        guest   => $guest,
        host  => $host,
    },
    #$guest_config_name,
    \$guest_xml,
);

my $vmm = Sys::Virt->new( uri => $host_uri );

my $dom = $vmm->create_domain($guest_xml);
