package JSORB::Interface;
use Moose;
use MooseX::AttributeHelpers;

use JSORB::Procedure;
use JSORB::Method;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

extends 'JSORB::Namespace';

has 'procedures' => (
    is      => 'ro',
    isa     => 'ArrayRef[JSORB::Procedure]',   
    default => sub { [] },
    trigger => sub {
        my $self = shift;
        $_->_set_parent($self)
            foreach @{ $self->procedures };
    }    
);

has '_procedure_map' => (
    metaclass => 'Collection::Hash',
    is        => 'ro',
    isa       => 'HashRef[JSORB::Procedure]', 
    lazy      => 1,  
    default   => sub {
        my $self = shift;
        return +{
            map { $_->name => $_ } @{ $self->procedures }
        }
    },
    provides  => {
        'get' => 'get_procedure_by_name',
    }
);

no Moose; 1;

__END__

=pod

=head1 NAME

JSORB::Interface - A Moosey solution to this problem

=head1 SYNOPSIS

  use JSORB::Interface;

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
