#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;
use Test::Exception;

BEGIN {
    use_ok('JSORB');
}

sub add { $_[0] + $_[1] }

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
                )
            ]
        )            
    ]
);
isa_ok($ns, 'JSORB::Namespace');
isa_ok($ns, 'JSORB::Core::Element');

is($ns->name, 'Math', '... got there right name');
is($ns->fully_qualified_perl_name, 'Math', '... got the right fully qualified Perl name');
is($ns->fully_qualified_javascript_name, 'Math', '... got the right fully qualified Javascript name');

my $i = $ns->get_element_by_name('Simple');
isa_ok($i, 'JSORB::Interface');
isa_ok($i, 'JSORB::Namespace');
isa_ok($i, 'JSORB::Core::Element');

is($i->name, 'Simple', '... got the right name');
is($i->fully_qualified_perl_name, 'Math::Simple', '... got the right fully qualified Perl name');
is($i->fully_qualified_javascript_name, 'Math.Simple', '... got the right fully qualified Javascript name');

my $proc = $i->get_procedure_by_name('add');
isa_ok($proc, 'JSORB::Procedure');
isa_ok($proc, 'JSORB::Core::Element');

is($proc->name, 'add', '... got the right name');
is($proc->fully_qualified_perl_name, 'Math::Simple::add', '... got the right fully qualified Perl name');
is($proc->fully_qualified_javascript_name, 'Math.Simple.add', '... got the right fully qualified Javascript name');
is($proc->body, \&add, '... got the body we expected');
is_deeply($proc->spec, [ qw[ Int Int Int ] ], '... got the spec we expected');






















