package JSORB::Server::Simple;
use Moose;

use HTTP::Engine;
use JSON::RPC::Common::Marshal::HTTP;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

with 'MooseX::Traits';

# has '+_trait_namespace' => ( default => 'JSORB::Server::Traits' );

has 'dispatcher' => (
    is       => 'ro',
    isa      => 'JSORB::Dispatcher::Path',   
    required => 1,
);

has 'host' => (
    is      => 'ro',
    isa     => 'Str',   
    default => sub { 'localhost' },
);

has 'port' => (
    is      => 'ro',
    isa     => 'Int',   
    default => sub { 9999 },
);

has 'request_marshaler' => (
    is      => 'ro',
    isa     => 'JSON::RPC::Common::Marshal::HTTP',   
    default => sub { JSON::RPC::Common::Marshal::HTTP->new },
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
                     host => $self->host,
                     port => $self->port,
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
    builder => 'build_handler',
);

sub prepare_handler_args { () }

sub build_handler {
    my $self = shift;
    my $m    = $self->request_marshaler;
    my $d    = $self->dispatcher;        
    return sub {
        my $request  = shift;
        my $response = HTTP::Engine::Response->new;
        eval {
            my $call     = $m->request_to_call($request);
            my $result   = $d->handler(
                $call,
                $self->prepare_handler_args($call, $request)
            );
            $m->write_result_to_response($result, $response);
        };
        if ($@) {
            # NOTE:
            # should this return a JSONRPC error?
            # or is the standard HTTP Error okay?
            # - SL
            $response->status(500);
            $response->body($@);
        }    
        return $response;
    }        
}

# NOTE:
# we need to initialize the server
# engine so that it can be run 
# after a fork() such as in our 
# tests. Otherwise the laziness
# messes things up.
# -SL
sub BUILD { (shift)->server_engine }

no Moose; 1;

__END__

=pod

=head1 NAME

JSORB::Server::Simple

=head1 SYNOPSIS

  use JSORB::Server::Simple;

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
