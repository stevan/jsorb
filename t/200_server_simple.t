#!/usr/bin/perl

use strict;
use warnings;

use lib '/Users/stevan/Desktop/JSON-RPC-Common/lib';

use Test::More no_plan => 1;
use Test::Exception;

BEGIN {
    use_ok('JSORB');
    use_ok('JSORB::Dispatcher::Path');
    use_ok('JSORB::Server::Simple');
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

my $d = JSORB::Dispatcher::Path->new(namespace => $ns);
isa_ok($d, 'JSORB::Dispatcher::Path');

my $s = JSORB::Server::Simple->new(dispatcher => $d);
isa_ok($s, 'JSORB::Server::Simple');

#$s->run;



