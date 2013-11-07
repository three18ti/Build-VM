#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Sys::Virt;
use File::ShareDir qw(dist_dir);

use Template;
use Getopt::Long::Descriptive;

use lib 'lib';
use Build::VM::Host;
use Build::VM::Guest;

my $guest_name = 'foo-test';
my $disk_list = [[$guest_name . 1, 'hda'], [$guest_name . 2, 'hdb']];
my $memory_mb = '2048';
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
$guest->add_cdrom(['/media/ubuntu-13.10-server-amd64.iso', 'hdc']);

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
    \$guest_xml,
);
#    $guest_config_name,

my $vmm = Sys::Virt->new( uri => $host_uri );

my $dom = $vmm->create_domain($guest_xml);
