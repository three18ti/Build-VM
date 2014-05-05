package Build::VM;
# ABSTRACT: turns baubles into trinkets
use 5.010;
use Moose;
use strict;
use warnings;

use Carp;
use Template;
use Sys::Virt;
#use Sys::Guestfs;
use Ceph::RBD::CLI;
use Build::VM::Host;
use Build::VM::Guest;
use Build::VM::Cluster;
#use Build::VM::Hypervisor;
use MooseX::HasDefaults::RO;
use File::ShareDir 'dist_dir';
use List::MoreUtils qw( each_array );

has [qw ( base_image_name snap_name guest_name ) ]  => (
    isa         => 'Str',
    required    => 1,
);

has hvm_target  => (
    required    => 1,
);

has hvm_address_list    => (
    isa         => 'ArrayRef',
    required    =>  1,
);

has [qw(guest_memory storage_disk_size)] => (
    isa         => 'Int',
    required    => 1,
);

has 'cdrom_list'     => (
    isa             => 'ArrayRef[ArrayRef]',
    traits          => ['Array'],
    handles         => {
        cdroms      => 'elements',
        add_cdrom   => 'push',
    }
);

has rbd_hosts => (
    isa         => 'ArrayRef[Str]',
    required    => 1,
);

has rbd_pool  => (
    isa         => 'Str',
    default     => 'libvirt-pool',
);

has disk_names  => (
    isa     => 'ArrayRef[ArrayRef]',
    lazy    => 1,
    default => sub {
        [ 
            [$_[0]->guest_name . '-os', undef ],
            [$_[0]->guest_name . '-storage', '20'],
        ],
    },
);

has disk_list   => (
    isa         => 'ArrayRef[ArrayRef]',
    lazy        => 1,
    default     => sub { $_[0]->build_disk_list($_[0]->disk_names); },
);

has [qw(guest_vcpu guest_current_memory guest_num_interfaces)]    => (
    isa         => 'Int',
    required    => 0,
);

has [qw(guest_arch guest_interface guest_bridge guest_virtualport_type)]    => (
    isa         => 'Str',
    required    => 0,
);

has guest       => (
    isa         => 'Build::VM::Guest',
    lazy        => 1,
    default     => sub {
        my %opt_params;
        my $attributes = [qw(
            vcpu arch current_memory num_interfaces
            interface bridge virtualport_type 
        )];

        foreach my $attribute (@$attributes) {
            my $method_name = "guest_" . $attribute;
            $opt_params{$attribute} = $_[0]->$method_name if $_[0]->$method_name;
            # Probably a better way to set current memory...
#            $opt_params{$attribute} = $_[0]->to_kib($_[0]->$method_name) if $method_name eq 'guest_current_memory';
        }

#        $opt_params->{} = $_[0]->guest_vcpu if $_[0]->guest_vcpu;
        
        Build::VM::Guest->new(
            name    => $_[0]->guest_name,
            memory  => $_[0]->to_kib($_[0]->guest_memory),
            disk_list   => $_[0]->disk_list,
            cdrom_list  => $_[0]->cdrom_list || [[]],
            %opt_params,
        );
    },
);

has host        => (
    isa         => 'Build::VM::Host',
    lazy        => 1,
    default     => sub {
        Build::VM::Host->new(
            rbd_hosts_list  => $_[0]->rbd_hosts,
            rbd_pool        => $_[0]->rbd_pool,
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

has hvm_cluster => (
    isa         => 'Build::VM::Cluster',
    lazy        => 1,
    default     => sub {
        Build::VM::Cluster->new(
            hvm_address_list    => $_[0]->hvm_address_list,
            rbd_hosts_list      => $_[0]->rbd_hosts,
        );
    },
    handles     => {
        print_all_vm_list   => 'print_all_vm_list',
        guest_exists        => 'guest_exists',
        migrate_dom         => 'migrate_dom',
        select_hvm          => 'select_hvm',
        count_hvm           => 'count_hvm',
        find_dom            => 'find_dom',
    }
    
);

has hvm         => (
    isa         => 'Build::VM::Hypervisor',
    lazy        => 1,
    default     => sub {
        $_[0]->select_hvm($_[0]->hvm_target)
    },
    handles     => {
        get_dom     => 'get_dom',
    }
);

has guest_xml => (
    isa     => 'Str',
    lazy    => 1,
    builder => 'build_template',
);

has template_name   => (
    isa     => 'Str',
    default => 'server-base.tt',
);

has INCLUDE_PATH    => (
    isa     => 'ArrayRef[Str]',
    lazy    => 1,
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
    ) || carp $tt->error;
    return $xml;
}

sub build_disk_list {
    my $self = shift;
    my $disk_names = shift;

    my @disk_list;
    my $disk_letter = 'a';
    
    foreach my $disk_name ( @{$disk_names} ){
        my $device_name = "vd" . $disk_letter++;
        push @disk_list, [$disk_name->[0], $device_name ];
    }
    return \@disk_list;   
}

sub build_disks {
    my $self = shift;
    foreach my $disk ( @{$self->disk_names} ) {
        unless ( defined $disk->[1] ) {
            $self->rbd->image_clone($disk->[0]);
        }
        else {
            $self->rbd->image_create($disk->[0], $disk->[1] * 1024);
        }
    }
}

sub define_vm {
    my $self = shift;
    my $dom = $self->hvm->vmm->define_domain($self->guest_xml);
}

sub deploy_vm {
    my $self = shift;
    my $dom = $self->define_vm;
    $dom->create;
}

sub deploy_ephemeral {
    my $self = shift;
    my $dom = $self->hvm->vmm->create_domain($self->guest_xml);
}

sub remove_disks {
    my $self = shift;
    $self->rbd->image_delete($_->[0]) foreach @{$self->disk_names};
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

