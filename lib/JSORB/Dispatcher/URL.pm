package JSORB::Dispatcher::URL;
use Moose;

use Path::Router;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'namespace' => (
    is       => 'ro',
    isa      => 'JSORB::Namespace',   
    required => 1,
);

has 'router' => (
    is      => 'ro',
    isa     => 'Path::Router',   
    lazy    => 1,
    builder => '_build_router',
);

sub _build_router {
    my $self = shift;
    my $router = Path::Router->new;
    $self->_process_elements(
        $router,
        '/',
        $self->namespace
    );
    $router;
}

sub _process_elements {
    my ($self, $router, $base_url, $namespace) = @_;
    
    $base_url .= lc($namespace->name) . '/';
    
    foreach my $element (@{ $namespace->elements }) {
        if ($element->isa('JSORB::Interface')) { 
            $self->_process_interface($router, $base_url, $element);
        }
        else {
            $self->_process_elements($router, $base_url, $element);            
        }
    }
}

sub _process_interface {
    my ($self, $router, $base_url, $interface) = @_;

    $base_url .= lc($interface->name) . '/';
    
    # NOTE:
    # perhaps I want to actually do:
    #  $router->add_route(
    #      ($base_url . ':method'),
    #      target => $interface,
    #  );    
    # instead so that the method becomes
    # a param and then the interface 
    # itself is the target ... which 
    # means I can then hand off the 
    # rest of the dispatching to the 
    # interface .. hmmm
    
    foreach my $procedure (@{ $interface->procedures }) {
        $router->add_route(
            ($base_url . lc($procedure->name)),
            target => $procedure
        );
    }    
}

no Moose; 1;

__END__

=pod

=head1 NAME

JSORB::Dispatcher::URL - A Moosey solution to this problem

=head1 SYNOPSIS

  use JSORB::Dispatcher::URL;

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
