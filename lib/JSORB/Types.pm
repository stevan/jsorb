package JSORB::Types;
use Moose;
use Moose::Util::TypeConstraints;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

# ... for JSORB::Procedure ....

type 'Unit' => where { () };

class_type 'Moose::Meta::TypeConstraint'
    if !find_type_constraint('Moose::Meta::TypeConstraint');

subtype 'JSORB::Spec::Type'
    => as 'Moose::Meta::TypeConstraint'
    => where {
        # these are the types of things that cannot be
        # serialized into JSON so will be neither arguments
        # or return values in our RPC environment.
        ($_->is_a_type_of($_) || return) for map { 
            find_type_constraint($_)
        } qw[
            CodeRef
            RegexpRef
            GlobRef
            Object
        ]; 1;
    };

subtype 'JSORB::Spec' 
    => as 'ArrayRef[JSORB::Spec::Type]'
    => where {
        my $length = scalar @$_;
        # must have at least 2 elements, 
        # param and return value
        return unless $length >= 2;
        # if the first item is Unit, then 
        # there can only be 2 items 
        ($length == 2 || return) if $_->[0]->name eq 'Unit';        
        # if there are more than one Unit 
        # type that is wrong ...
        return if scalar( grep { $_->name eq 'Unit' } @$_ ) > 2; 
        1;
    };
    
subtype 'JSORB::ParameterSpec' 
    => as 'ArrayRef[JSORB::Spec::Type]'
    => where {
        (scalar @$_ == 1 || return) if $_->[0]->name eq 'Unit'; 1;
    };    

coerce 'JSORB::Spec' 
    => from 'ArrayRef[Str]'
        => via { +[ 
            map { 
                Moose::Util::TypeConstraints::find_or_parse_type_constraint($_) 
            } @$_ 
        ] };

no Moose; no Moose::Util::TypeConstraints; 1;

__END__

=pod

=head1 NAME

JSORB::Types - A set of 

=head1 SYNOPSIS

  use JSORB::Types;

=head1 DESCRIPTION

=head1 METHODS

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
