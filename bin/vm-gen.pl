#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use lib 'lib';
use Build::VM;

use Getopt::Long::Descriptive;

my ($opt, $usage) = describe_options (
    'vm-gen.pl command %o',
);

my $base_image_name     = 'ubuntu-server-13.10-x86_64-base';
my $snap_name           = '2013-11-13';
my $guest_name          = 'build_vm_bin';
my $guest_memory        = 4096;
my $storage_disk_size   = 20;
my $rbd_hosts           = [qw(192.168.0.35 192.168.0.2 192.168.0.40)];
my $hvm_address         = '192.198.0.35';

my $bvm = Build::VM->new(
    base_image_name     => $base_image_name,
    snap_name           => $snap_name,
    guest_name          => $guest_name,
    guest_memory        => $guest_memory,
    storage_disk_size   => $storage_disk_size,
    rbd_hosts           => $rbd_hosts,
    hvm_address         => $hvm_address,
);

my $commands = {
    new     => \&new_vm,
    list    => \&list_vm
};

my $command = shift @ARGV;

$commands->{$command}->($bvm);

sub new_vm {
    my $bvm = shift;
    say "new vm called";
}

sub list_vm {
    my $bvm = shift;
    $bvm->hvm->vm_list;
}
