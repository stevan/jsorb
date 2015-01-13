#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 18;
use Test::Exception;
use Test::WWW::Mechanize;

use JSON qw/ from_json /;

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

my $pid = $s->background;

my $mech = Test::WWW::Mechanize->new;

sub Test::WWW::Mechanize::method_call_is {
    my ( $mech, $method, $params, $result ) = @_;

    subtest "$method($params)" => sub {
        my $uri = "http://localhost:9999/?method=/math/simple/$method&params=[$params]";
        $mech->get_ok( $uri );

        my $expected = {};
        $expected->{jsonrpc} = '2.0';
        $expected->{result} = $result;

        is_deeply( from_json( $mech->content ) => $expected, 'expected results' );
    }
}

$mech->method_call_is( 'add', '2,2', 4 );
$mech->method_call_is( 'sub', '4,2', 2 );
$mech->method_call_is( 'mul', '2,2', 4 );
$mech->method_call_is( 'div', '10,2', 5 );

ok($mech->get('http://localhost:9999/?method=/math/simple/div&params=[2,0]'), '... the content with an error');
is($mech->status, 500, '... got the HTTP error we expected');
$mech->content_contains('"error":', '... got the content we expected');
$mech->content_contains('"Illegal division by zero', '... got the content we expected');

ok($mech->get('http://localhost:9999/?method=/math/simple/add&params=[2]'), '... the content with an error');
is($mech->status, 500, '... got the HTTP error we expected');
$mech->content_contains('"error":', '... got the content we expected');
$mech->content_contains('"Bad number of arguments', '... got the content we expected');

END {
    kill TERM => $pid;
}

