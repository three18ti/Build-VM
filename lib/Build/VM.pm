package Build::VM;
# ABSTRACT: turns baubles into trinkets
use Moose;
use strict;
use warnings;

use Sys::Virt;

use Sys::Guestfs;




sub to_kib {
    my $self = shift;
    my $mb = shift;

    return $mb * 1024;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

