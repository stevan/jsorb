package TestApp::Controller::Foo;
use Moose;

BEGIN { extends 'Catalyst::Controller' };

__PACKAGE__->config(
    'Action::JSORB' => JSORB::Dispatcher::Catalyst->new(
        namespace     => JSORB::Namespace->new(
            name     => 'Test',
            elements => [
                JSORB::Interface->new(
                    name       => 'App',            
                    procedures => [
                        JSORB::Procedure->new(
                            name  => 'greeting',
                            body  => \&foo,
                            spec  => [ 'Catalyst' => 'Str' => 'Str' ],
                        ),    
                    ]
                )            
            ]
        )
    )    
);

sub rpc : Local : ActionClass(JSORB) {}

sub foo : Private {
    my ($c, $who) = @_;
    return "Yo! What's up $who";    
}

1;