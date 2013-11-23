package Build::VM::Hypervisor;
use 5.010;
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

sub print_vm_list {
    my $self = shift;

    my @dom_list = $self->vmm->list_all_domains;
    say sprintf "   ID:  | Name:                                     | State:    | Persistence:";
    say sprintf "--------|-------------------------------------------|-----------|-------------";
    foreach my $dom (@dom_list) {
        say sprintf "  % 4s  | % -40s  | % -8s  | % -10s", 
            $dom->get_id, $dom->get_name, 
                $dom->is_active ? "active" : "inactive", 
                $dom->is_persistent ? "persistent" : "ephemeral";
    }
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
