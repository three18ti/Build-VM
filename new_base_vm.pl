#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;


use lib 'lib';
use Build::VM;

my $hvm_address = '192.168.0.35';

my $bvm = Build::VM->new(
    base_image_name   => 'test_base-base',
    snap_name         => '2013-11-25',
    guest_name        => 'test_base_clone',
    guest_memory      => 4096,
    storage_disk_size => 20,
    rbd_hosts         => [qw(192.168.0.35 192.168.0.2 192.168.0.40)],
    hvm_address       => $hvm_address,
    cdrom_list        => [[ '/media/ubuntu-13.10-server-amd64.iso', 'vdb'],],
    disk_names        => [['test_base-base', 5]],
    template_name     => 'server-base.tt',
);
$bvm->hvm->vm_list;
my $command = shift @ARGV;

my $commands = {
    new_base => \&new_base,
    list    => \&list_vm,
    destroy => \&destroy,
};
$commands->{$command}->($bvm);


sub new_base {
    my $dom;
    unless ($bvm->hvm->guest_exists($bvm->guest_name)) {
        $bvm->build_disks;
        my $dom = $bvm->deploy_ephemeral;
    }
    else {
        say "Vm exists";
    }
    $bvm->hvm->print_vm_list;
}


sub destroy { 
    my $dom = $bvm->hvm->get_dom($bvm->guest_name);
    eval { $dom->destroy };
    eval { $dom->undefine };
    $bvm->remove_disks;
}
