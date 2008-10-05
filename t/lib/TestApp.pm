package TestApp;

use strict;
use warnings;

use Catalyst; #'-Debug';

use JSORB;
use JSORB::Dispatcher::Catalyst;

our $VERSION = '0.01';

TestApp->config( 
    name => 'TestApp', 
    who  => 'World',
    # add the JSORB config ...
    'Action::JSORB' => JSORB::Dispatcher::Catalyst->new(
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
);

TestApp->setup;

sub rpc : Global : ActionClass(JSORB) {}

1;
