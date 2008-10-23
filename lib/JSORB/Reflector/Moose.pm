package JSORB::Reflector::Moose;
use Moose;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'metaclass' => (
    is       => 'ro',
    isa      => 'Moose::Meta::Class',   
    required => 1,
    handles  => {
        'class_name' => 'name'
    }
);

has 'method_list' => (
    is      => 'ro',
    isa     => 'ArrayRef[HashRef]',   
    lazy    => 1,
    builder => 'build_method_list',
);

has 'namespace' => (
    is      => 'ro',
    isa     => 'JSORB::Namespace',   
    lazy    => 1,
    builder => 'build_namespace',
);

sub build_namespace {
    my $self = shift;
    
    my @name = split /\:\:/ => $self->class_name;
    
    my $root_ns;
    
    my $interface = JSORB::Interface->new(name => pop @name);
    
    if (@name) {
        $root_ns   = JSORB::Namespace->new(name => shift @name);

        my $current_ns = $root_ns;    
        while (@name) {
            my $ns = JSORB::Namespace->new(name => shift @name);
            $current_ns->add_element($ns);
            $current_ns = $ns;
        }
    
        $current_ns->add_element($interface);
    }
    else {
        $root_ns = $interface;
    }
    
    foreach my $method_spec (@{ $self->method_list }) {
        $interface->add_procedure(
            JSORB::Method->new( $method_spec )
        );
    }
    
    return $root_ns;
}

sub build_method_list {
    my $self = shift;
    return [ map { +{ name => $_ } } $self->metaclass->get_method_list ]
}

no Moose; 1;

__END__

=pod

=head1 NAME

JSORB::Reflector::Moose - A Moosey solution to this problem

=head1 SYNOPSIS

  use JSORB::Reflector::Moose;

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
