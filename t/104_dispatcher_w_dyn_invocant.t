#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;
use Test::Exception;

use JSON::RPC::Common::Procedure::Call;

BEGIN {
    use_ok('JSORB');
    use_ok('JSORB::Dispatcher::Path');
}

{
    package App::Foo;
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
    traits    => [ 'JSORB::Dispatcher::Traits::WithDynamicInvocant' ],
    namespace => $ns,
    invocant  => App::Foo->new
);
isa_ok($d, 'JSORB::Dispatcher::Path');

{
    my $call = JSON::RPC::Common::Procedure::Call->new(
        method => "/app/foo/bar",
        params => [],
    );
    
    my $res = $d->handler($call);
    isa_ok($res, 'JSON::RPC::Common::Procedure::Return');

    ok($res->has_result, '... we have a result, not an error');
    ok(!$res->has_error, '... we have a result, not an error');

    is($res->result, 'BAR', '... got the result we expected');
}

{
    my $call = JSON::RPC::Common::Procedure::Call->new(
        method => "/app/foo/baz",
        params => [],
    );
    
    my $res = $d->handler($call);
    isa_ok($res, 'JSON::RPC::Common::Procedure::Return');

    ok($res->has_result, '... we have a result, not an error');
    ok(!$res->has_error, '... we have a result, not an error');

    is($res->result, 'BAZ', '... got the result we expected');
}

# ... change the invocant

lives_ok {
    $d->invocant(
        App::Foo->new(
            bar => 'This is a Bar.', 
            baz => 'This is a Baz.'
        )
    );
} '... changed the invocant okay';

{
    my $call = JSON::RPC::Common::Procedure::Call->new(
        method => "/app/foo/bar",
        params => [],
    );
    
    my $res = $d->handler($call);
    isa_ok($res, 'JSON::RPC::Common::Procedure::Return');

    ok($res->has_result, '... we have a result, not an error');
    ok(!$res->has_error, '... we have a result, not an error');

    is($res->result, 'This is a Bar.', '... got the result we expected');
}

{
    my $call = JSON::RPC::Common::Procedure::Call->new(
        method => "/app/foo/baz",
        params => [],
    );
    
    my $res = $d->handler($call);
    isa_ok($res, 'JSON::RPC::Common::Procedure::Return');

    ok($res->has_result, '... we have a result, not an error');
    ok(!$res->has_error, '... we have a result, not an error');

    is($res->result, 'This is a Baz.', '... got the result we expected');
}

lives_ok {
    $d->clear_invocant;
} '... cleared the invocant okay';

ok(!$d->invocant, '... we no longer have an invocant');
    
{
    my $call = JSON::RPC::Common::Procedure::Call->new(
        method => "/app/foo/baz",
        params => [],
    );
    
    my $res = $d->handler($call);
    isa_ok($res, 'JSON::RPC::Common::Procedure::Return');

    ok(!$res->has_result, '... we have a result, not an error');
    ok($res->has_error, '... we have a result, not an error');

    like($res->error->message, qr/You must supply an invocant for this call/, '... got the error we expected');
}


