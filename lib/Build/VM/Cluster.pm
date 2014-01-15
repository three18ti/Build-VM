package Build::VM::Cluster;
use 5.010;

use Carp;
use Moose;
use strict;
use warnings;
use Data::Validate::IP;
use List::Util qw(first);
use MooseX::HasDefaults::RO;

use Build::VM::Hypervisor;

use Data::Dump;
use Data::Dumper;

has 'hvm_address_list' => (
    isa         => 'ArrayRef',
    traits      => ['Array'],
    required    => 1,
    handles     => {
        'hvm_address_count' => 'count',
        'hvm_elements'  => 'elements',
    },
);

has 'rbd_pool'  => (
    isa         => 'Str',
    default     => 'libvirt-pool',
);

has 'rbd_hosts_list' => (
    isa         => 'ArrayRef[Str]',
    traits      => ['Array'],
#    required    => 1,
    handles     => {
        rbd_hosts => 'elements',
    },
);

has '_hvm_list' => (
    isa         => 'ArrayRef[Build::VM::Hypervisor]',
    lazy        => 1,
    traits      => ['Array'],
    builder     => '_build_hvm_list',
    handles     => {
        list_hvm    => 'elements',
        find_hvm    => 'first',
        count_hvm   => 'count',
    },
);

sub _build_hvm_list {
    my $self = shift;
    
    # I think there should be some sort of "resolve hostname" flag...

    my $hvm_list;
    # test if arrayref or single address, set the one 
    if ($self->hvm_address_count == 1) {
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
                    hostname    => $element->[0],
                    address     => $element->[1], 
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

sub select_hvm {
    my $self        = shift;

    my @search_hvm;
    if (ref $_[0] eq 'ARRAY' ) {
        my $hvm = shift @_;
        say Dumper $hvm;
        @search_hvm = @{$hvm};
        # wtf... this is the same thing but doesn't work
        # @search_hvm = @{$_[0]};
    }
    # untested
    elsif ( ref $_[0] eq 'HASH' ) {
        push @search_hvm, $_[0]->{hostname};
        push @search_hvm, $_[0]->{address};
    }
    else {
        @search_hvm = @_;
    }

    # Hopefully we'll find hvm, otherwise undef
    my $hvm;    
    # Actually, search first by ip.  For some reason I don't think that you'd just call 
    # $cluster->select_hvm( $hostname ); because...
    # accept:
    # my $hvm = $cluster->select_hvm( ip => '192.168.1.10');
    # my $hvm = $cluster->select_hvm( address => '192.168.1.10');
    # my $hvm = $cluster->select_hvm( '192.168.1.10');
    if ($search_hvm[0] =~ /(ip|address)/i or is_ipv4 $search_hvm[0]) {
        $hvm = $self->find_hvm(
            sub {
                my $search_address = @search_hvm == 1 ? $search_hvm[0] : $search_hvm[1];
                $_->address eq $search_address if $_->address;
            }
        );
    }
    # accept hostname and name, don't know why you'd want to use (HOST)*NAME but accept that too
    # suggest invoking:
    # my $hvm = $cluster->select_hvm( hostname => 'foobar');
    # ok, it's easy, support just hvm name:
    # my $hvm = $cluster->select_hvm( 'some_hostname' );
    elsif ($search_hvm[0] =~ /(host)*name/i or !is_ipv4 $search_hvm[0]) {
        $hvm = $self->find_hvm( 
            sub { 
                my $hvm_name = @search_hvm == 1 ? $search_hvm[0] : $search_hvm[1];
                $_->hostname eq $hvm_name if $_->hostname;
            }
        );
    }

#    elsif (
}

sub print_hvm_list {
    my $self = shift;
    
    foreach my $hvm ( $self->list_hvm ) {
#        if 
    }    

#    say sprintf "   ID:  | Name:                                     | State:    | Persistence:";
#    say sprintf "--------|-------------------------------------------|-----------|-------------";
#    foreach my $dom (@dom_list) {
#        say sprintf "  % 4s  | % -40s  | % -8s  | % -10s",
#            $dom->get_id == '-1' ? "off" : $dom->get_id,
#                $dom->get_name,
#                $dom->is_active ? "active" : "inactive",
#                $dom->is_persistent ? "persistent" : "ephemeral";
#    }


}

# Print vms on all the hypervisors
sub print_all_vm_list {
    my $self = shift;

    foreach my $hvm ( $self->list_hvm ) {
        my $hvm_id = $hvm->hostname ? $hvm->hostname : $hvm->address;
        say sprintf "HVM ID: | % -40s ", $hvm_id;
        $hvm->print_vm_list;
    }
}

sub find_dom {
    my $self        = shift;
    my $guest_name  = shift;

    my $hvm = first { 
        $_->get_dom($guest_name);
    } $self->list_hvm;

    $hvm->get_dom($guest_name);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

