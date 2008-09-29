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
    use MooseX::AttributeHelpers;

    has ['first_name', 'last_name'] => (is => 'rw', isa => 'Str');
    has 'age'      => (is => 'rw', isa => 'Int');
    has 'spouse'   => (is => 'rw', isa => 'Person');
    
    has ['mother', 'father'] => (
        is        => 'ro', 
        isa       => 'Person', 
        weak_ref  => 1, 
        trigger   => sub {
            my ($self, $parent) = @_;
            $parent->add_child($self);
        }
    );
    
    has 'children' => (
        metaclass => 'Collection::Array',
        is        => 'rw', 
        isa       => 'ArrayRef[Person]',
        default   => sub { [] },
        provides  => {
            'push' => 'add_child'
        }
    );

    has 'car' => (is => 'rw', isa => 'Car');
    
    package Car;
    use Moose;
    
    has 'owner' => (
        is       => 'rw', 
        isa      => 'Person', 
        weak_ref => 1,
        trigger  => sub {
            my ($self, $owner) = @_;
            $owner->car($self);
        }
    );    
    
    has [ 'make', 'model', 'vin' ] => (is => 'rw');
}

my $db = KiokuDB->connect("bdb:dir=data", create => 1);

my $s = $db->new_scope;

my $me = Person->new(first_name => 'Stevan', last_name => 'Little', age => 35);
my $lu = Person->new(first_name => 'Lucinda', last_name => 'Juliani', age => 32, spouse => $me);
$me->spouse($lu);

my $minivan = Car->new(make => 'Toyota', model => 'Sienna', vin => '12345abcdefghijklmno', owner => $lu);
my $volvo   = Car->new(make => 'Volvo', model => 'Sedan', vin => '12345abcdefghijklmno', owner => $me);

my %parents = (father => $me, mother => $lu);

my @children = (
    Person->new(first_name => 'Xoe',       last_name => 'Juliani', age => 11, %parents),
    Person->new(first_name => 'Annabelle', last_name => 'Juliani', age => 6,  %parents),
    Person->new(first_name => 'Benjamin',  last_name => 'Juliani', age => 6,  %parents),        
);

my ($me_id) = $db->txn_do(sub {
    $db->store( $me );
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
