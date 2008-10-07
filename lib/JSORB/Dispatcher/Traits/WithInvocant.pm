package JSORB::Dispatcher::Traits::WithInvocant;
use Moose::Role;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

around 'assemble_params_list' => sub {
    my $next = shift;
    my ($self, $call, $invocant, @args) = @_;
    return ($invocant, $self->$next( $call, @args ));    
};

no Moose::Role; 1;

__END__

=pod

=head1 NAME

JSORB::Dispatcher::Traits::WithInvocant - A Moosey solution to this problem

=head1 SYNOPSIS

  use JSORB::Dispatcher::Traits::WithInvocant;

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
