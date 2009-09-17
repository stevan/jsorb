package JSORB::Client::Compiler::Javascript;
use Moose;

use Try::Tiny;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

with 'JSORB::Client::Compiler';

sub compile_root_namespace {
    my ($self, $root) = @_;
    $self->perform_unit_of_work(sub {
        my $name = $root->name;
        $self->print_to_buffer( "if (${name} == undefined) var ${name} = function () {};" );
        $self->compile_namespace( $root );
    });
}

sub compile_namespace {
    my ($self, $ns) = @_;
    $self->perform_unit_of_work(sub {
        foreach my $element ( @{ $ns->elements } ) {
            if ($element->isa('JSORB::Interface')) {
                $self->compile_interface( $element );
            }
            else {
                my $name = join '.' => @{ $element->fully_qualified_name };
                $self->print_to_buffer( "if (${name} == undefined) ${name} = function () {};" );
            }

            $self->compile_namespace( $element );
        }
    });
}

sub compile_interface {
    my ($self, $i) = @_;
    $self->perform_unit_of_work(sub {
        my @name = @{ $i->fully_qualified_name };
        my $name = join '.' => @name;
        my $path = join '/' => map { lc } @name;

        $self->print_to_buffer(
             "${name} = function (url) {",
             "    this._JSORB_CLIENT = new JSORB.Client ({",
             "        base_url       : url,",
             "        base_namespace : '/${path}/'",
             "    });",
             "}",
        );

        foreach my $proc ( @{ $i->procedures } ) {
            $self->compile_procedure( $proc );
        }
    });
}

sub compile_procedure {
    my ($self, $p) = @_;
    $self->perform_unit_of_work(sub {
        ($p->has_spec)
            || confess "Currently we only support compiling procedures with specs";

        my @name       = @{ $p->fully_qualified_name };
        my $local_name = pop @name;
        my $i_name     = join '.'  => @name;
        my $arg_list   = join ', ' => map { "arg${_}" } 1 .. @{ $p->parameter_spec };

        $self->print_to_buffer(
            "${i_name}.prototype.${local_name} = function (${arg_list}, callback) {",
            "    this._JSORB_CLIENT.call(",
            "        { method : '${local_name}', params : [ ${arg_list} ] },",
            "        callback",
            "    )",
            "}",
        );
    });
}


__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=head1 NAME

JSORB::Client::Compiler::Javascript - A Moosey solution to this problem

=head1 SYNOPSIS

  use JSORB::Client::Compiler::Javascript;

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
