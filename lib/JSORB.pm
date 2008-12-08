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

JSORB - Javascript Object Request Broker

=head1 SYNOPSIS

  # Set up a simple JSORB server

  use JSORB;
  use JSORB::Server::Simple;
  use JSORB::Dispatcher::Path;
  use JSORB::Reflector::Package;
  
  {
      package Math::Simple;
      use Moose;

      sub add { $_[0] + $_[1] }
  }
 
  
  JSORB::Server::Simple->new(
      port       => 8080,
      dispatcher => JSORB::Dispatcher::Path->new(
          namespace => JSORB::Reflector::Package->new(
              introspector   => Math::Simple->meta,
              procedure_list => [
                  { name => 'add', spec => [ ('Int', 'Int') => 'Int' ] }
              ]
          )->namespace
      )
  )->run;
  
  # go to the URL directly ...
  http://localhost:8080/?method=/math/simple/add&params=[2,2]  
  
  # and get back a response ...
  {"jsonrpc":"2.0","result":2}
  
  # or use the Javascript client library
  
  var c = new JSORB.Client ({
      base_url : 'http://localhost:8080/',
  })
  
  c.call({
      method : '/math/simple/add',
      params : [ 2, 2 ]
  }, function (result) {
      alert(result)
  });

=head1 DESCRIPTION

                                         __
          __                            /\ \
         /\_\      ____    ___    _ __  \ \ \____
         \/\ \    /',__\  / __`\ /\`'__\ \ \ '__`\
          \ \ \  /\__, `\/\ \L\ \\ \ \/   \ \ \L\ \
          _\ \ \ \/\____/\ \____/ \ \_\    \ \_,__/
         /\ \_\ \ \/___/  \/___/   \/_/     \/___/
         \ \____/
          \/___/

=head2 DISCLAIMER

This is a B<VERY VERY> early release of this module, and while 
it is quite functional, this module should in no way be seen as 
complete. You are more then welcome to experiment and play 
around with this module, but don't come crying to me if it 
accidently deletes your MP3 collection, kills the neighbors dog 
and causes the large hadron collider to create a black hole that 
swallows up all of existence tearing you molecule from molecule 
along the event horizon for all eternity. 

=head2 GOAL

The goal of this module is to provide a cleaner and more formalized 
way to do AJAX programming using JSON-RPC in the flavor of Object 
Request Brokers. 

=head2 FUTURE PLANS

Currently this is more focused on RPC calls between Perl on the 
server side and Javascript on the client side. Eventually we will 
have a Perl client and possibly some servers written in other 
languages as well. 

Plans for auto-generation of the Javascript clients is also on 
my TODO list. These clients will provide a more natural style of
programming with Javascript objects and reduce the heavy RPC 
slant of the current usage patterns.

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
