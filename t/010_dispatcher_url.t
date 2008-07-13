#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;
use Test::Exception;

use lib '/Users/stevan/Projects/CPAN/current/Path-Router/Path-Router/lib';

BEGIN {
    use_ok('JSORB');
    use_ok('JSORB::Dispatcher::URL');
}

sub add { $_[0] + $_[1] }
sub sub { $_[0] - $_[1] }
sub mul { $_[0] * $_[1] }
sub div { $_[0] / $_[1] }

my $ns = JSORB::Namespace->new(
    name     => 'Math',
    elements => [
        JSORB::Interface->new(
            name       => 'Simple',            
            procedures => [
                JSORB::Procedure->new(
                    name  => 'add',
                    body  => \&add,
                    spec  => [ 'Int' => 'Int' => 'Int' ],
                ),
                JSORB::Procedure->new(
                    name  => 'sub',
                    body  => \&sub,
                    spec  => [ 'Int' => 'Int' => 'Int' ],
                ),
                JSORB::Procedure->new(
                    name  => 'mul',
                    body  => \&mul,
                    spec  => [ 'Int' => 'Int' => 'Int' ],
                ),
                JSORB::Procedure->new(
                    name  => 'div',
                    body  => \&div,
                    spec  => [ 'Int' => 'Int' => 'Int' ],
                ),                                               
            ]
        )            
    ]
);
isa_ok($ns, 'JSORB::Namespace');

my $d = JSORB::Dispatcher::URL->new(namespace => $ns);
isa_ok($d, 'JSORB::Dispatcher::URL');

is($d->namespace, $ns, '... got the same namespace');

is(
    $ns->get_element_by_name('Simple')->get_procedure_by_name($_),
    $d->router->match('/math/simple/' . $_)->target,
    '... got the right target (' . $_ . ')'
) foreach qw[ add sub mul div ];




