package JSORB;
use Moose;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use JSORB::Namespace;
use JSORB::Interface;
use JSORB::Procedure;
use JSORB::Method;

use JSORB::Types;

no Moose; 1;

__END__

=pod

=head1 NAME

JSORB - A Moosey solution to this problem

=head1 SYNOPSIS

  use JSORB;
  
  JSORB::Server::Simple->new(
      dispatcher => JSORB::Dispatcher::Path->new(
          namespace => JSORB::Namespace->new(
              name     => 'Math',
              elements => [
                  JSORB::Interface->new(
                      name       => 'Simple',            
                      procedures => [
                          JSORB::Procedure->new(
                              name  => 'add',
                              body  => sub { $_[0] + $_[0] },
                              spec  => [ 'Int' => 'Int' => 'Int' ],
                          )
                      ]
                  )            
              ]
          )
      )
  )->run;

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
