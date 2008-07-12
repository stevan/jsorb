package JSORB::Namespace;
use Moose;
use MooseX::AttributeHelpers;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

extends 'JSORB::Core::Element';

has 'elements' => (
    is      => 'ro',
    isa     => 'ArrayRef[JSORB::Namespace]',   
    default => sub { [] },
    trigger => sub {
        my $self = shift;
        $_->_set_parent($self)
            foreach @{ $self->elements };
    }
);

has '_element_map' => (
    metaclass => 'Collection::Hash',
    init_arg  => undef,    
    is        => 'ro',
    isa       => 'HashRef[JSORB::Namespace]', 
    lazy      => 1,  
    default   => sub {
        my $self = shift;
        return +{
            map { $_->name => $_ } @{ $self->elements }
        }
    },
    provides  => {
        'get' => 'get_element_by_name',
    }
);

no Moose; 1;

__END__

=pod

=head1 NAME

JSORB::Namespace - A Moosey solution to this problem

=head1 SYNOPSIS

  use JSORB::Namespace;

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
