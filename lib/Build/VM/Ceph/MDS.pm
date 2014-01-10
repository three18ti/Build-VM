package Build::VM::Ceph::MDS;
use Moose;
use strict;
use warnings;
use MooseX::HasDefaults::RO;

# I don't actually know what the mds requires... so... yah...
# But I hope to be able to support it...

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

