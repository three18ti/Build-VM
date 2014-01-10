#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Test::More;
use Test::Output;

use lib 'lib';

BEGIN { use_ok 'Build::VM::Cluster'};

use Data::Dump;

my $clusters;
push @{$clusters}, Build::VM::Cluster->new(
    hvm_address_list    => [ qw(192.168.15.35) ],
    rbd_hosts_list      => [ qw(192.168.15.35 192.168.15.2 192.168.15.40) ],
);

push @{$clusters}, Build::VM::Cluster->new(
    rbd_hosts_list      => [ qw(192.168.15.35 192.168.15.2 192.168.15.40) ],
    hvm_address_list    => [
        '192.168.15.40',
        [qw(kitt 192.168.15.35)],
        { 
            hostname    => 'shepard',
            address     => '192.168.15.2',
        },
    ],
);

map { $_->_hvm_list } @$clusters;

dd $clusters;


done_testing;

