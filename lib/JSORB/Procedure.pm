package JSORB::Procedure;
use Moose;

use JSORB::Types;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

extends 'JSORB::Core::Element';

has 'body' => (
    is       => 'ro',
    isa      => 'CodeRef',   
    required => 1,
);      

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
    isa     => 'JSORB::Spec',   
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

sub call {
    my ($self, @args) = @_;

    if ($self->has_spec) {
        my @params = @{ $self->parameter_spec };
        
        (scalar @params == scalar @args)
            || confess "Not enough arguments, got (" 
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

    my $result = $self->body->(@args);

    ($self->return_value_spec->check($result))
        || confess "Return value $result did not pass the return value spec, "
                 . "we expected " . $self->return_value_spec->name
        if $self->has_spec;
    
    $result;
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
