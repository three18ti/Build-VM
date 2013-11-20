package Build::VM::Hypervisor;
use Moose;
use strict;
use warnings;
use MooseX::HasDefaults::RO;

has 'hostname'  => (
    isa     => 'Str',
);

has 'address'   => (
    isa         => 'Str',
    required    => 1,
);

has 'uri'       => (
    isa         => 'Str',
    lazy        => 1,
    default     => sub { 
        'qemu+ssh://' . $_[0]->address . '/session?socket=/var/run/libvirt/libvirt-sock';
    },
);

has vmm         => (
    isa         => 'Sys::Virt',
    lazy        => 1,
    default     => sub {
        Sys::Virt->new(
            uri => $_[0]->uri,
        );
    },
);


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__