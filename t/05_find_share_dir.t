#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Test::More;
use File::ShareDir 'dist_dir';

use lib 'lib';

BEGIN { use_ok 'Build::VM' }

like dist_dir ('Build-VM'), qr/blib\/lib\/auto\/share\/dist\/Build-VM/,
    "Found Dist Dir";


done_testing;
__END__
