package Catalyst::Controller::JSORB;
use Moose;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

extends 'Catalyst::Controller';

sub ACCEPT_CONTEXT {
    my ($self, $c, @args) = @_;

    if (not exists $self->config->{'Action::JSORB'}) {

        my $method = $self->can('setup_jsorb_dispatcher');

        (defined $method)
            || confess "No JSORB Dispatcher found.";

        my $dispatcher = $self->$method($c, @args);

        (blessed $dispatcher && $dispatcher->isa('JSORB::Dispatcher::Path'))
             || confess "Bad dispatcher - $dispatcher";

        $self->config->{'Action::JSORB'} = $dispatcher;
    }
    
    if (my $method = $self->can('create_dynamic_invocant')) {
        
        ($self->config->{'Action::JSORB'}->does('JSORB::Dispatcher::Traits::WithDynamicInvocant'))
            || confess "Your dispatcher must do the JSORB::Dispatcher::Traits::WithDynamicInvocant role";
        
        my $invocant = $self->$method($c, @args);
        
        (defined $invocant)
            || confess "Invocant creation controlled";
        
        $self->config->{'Action::JSORB'}->invocant($invocant);
    }

    $self;
}

no Moose; 1;

__END__

=pod

=head1 NAME

Catalyst::Controller::JSORB - A Moosey solution to this problem

=head1 SYNOPSIS

  use Catalyst::Controller::JSORB;

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
