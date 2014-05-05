#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Config::Any;
use lib 'lib';
use Build::VM;

use Getopt::Long::Descriptive;

my ($opt, $usage) = describe_options (
    'vm-gen.pl command %o',
);
my $command = shift @ARGV;

my $vm_config       = shift @ARGV || 'etc/new_vm.yml';
my $default_config  = 'etc/build_vm.yml';

my $default         = Config::Any->load_files({ files => [$default_config], use_ext => 1})->[0]->{$default_config};
my $vm              = Config::Any->load_files({ files => [$vm_config],  use_ext => 1 })->[0]->{$vm_config};

my $bvm = Build::VM->new( { %$default, %$vm });

# What's the difference between new and deploy?
my $commands = {
    new         => \&new_vm,
    start       => \&start_vm,
    list        => \&list_vm,
    list_all    => \&print_all_vm_list,
    destroy     => \&destroy,
    protect     => \&protect,
    deploy      => \&deploy,
    dumpxml     => \&dump_xml,
    migrate     => \&migrate,
};

$commands->{$command}->($bvm);

sub new_vm {
    my $bvm = shift;
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

sub start_vm {
    my $bvm = shift;
    my $dom;
    unless ($bvm->hvm->guest_exists($bvm->guest_name)) {
        my $dom = $bvm->deploy_ephemeral;
    }
    else {
        say "Vm exists";
    }
    $bvm->hvm->print_vm_list;
}

sub deploy {
    my $bvm = shift;
    my $dom;
    unless ($bvm->hvm->guest_exists($bvm->guest_name)) {
        $bvm->build_disks;
        my $dom = $bvm->deploy_vm;
    }
    else {
        say "Vm exists";
    }

}

sub protect {
    my $bvm = shift;
#    unless ($bvm->hvm->guest_exists($bvm->guest_name)) {
#        say "Vm Doesn't exist";
#    }
#    else {
        my $dom = $bvm->hvm->get_dom($bvm->guest_name);
#        eval { $dom->destroy };
#        eval { $dom->undefine };
        $bvm->rbd->snap_create;
        $bvm->rbd->snap_protect;
#    }
}

sub list_vm {
    my $bvm = shift;
    $bvm->hvm->print_vm_list;
}

sub print_all_vm_list {
    my $bvm = shift;
    $bvm->print_all_vm_list;
}

sub destroy {
    my $bvm = shift;
    my $dom = $bvm->hvm->get_dom($bvm->guest_name);
    eval { $dom->destroy };
    eval { $dom->undefine };
    $bvm->remove_disks;
}

sub dump_xml {
    my $bvm = shift;
    say $bvm->guest_xml;
}

#sub migrate {
#    my $bvm     = shift;
#    $bvm->select_hvm('192.168.15.35')->print_vm_list;
#    $bvm->migrate_dom($bvm->guest_name, [address => '192.168.15.35']);
#    $bvm->select_hvm('192.168.15.35')->print_vm_list;
#    $bvm->select_hvm('192.168.15.40')->print_vm_list;
#}
sub migrate {
    my $bvm     = shift;
    $bvm->select_hvm('192.168.15.35')->print_vm_list;
    $bvm->migrate_dom($bvm->guest_name, [address => '192.168.15.2']);
    $bvm->select_hvm('192.168.15.2')->print_vm_list;
    $bvm->select_hvm('192.168.15.35')->print_vm_list;
}
#sub migrate {
#    my $bvm     = shift;
#    $bvm->select_hvm('192.168.15.35')->print_vm_list;
#    $bvm->migrate_dom($bvm->guest_name, [address => '192.168.15.2']);
#    $bvm->select_hvm('192.168.15.35')->print_vm_list;
#    $bvm->select_hvm('192.168.15.2')->print_vm_list;
#}
