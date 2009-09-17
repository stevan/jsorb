package JSORB::Client::Compiler;
use Moose::Role;
use MooseX::AttributeHelpers;
use MooseX::Params::Validate;
use MooseX::Types::Path::Class;

use Buffer::Transactional;
use IO::Scalar;
use Try::Tiny;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has '_buffer' => (
    init_arg => undef,
    is       => 'rw',
    isa      => 'Buffer::Transactional'
);

has '_errors' => (
    metaclass => 'Collection::Array',
    init_arg  => undef,
    is        => 'ro',
    isa       => 'ArrayRef[Str]',
    lazy      => 1,
    default   => sub { [] },
    provides  => {
        'push'     => '_add_error',
        'elements' => 'get_all_errors',
    }
);

sub print_to_buffer {
    my ($self, @data) = @_;
    $self->_buffer->print( map { "$_\n" } @data );
}

sub perform_unit_of_work {
    my ($self, $work) = @_;
    try {
        $self->_buffer->begin_work;
        $work->();
        $self->_buffer->commit;
    } catch {
        $self->_buffer->rollback;
        $self->_add_error( $_ );
    };
}


sub compile {
    my ($self, $namespace, $output) = validated_list(\@_,
        namespace => { isa => 'JSORB::Namespace' },
        to        => { isa => 'Path::Class::File', coerce => 1, optional => 1 },
    );

    confess "Currently only compiling from root namespace is supported"
        if $namespace->has_parent;

    # FIXME:
    # this dual usage of $source is
    # yucky, I should fix it at some
    # point.
    # - SL

    my $source;

    unless (defined $output) {
        $self->_buffer( Buffer::Transactional->new( out => IO::Scalar->new( \$source ) ) );
    }
    else {
        $source = $output->openw;
        $self->_buffer( Buffer::Transactional->new( out => $source ) );
    }

    $self->perform_unit_of_work(sub {
        $self->compile_root_namespace( $namespace );
    });

    unless (defined $output) {
        return $source;
    }
    else {
        $source->close;
    }
}

requires 'compile_root_namespace';
requires 'compile_namespace';
requires 'compile_interface';
requires 'compile_procedure';

no Moose::Role; 1;

__END__

=pod

=head1 NAME

JSORB::Client::Compiler - A Moosey solution to this problem

=head1 SYNOPSIS

  use JSORB::Client::Compiler;

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

Copyright 2009 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
