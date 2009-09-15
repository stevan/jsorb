package JSORB::Client::Compiler::Javascript;
use Moose;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

sub compile_namespace {
    my ($self, $root) = @_;

    confess "You must compile the namespace from it's root"
        if $root->has_parent;

    my @out;

    my $name = $root->name;

    push @out => "if (${name} == undefined) var ${name} = function () {};";
    push @out => $self->_compile_namespace( $root );

    join "\n" => @out, '';
}

sub _compile_namespace {
    my ($self, $ns) = @_;

    my @out;

    foreach my $element ( @{ $ns->elements } ) {
        if ($element->isa('JSORB::Interface')) {
            push @out => '', $self->compile_interface( $element );
        }
        else {
            my $name = join '.' => @{ $element->fully_qualified_name };
            push @out => "if (${name} == undefined) ${name} = function () {};";
        }

        push @out => $self->_compile_namespace( $element );
    }

    @out;
}

sub compile_interface {
    my ($self, $i) = @_;

    my @out;

    my @name = @{ $i->fully_qualified_name };
    my $name = join '.' => @name;
    my $path = join '/' => map { lc } @name;

    push @out => (
         "${name} = function (url) {",
         "    this._JSORB_CLIENT = new JSORB.Client ({",
         "        base_url       : url,",
         "        base_namespace : '/${path}/'",
         "    });",
         "}",
    );

    foreach my $proc ( @{ $i->procedures } ) {
        push @out => '', $self->compile_procedure( $proc );
    }

    @out;
}

sub compile_procedure {
    my ($self, $p) = @_;

    ($p->has_spec)
        || confess "Currently we only support compiling procedures with specs";

    my @out;

    my @name       = @{ $p->fully_qualified_name };
    my $local_name = pop @name;
    my $i_name     = join '.'  => @name;
    my $arg_list   = join ', ' => map { "arg${_}" } 1 .. @{ $p->parameter_spec };

    push @out => (
        "${i_name}.prototype.${local_name} = function (${arg_list}, callback) {",
        "    this._JSORB_CLIENT.call(",
        "        { method : '${local_name}', params : [ ${arg_list} ] },",
        "        callback",
        "    )",
        "}",
    );

    @out;
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
