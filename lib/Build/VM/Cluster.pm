package Build::VM::Cluster;
use 5.010;

use Carp;
use Moose;
use strict;
use warnings;
use Data::Validate::IP;
use MooseX::HasDefaults::RO;

use Build::VM::Hypervisor;

has 'hvm_address_list' => (
    traits      => ['Array'],
    isa         => 'ArrayRef',
    required    => 1,
    handles     => {
        'count_hvm'     => 'count',
        'hvm_elements'  => 'elements',
    },
);

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

has '_hvm_list' => (
    isa     => 'ArrayRef[Build::VM::Hypervisor]',
    lazy    => 1,
    builder => '_build_hvm_list',
);

sub _build_hvm_list {
    my $self = shift;
    
    # I think there should be some sort of "resolve hostname" flag...

    my $hvm_list;
    # test if arrayref or single address, set the one 
    if ($self->count_hvm == 1) {
        push @{$hvm_list}, Build::VM::Hypervisor->new ( 
            # This is dumb... already an arrayref
            #address =>  [$self->hvm_address->shift],
            address => $self->hvm_address_list->[0],
        );
    }
    # iterate through the list of hvms
    else {
        foreach my $element ($self->hvm_elements) {
            # if array should be ['hostname', 'address'] # could test for name/address...
            if ( ref $element eq 'ARRAY' ) {
                push @{$hvm_list}, Build::VM::Hypervisor->new ( 
                    hostname    => shift @{$element},
                    address     => shift @{$element},, 
                );
            }
            # hashref of elements, 
            elsif ( ref $element eq 'HASH' ) {
                push @{$hvm_list}, Build::VM::Hypervisor->new ( 
                    hostname    => $element->{hostname},
                    address     => $element->{address}, 
                );
                
            }
            # hopefully we've provided a list of ips... that's required
            else {
                croak "$element is not IP Address" unless is_ipv4 $element;
                push @{$hvm_list}, Build::VM::Hypervisor->new(
                    address     => $element,
                );
            }
        }
    }
    return $hvm_list;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

