package Build::VM;
# ABSTRACT: turns baubles into trinkets
use Moose;
use strict;
use warnings;

use Carp;
use Template;
use Sys::Virt;
use Sys::Guestfs;
use Ceph::RBD::CLI;
use Build::VM::Host;
use Build::VM::Guest;
use Build::VM::Hypervisor;
use MooseX::HasDefaults::RO;
use File::ShareDir 'dist_dir';
use List::MoreUtils qw( each_array );

has [qw ( base_image_name snap_name guest_name hvm_address) ]  => (
    isa         => 'Str',
    required    => 1
);

has [qw(guest_memory storage_disk_size)] => (
    isa         => 'Int',
    required    => 1,
);

has rbd_hosts => (
    isa         => 'ArrayRef[Str]',
    required    => 1,
);

has disk_names  => (
    isa     => 'ArrayRef[Str]',
    lazy    => 1,
    default => sub {
        [ $_[0]->guest_name . '-os', $_[0]->guest_name . '-storage' ],
    },
);

has disk_list   => (
    isa         => 'ArrayRef[ArrayRef]',
    lazy        => 1,
    default     => sub { $_[0]->build_disk_list($_[0]->disk_names); },
);

has guest       => (
    isa         => 'Build::VM::Guest',
    lazy        => 1,
    default     => sub {
        Build::VM::Guest->new(
            name    => $_[0]->guest_name,
            memory  => $_[0]->to_kib($_[0]->guest_memory),
            disk_list   => $_[0]->disk_list,
        );
    },
);

has host        => (
    isa         => 'Build::VM::Host',
    lazy        => 1,
    default     => sub {
        Build::VM::Host->new(
            rbd_hosts_list  => $_[0]->rbd_hosts,
        );
    },
);

has rbd         => (
    isa         => 'Ceph::RBD::CLI',
    lazy        => 1,
    default     => sub {
        Ceph::RBD::CLI->new(
            image_name  => $_[0]->base_image_name,
            snap_name   => $_[0]->snap_name,
        ),
    },
);

has hvm         => (
    isa         => 'Build::VM::Hypervisor',
    lazy        => 1,
    default     => sub {
        Build::VM::Hypervisor->(
            address => $_[0]->hvm_address
        );
    }
);

has template_xml => (
    isa     => 'Str',
    builder => 'build_template',
);

has template_name   => (
    isa     => 'Str',
    default => 'server-base.tt',
);

has INCLUDE_PATH    => (
    isa     => 'ArrayRef[Str]',
    default => sub { ['share', eval { dist_dir 'Build-VM' } ] }
);

sub build_template {
    my $self = shift;
    my $tt = Template->new({
        INCLUDE_PATH    => $self->INCLUDE_PATH, 
    })
    || carp "$Template::ERROR\n";
    my $xml = '';
    $tt->process(
        $self->template_name,
        {
            guest   => $self->guest,
            host    => $self->host,
        },
        \$xml,
    );
    return $xml;
}

# This can only handle 704 disks...
sub build_disk_list {
    my $self = shift;
    my $disk_names = shift;

    my @letters = 'a' .. 'zz';
    my @disk_letters = @letters[ 0 .. $#{$disk_names} ];

    my $disk_it = each_array @{$disk_names}, @disk_letters;
    my @disk_list;
    while ( my ( $disk_name, $disk_letter ) = $disk_it->() ){
        push @disk_list, [$disk_name->[0], "vd" . $disk_letter ];
    }
    return \@disk_list;   
}

sub to_kib {
    my $self = shift;
    my $mb = shift;

    return $mb * 1024;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

