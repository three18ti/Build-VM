package Ceph::RBD::CLI;
use 5.010;
use Moose;
# ABSTRACT: turns baubles into trinkets
use strict;
use warnings;
use MooseX::HasDefaults::RO;

has 'pool_name' => (
	isa		=> 'Str',
	default	=> 'libvirt-pool',
);

has 'image_name'	=> (
	isa		=> 'Str',
);
has 'image_size'    => (
    isa     => 'Str',
);

has 'snap_name'	=> (
    isa     => 'Str',	
);

has 'format'        => (
    isa     => 'Int',
    default => 2,
);

has 'parent_name'   => (
    isa     => 'Str',
);

sub ls {
    my $self        = shift;
    my $pool        = shift // $self->pool_name;
    my @list = split/\n/, `rbd ls $pool`;
}

sub make_parent {
    my $self        = shift;
    my $snap_name   = shift // $self->snap_name;
    my $image_name  = shift // $self->image_name;
    my $pool        = shift // $self->pool_name;
    $self->snap_create($snap_name, $image_name, $pool);
    $self->snap_protect($snap_name, $image_name, $pool);    
}

sub image_create {
    my $self        = shift;
    my $image_name  = shift // $self->image_name;
    my $image_size  = shift // $self->image_size;
    my $pool        = shift // $self->pool_name;
    my $format      = shift // $self->format;
    `rbd create $pool/$image_name --size $image_size --image-format $format`
}

sub image_exists {
    my $self        = shift;
    my $image_name  = shift // $self->image_name;
    my $image_size  = shift // $self->image_size;
    my $pool        = shift // $self->pool_name;

    my @images = $self->ls($pool);
    return $image_name ~~ @images ? 1 : 0;
}

sub image_clone {
    my $self        = shift;
    my $new_image   = shift;
    my $snap_name   = shift // $self->snap_name;
    my $image_name  = shift // $self->image_name;
    my $pool        = shift // $self->pool_name;
    my $new_pool    = shift // $pool // $self->pool_name;
    `rbd clone $pool/$image_name\@$snap_name $new_pool/$new_image`
}

sub image_delete {
    my $self        = shift;
    my $image_name  = shift // $self->image_name;
    my $pool        = shift // $self->pool_name;
    `rbd rm $pool/$image_name`;
}

sub image_purge {
    my $self        = shift;
    my $image_name  = shift // $self->image_name;
    my $pool        = shift // $self->pool_name;
    $self->snap_purge($image_name, $pool);
    $self->image_delete($image_name, $pool);
}

sub snap_ls {
    my $self        = shift;
    my $snap_name   = shift // $self->snap_name;
    my $image_name  = shift // $self->image_name;
    my $pool        = shift // $self->pool_name;
    `rbd snap ls $pool/$image_name`;
}

sub snap_children {
    my $self        = shift;
    my $snap_name   = shift // $self->snap_name;
    my $image_name  = shift // $self->image_name;
    my $pool        = shift // $self->pool_name;
    `rbd snap children $pool/$image_name\@$snap_name`;
}

sub snap_create {
    my $self        = shift;
    my $snap_name   = shift // $self->snap_name;
    my $image_name  = shift // $self->image_name;
    my $pool        = shift // $self->pool_name;
    `rbd snap create $pool/$image_name\@$snap_name`;
}

sub snap_protect {
    my $self        = shift;
    my $snap_name   = shift // $self->snap_name;
    my $image_name  = shift // $self->image_name;
    my $pool        = shift // $self->pool_name;
    `rbd snap protect $pool/$image_name\@$snap_name`;
}

sub snap_unprotect {
    my $self        = shift;
    my $snap_name   = shift // $self->snap_name;
    my $image_name  = shift // $self->image_name;
    my $pool        = shift // $self->pool_name;
    `rbd snap unprotect $pool/$image_name\@$snap_name`;
}

sub snap_purge {
    my $self        = shift;
    my $image_name  = shift // $self->image_name;
    my $pool        = shift // $self->pool_name;
    `rbd snap purge $pool/$image_name`;
}

sub snap_delete {
    my $self        = shift;
    my $snap_name   = shift // $self->snap_name;
    my $image_name  = shift // $self->image_name;
    my $pool        = shift // $self->pool_name;
    `rbd snap rm $pool/$image_name\@$snap_name`;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
