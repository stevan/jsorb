package JSORB::Server::Traits::WithDebug;
use Moose::Role;

use Text::SimpleTable;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

around 'build_handler' => sub {
    my $next    = shift;
    my $self    = shift;
    my $handler = $self->$next(@_);
    return sub {
        my $request = shift;
    
        my $t = Text::SimpleTable->new(15, 55);
        $t->row('Method',      $request->method);        
        $t->row('Request URI', $request->request_uri);        
        
        my $t2 = Text::SimpleTable->new([ 15, 'Parameter' ], [ 55, 'Value' ]);        
        $t2->row($_, $request->param($_)) for sort $request->param;        
        
        warn $t->draw, "\n", $t2->draw, "\n";
        
        $handler->($request);
    }
};

no Moose::Role; 1;

__END__

=pod

=head1 NAME

JSORB::Server::Traits::WithDebug - A Moosey solution to this problem

=head1 SYNOPSIS

  use JSORB::Server::Traits::WithDebug;

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
