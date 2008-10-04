package TestApp::Controller::Foo;
use Moose;

use JSORB::Dispatcher::Catalyst::WithInvocant;

BEGIN { extends 'Catalyst::Controller' };

{
    package Test::App;
    use Moose;
    
    sub foo {
        my ($self, $c, $who) = @_;
        return "Yo! What's up $who";    
    }
}

__PACKAGE__->config(
    'Action::JSORB' => JSORB::Dispatcher::Catalyst::WithInvocant->new(
        invocant      => Test::App->new,
        namespace     => JSORB::Namespace->new(
            name     => 'Test',
            elements => [
                JSORB::Interface->new(
                    name       => 'App',            
                    procedures => [
                        JSORB::Method->new(
                            name        => 'greeting',
                            method_name => 'foo',
                            spec        => [ 'Catalyst' => 'Str' => 'Str' ],
                        ),    
                    ]
                )            
            ]
        )
    )    
);

sub rpc : Local : ActionClass(JSORB) {}


1;