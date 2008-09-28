package Catalyst::Action::JSORB;
use Moose;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use JSORB;
use JSON::RPC::Common::Marshal::HTTP;

extends 'Catalyst::Action';

sub execute {
    my $self = shift;
    my ($controller, $c) = @_;
    $self->NEXT::execute(@_); 
    
    # try local, but if none exists, use global
    my $dispatcher = $controller->config->{'Action::JSORB'} || $c->config->{'Action::JSORB'};
    
    $dispatcher = $self->_inflate_dispatcher($dispatcher, $controller)
        unless blessed $dispatcher;
    
    ($dispatcher->isa('JSORB::Dispatcher::Catalyst'))
        || confess "Bad dispatcher - $dispatcher";   
    
    my $marshaler = JSON::RPC::Common::Marshal::HTTP->new;
    my $call      = $marshaler->request_to_call($c->request);    
    my $result    = $dispatcher->handler($call, $c);
    
    $marshaler->write_result_to_response($result, $c->response);    
}

sub _inflate_dispatcher {
    my ($self, $config, $controller) = @_;
    
    my ($package, $procs) = %$config;
    
    my $dispatcher = JSORB::Dispatcher::Catalyst->new(
        namespace => $self->_create_namespace(
            sub {
                map {
                    JSORB::Procedure->new( name => $_, %{ $procs->{$_} } )
                } keys %$procs                 
            },
            (split '::' => $package)
        )
    );    
    
    return $dispatcher;
}

sub _create_namespace {
    my ($self, $callback, @namespace) = @_;
    my $name = shift @namespace;    
    if (@namespace) {
        JSORB::Namespace->new(
            name     => $name,
            elements => [ $self->_create_namespace($callback, @namespace) ]
        )        
    }
    else {
        JSORB::Interface->new(
            name       => $name,
            procedures => [ $callback->() ]
        )        
    }
}

no Moose; 1;

__END__

=pod

=head1 NAME

Catalyst::Action::JSORB - A Moosey solution to this problem

=head1 SYNOPSIS

  use Catalyst::Action::JSORB;

=head1 DESCRIPTION

=head1 METHODS 

=over 4

=item B<>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
