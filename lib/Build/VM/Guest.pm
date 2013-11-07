package Build::VM::Guest;
use Moose;
use strict;
use warnings;
use MooseX::HasDefaults::RO;

has 'name'      => (
    isa             => 'Str',
    required        => 1,

);

has 'memory'    => (
    isa             => 'Int',
    required        => 1,
);

has 'disk_list' => (
    isa             => 'ArrayRef[ArrayRef]',
    required        => 1,
    traits          => ['Array'],
    handles         => {
        disks       => 'elements',
        add_disk    => 'push'
    }
);

has 'cdrom_list'     => (
    isa             => 'ArrayRef[ArrayRef]',
    traits          => ['Array'],
    handles         => {
        cdroms      => 'elements',
        add_cdrom   => 'push',
    }
);

has 'current_memory'    => (
    isa             => 'Int',
    lazy            => 1,
    default         => sub { $_[0]->memory },

);

has 'arch'      => (
    isa             => 'Str',
    default         => 'x86_64',
);

has 'vcpu'      => (
    isa             => 'Int',
    default         => 2,    
);

has 'interface' => (
    isa             => 'Str',
    default         => 'bridge',
);

has 'bridge'    => (
    isa             => 'Str',
    default         => 'ovsbr0',
);

has 'virtualport_type' => (
    isa             => 'Str',
    default         => 'openvswitch',
);

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
