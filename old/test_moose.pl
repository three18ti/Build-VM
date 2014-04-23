
package My::App;
use 5.010;
use Moose;
use strict;
use warnings;
use MooseX::HasDefaults::RO;

has [qw( foo bar )]         => ( 
    isa         => 'Int',
    required    => 1,
);

has [qw( biz baz )]         => (
    isa         => 'Int',
    default     => '1',
);

package My;
use 5.010;
use Moose;
use strict;
use warnings;
use MooseX::HasDefaults::RO;

has [qw(app_foo app_bar)]   => (
    isa         => 'Int',
    required    => 1,
);

has [qw(app_biz app_baz)]   => (
    isa         => 'Int',
    required    => 0,
);

has 'MyApp' => (
    lazy        => 1,
    isa         => 'My::App',
    default     => sub {
        my $attrs   = [qw(
            biz baz
        )];
        
        my %opt_params;
        foreach my $attribute (@$attrs) {
            my $method_name = 'app_' . $attribute;
            $opt_params{$attribute} = $_[0]->$method_name if $_[0]->$method_name;
        }

        My::App->new(
            foo => $_[0]->app_foo,
            bar => $_[0]->app_bar,
            %opt_params,
        );

    },
    handles => qr/^(.*)/,
);

package main;
use 5.010;
use strict;
use warnings;
use Test::More;

#BEGIN { use_ok 'My' }

my $app = new_ok 'My' => [ 
        app_foo => 1,
        app_bar => 2,
        app_biz => 3,
];

foreach my $test (qw( foo bar biz baz app_foo app_bar app_biz app_baz )){
    is $app->$test, $app->$test, '$app' . "->" . $test;
}

is $app->foo, 1, "foo ok";
is $app->app_foo, 1, "app_foo ok";

# Not sure what I was going for here... it started out as the following but that didn't work
# is $app->$test, $count++ %4 ? $app->$test : undef , '$app' . "->" . $test
my $count = 0;
foreach my $test (qw( foo bar biz baz app_foo app_bar app_biz app_baz )){
    is $app->$test, $count++ %4 ? $app->$test : $app->$test , '$app' . "->" . $test;
}

done_testing;
