package TestApp::Controller::Bar;
use Moose;

use JSORB;
use JSORB::Dispatcher::Catalyst::WithInvocant;

BEGIN { extends 'Catalyst::Controller::JSORB' };

{
    package Another::Test::App;
    use Moose;
    
    has 'place' => (is => 'ro', isa => 'Str');
    
    sub foo { "It's the end of the " . (shift)->place }
}

sub setup_jsorb_dispatcher {
    my ($self, $c) = @_;
    return JSORB::Dispatcher::Path->new_with_traits(
        traits    => [ 'JSORB::Dispatcher::Traits::WithInvocant' ],
        invocant  => Another::Test::App->new(place => $c->config->{'who'}),
        namespace => JSORB::Namespace->new(
            name     => 'Another', 
            elements => [
                JSORB::Namespace->new(
                    name     => 'Test',
                    elements => [
                        JSORB::Interface->new(
                            name       => 'App',            
                            procedures => [
                                JSORB::Method->new(
                                    name        => 'greeting',
                                    method_name => 'foo',
                                    spec        => [ 'Unit' => 'Str' ],
                                ),    
                            ]
                        )            
                    ]
                )
            ]
        )
    )
}

sub rpc : Local : ActionClass(JSORB) {}


1;