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

sub vm_list {
    my $self = shift;

    my @dom_list = $self->vmm->list_domains;
    use Data::Dump;
    print dd @dom_list;
#    foreach my $dom (@dom_list) {
#        print "Domain ", $dom->get_id, " ", $dom->get_name, "\n";
#    }
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
