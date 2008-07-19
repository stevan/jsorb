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

{
    package Foo;
    use Moose;
    
    has 'bar' => (
        is      => 'ro',
        isa     => 'Str',   
        default => sub { "BAR" },
    );
    
    has 'baz' => (
        is      => 'ro',
        isa     => 'Str',   
        default => sub { "BAZ" },
    );    
}

my $ns = JSORB::Namespace->new(
    name     => 'App',
    elements => [
        JSORB::Interface->new(
            name       => 'Foo',            
            procedures => [
                JSORB::Method->new(
                    name  => 'bar',
                    spec  => [ 'Unit' => 'Str' ],
                ),
                JSORB::Method->new(
                    name  => 'baz',
                    spec  => [ 'Unit' => 'Str' ],
                ),                                                              
            ]
        )            
    ]
);
isa_ok($ns, 'JSORB::Namespace');

my $d = JSORB::Dispatcher::Path->new_with_traits(
    traits    => [ 'JSORB::Dispatcher::Traits::WithInvocant' ],
    namespace => $ns,
    invocant  => Foo->new
);
isa_ok($d, 'JSORB::Dispatcher::Path');

my $s = JSORB::Server::Simple->new(dispatcher => $d);
isa_ok($s, 'JSORB::Server::Simple');

#$s->run;



