package JSORB::Method;
use Moose;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

extends 'JSORB::Core::Element';
   with 'JSORB::Core::Roles::HasSpec';

has 'class_name' => (
    is      => 'ro',
    isa     => 'ClassName',   
    lazy    => 1,
    default => sub { 
        my $self = shift;
        ($self->has_parent)
            || confess "Class name is required, no parent to derive it froms";
        $self->parent->name 
    }
);

has 'method_name' => (
    is      => 'ro',
    isa     => 'Str',   
    lazy    => 1,
    default => sub { (shift)->name }
);      

sub call {
    my ($self, $invocant, @args) = @_;
    
    (blessed $invocant && $invocant->isa($self->class_name))
        || confess "The invocant must be an instance of " 
                 . $self->class_name 
                 . " not $invocant";
    
    $self->check_parameter_spec(@args)
        if $self->has_spec;
    
    my $method = $self->method_name;
    my @result = ($invocant->$method(@args));
    
    $self->check_return_value_spec(@result)
        if $self->has_spec;
    
    $result[0];
}

no Moose; 1;

__END__

=pod

=head1 NAME

JSORB::Method - A Moosey solution to this problem

=head1 SYNOPSIS

  use JSORB::Method;

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
