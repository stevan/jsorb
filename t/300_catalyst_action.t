#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More no_plan => 1;
use Catalyst::Test 'TestApp';

{
    my $request = HTTP::Request->new( 
        GET => 'http://localhost:3000/rpc?method=/test/app/greeting&params=[]' 
    );

    ok(my $response = request($request), '... got a response from the request');
    ok($response->is_success, '... response is successful');
    is($response->header( 'Content-Type' ), 'application/json-rpc', '... got the JSON content-type');    
    is($response->code, 200, '.. response code is 200');
       
    is($response->content, '{"jsonrpc":"2.0","result":"Hello World"}', '... got the content we expected');
}

