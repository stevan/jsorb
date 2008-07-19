package JSORB::Core::Roles::HasSpec;
use Moose::Role;

use JSORB::Types;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'spec' => (
    metaclass => 'Collection::Array',
    is        => 'ro',
    isa       => 'JSORB::Spec', 
    coerce    => 1,  
    default   => sub { [] },
    provides  => {
        'empty' => 'has_spec'
    }
);

has 'parameter_spec' => (
    is      => 'ro',
    isa     => 'JSORB::ParameterSpec',   
    lazy    => 1,
    default => sub {
        my $self = shift;
        [ @{ $self->spec }[ 0 .. ($#{ $self->spec } - 1) ] ]
    },
);

has 'return_value_spec' => (
    is      => 'ro',
    isa     => 'JSORB::Spec::Type',   
    lazy    => 1,
    default => sub { (shift)->spec->[-1] },
);

sub check_parameter_spec {
    my ($self, @args) = @_;
    
    return unless $self->has_spec;
    
    my @params = @{ $self->parameter_spec };
    
    return if scalar @params == 1 && 
              scalar   @args == 0 && 
              $params[0]->name eq 'Unit'; 
    
    (scalar @params == scalar @args)
        || confess "Bad number of arguments, got (" 
                 . scalar @args 
                 . "), expected (" 
                 . scalar @params 
                 . ")"; 
    
    foreach my $i (0 .. $#args) {
        ($params[$i]->check($args[$i]))
            || confess "Parameter at position $i ($args[$i]) did not pass the spec, "
                     . "we expected " . $params[$i]->name;
    }    
}

sub check_return_value_spec {
    my ($self, @result) = @_;
    return unless $self->has_spec;
    
    my $rv = $self->return_value_spec;
    
    (scalar @result == 0)
        || confess "Return value is Unit but a value was returned @result"
        if $rv->name eq 'Unit';
    
    ($rv->check($result[0]))
        || confess "Return value $result[0] did not pass the return value spec, "
                 . "we expected " . $rv->name;
}


no Moose::Role; 1;

__END__

=pod

=head1 NAME

JSORB::Core::Roles::HasSpec - A Moosey solution to this problem

=head1 SYNOPSIS

  use JSORB::Core::Roles::HasSpec;

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
