#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use Scalar::Util 'blessed', 'refaddr';

use lib "$FindBin::Bin/../../lib";

use JSORB;
use JSORB::Dispatcher::Path;
use JSORB::Server::Simple;
use JSORB::Server::Traits::WithStaticFiles;

use KiokuDB;
use KiokuDB::Backend::Serialize::JSPON::Collapser;

{
    package Person;
    use Moose;
    
    has ['first_name', 'last_name'] => (is => 'rw', isa => 'Str');
    has 'age'    => (is => 'rw', isa => 'Int');
    has 'spouse' => (is => 'rw', isa => 'Person');
}

my $db = KiokuDB->connect("bdb:dir=data");

my $s = $db->new_scope;

my $me = Person->new(
    first_name => 'Stevan',
    last_name  => 'Little',
    age        => 35,
);

my $lu = Person->new(
    first_name => 'Lucinda',
    last_name  => 'Juliani',
    age        => 32,        
    spouse     => $me,
);

$me->spouse($lu);

my ($me_id) = $db->txn_do(sub {
    $db->store( $me, $lu );
});    

sub collapse_object {
    my $object = shift;
    my $collapser = KiokuDB::Backend::Serialize::JSPON::Collapser->new;
    return $collapser->collapse_jspon($db->live_objects->object_to_entry($object));
}

my $ns = JSORB::Namespace->new(
    name     => 'KiokuDB',
    elements => [
        JSORB::Interface->new(
            name       => 'Navigator',
            procedures => [
                JSORB::Procedure->new(
                    name  => 'lookup',
                    body  => sub {  
                        my $id  = shift || $me_id;
                        my $obj = $db->lookup($id);
                        collapse_object($obj);
                    },
                    spec  => [ 'Str' => 'HashRef' ]
                )
            ]
        )
    ]
);

JSORB::Server::Simple->new_with_traits(
    traits     => [
        'JSORB::Server::Traits::WithDebug',
        'JSORB::Server::Traits::WithStaticFiles',
    ],
    doc_root   => [ $FindBin::Bin, '..', '..' ],
    dispatcher => JSORB::Dispatcher::Path->new(
        namespace => $ns,
    )
)->run;

1;
