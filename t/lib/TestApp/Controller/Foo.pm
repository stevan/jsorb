package TestApp::Controller::Foo;
use Moose;

use JSORB::Dispatcher::Catalyst::WithInvocant;

BEGIN { extends 'Catalyst::Controller' };

{
    package Test::App;
    use Moose;
    
    has 'greeting_prefix' => (
        is      => 'ro',
        isa     => 'Str',   
        default => sub { 'Yo!' },
    );
    
    sub foo {
        my ($self, $c, $who) = @_;
        return $self->greeting_prefix . " What's up $who";    
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

sub ACCEPT_CONTEXT {
    my ($self, $c, $args) = @_;
    $self->config->{'Action::JSORB'}->invocant(
        Test::App->new(
            greeting_prefix => $c->req->param('greeting_prefix') 
        )
    ) if $c->req->param('greeting_prefix');
    $self;
}

sub rpc : Local : ActionClass(JSORB) {}


1;