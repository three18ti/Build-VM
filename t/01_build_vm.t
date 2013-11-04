#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Test::More;

use lib 'lib';

BEGIN { use_ok 'Build::VM' }

use Template;


my $tt = Template->new({

}) || die "$Template::ERROR\n";

my $output = '';
use Build::VM::Guest;
use Build::VM::System;
$tt->process(
    'server-base.tt',    
    {
        guest   =>  Build::VM::Guest->new(
                    name    => 'foo-test',
                    memory  => 2048 * 1024,
                    disk_list   => [qw(foo-test1 foo-test2)],
                    cdrom       => '/media/ubuntu-13.10-server-amd64.iso',
                ),
        system  =>  Build::VM::System->new(
                    rbd_hosts_list   => [qw(192.168.0.2 192.168.0.35 192.168.0.40)],
                ),
    },
    'server-base.out'
);

done_testing;
