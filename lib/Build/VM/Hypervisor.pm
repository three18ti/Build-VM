package Build::VM::Hypervisor;
use 5.010;
use Moose;
use strict;
use warnings;
use Sys::Virt;
use List::Util qw(first);
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

sub get_dom {
    my $self = shift;
    my $guest_name = shift;
    my $vm_list = $self->vm_list;

    first { $_->get_name eq $guest_name } @$vm_list;
}

sub guest_exists {
    my $self = shift;
    my $guest_name = shift;

    my @dom_list = $self->vmm->list_all_domains;
    my $matches = grep { $_->get_name eq $guest_name } @dom_list;
}

sub vm_list {
    my $self = shift;
    my @dom_list = $self->vmm->list_all_domains;
    return \@dom_list;
}

sub print_vm_list {
    my $self = shift;

    my @dom_list = $self->vmm->list_all_domains;
    @dom_list = sort { $b->get_id <=> $a->get_id } @dom_list;
    
    say sprintf " VM ID: | Name:                                     | State:    | Persistence:";
    say sprintf "--------|-------------------------------------------|-----------|-------------";
    foreach my $dom (@dom_list) {
        say sprintf "  % 4s  | % -40s  | % -8s  | % -10s", 
            $dom->get_id == '-1' ? "off" : $dom->get_id, 
                $dom->get_name, 
                $dom->is_active ? "active" : "inactive", 
                $dom->is_persistent ? "persistent" : "ephemeral";
    }
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
