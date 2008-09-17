package TestApp;

use strict;
use warnings;

use Catalyst;

use JSORB;
use JSORB::Dispatcher::Path;

use Moose::Util::TypeConstraints qw[class_type];

class_type 'Catalyst';

our $VERSION = '0.01';

TestApp->config( 
    name  => 'TestApp', 
    root  => '/some/dir',
    who   => 'World',
    JSORB => {
        dispatcher => JSORB::Dispatcher::Path->new_with_traits(
            traits        => [ 'JSORB::Dispatcher::Traits::WithContext' ],
            context_class => 'Catalyst',
            namespace     => JSORB::Namespace->new(
                name     => 'Test',
                elements => [
                    JSORB::Interface->new(
                        name       => 'App',            
                        procedures => [
                            JSORB::Procedure->new(
                                name  => 'greeting',
                                body  => sub {
                                    my ($c) = @_;
                                    return 'Hello ' . $c->config->{'who'};
                                },
                                spec  => [ 'Catalyst' => 'Str' ],
                            ),
                        ]
                    )            
                ]
            )
        )
    }
);

TestApp->setup;

sub rpc : Global : ActionClass(JSORB) {}

1;
