package Build::VM::Host;
use Moose;
use strict;
use warnings;
use MooseX::HasDefaults::RO;

has 'rbd_pool'  => (
    isa     => 'Str',
    default => 'libvirt-pool',
);

has 'rbd_hosts_list' => (
    isa     => 'ArrayRef[Str]',
    required => 1,
    traits => ['Array'],
    handles => {
        rbd_hosts => 'elements',
    },
);

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

