#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use Config::Any;

use lib 'lib';
use Build::VM;

my $default_config  = 'etc/build_vm.yml';
my $vm_config       = 'etc/new_vm.yml';

my $defualt         = Config::Any->load_files({ files => [$default_config], use_ext => 1})->[0]->{$default_config};
my $vm              = Config::Any->load_files({ files => [$vm_config],  use_ext => 1 })->[0]->{$vm_config};

my $bvm = Build::VM->new( {%$defualt, %$vm} );


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

new_base;
