package JSORB::Procedure;
use Moose;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

extends 'JSORB::Core::Element';
   with 'JSORB::Core::Roles::HasSpec',
        'MooseX::Traits';

has 'body' => (
    is      => 'ro',
    isa     => 'CodeRef',   
    lazy    => 1,
    default => sub {
        my $self      = shift;
        my @full_name = @{ $self->fully_qualified_name };
        my $sub_name  = pop @full_name;
        my $pkg_name  = join '::' => @full_name;
        my $meta      = Class::MOP::Class->initialize($pkg_name || 'main');
        $meta->has_package_symbol({ name => $sub_name, sigil => '&', type => 'CODE' })
            || confess "Could not find $sub_name in package " . $meta->name;
        $meta->get_package_symbol({ name => $sub_name, sigil => '&', type => 'CODE' })
    }
);      

sub call {
    my ($self, @args) = @_;
    $self->check_parameter_spec(@args);
    my @result = ($self->body->(@args));
    $self->check_return_value_spec(@result);
    $result[0];
}

no Moose; 1;

__END__

=pod

=head1 NAME

JSORB::Procedure - A Moosey solution to this problem

=head1 SYNOPSIS

  use JSORB::Procedure;

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
