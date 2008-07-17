package JSORB::Server::Simple;
use Moose;

use HTTP::Engine;
use JSON::RPC::Common::Marshal::HTTP;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'request_marshaler' => (
    is      => 'ro',
    isa     => 'JSON::RPC::Common::Marshal::HTTP',   
    lazy    => 1,
    default => sub {
        JSON::RPC::Common::Marshal::HTTP->new;
    },
);

has 'dispatcher' => (
    is       => 'ro',
    isa      => 'JSORB::Dispatcher::URL',   
    required => 1,
);

has 'server_engine' => (
    is      => 'ro',
    isa     => 'HTTP::Engine', 
    lazy    => 1,  
    default => sub {    
        my $self = shift;
        HTTP::Engine->new(
             interface => {
                 module => 'ServerSimple',
                 args   => {
                     host => 'localhost',
                     port =>  8080,
                 },
                 request_handler => $self->handler,
             },
         );
    },
    handles => [qw[run]]
);

has 'handler' => (
    is      => 'ro',
    isa     => 'CodeRef',   
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $m    = $self->request_marshaler;
        my $d    = $self->dispatcher;        
        use Data::Dumper;
        return sub {
            my $c = shift;
            eval {
                my $call = $m->request_to_call($c->req);
                my $response = $d->handler($call);
                $m->write_result_to_response($response, $c->res);
            };
            if ($@) {
                $c->res->status(500);
                $c->res->body($@);
            }    
        }        
    },
);

no Moose; 1;

__END__

=pod

=head1 NAME

JSORB::Server::Simple - A Moosey solution to this problem

=head1 SYNOPSIS

  use JSORB::Server::Simple;

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
