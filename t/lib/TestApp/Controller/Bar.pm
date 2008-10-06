package TestApp::Controller::Bar;
use Moose;

use JSORB;
use JSORB::Dispatcher::Catalyst::WithInvocant;

BEGIN { extends 'Catalyst::Controller::JSORB' };

{
    package Another::Test::App;
    use Moose;
    
    has 'count' => (
        is      => 'ro',
        isa     => 'Int',   
    );
    
    has 'place' => (
        is      => 'ro',
        isa     => 'Str',   
        default => sub { 'World' },
    );
    
    sub foo { 
        my $self = shift;
        "It's the end of the " . $self->place . "(" . $self->count . ")" 
    }
}

my $counter = 0;

sub create_dynamic_invocant {
    my ($self, $c) = @_;
    Another::Test::App->new(count => $counter++);
}

sub setup_jsorb_dispatcher {
    my ($self, $c) = @_;
    return JSORB::Dispatcher::Path->new_with_traits(
        traits    => [ 'JSORB::Dispatcher::Traits::WithDynamicInvocant' ],
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