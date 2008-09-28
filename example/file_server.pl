#!/usr/bin/perl

use strict;
use warnings;
use FindBin;

{
    package FileServer;
    use Moose;

    extends 'HTTP::Server::Simple::CGI';
    use HTTP::Server::Simple::Static;

    sub handle_request {
        my ( $self, $cgi ) = @_;
        return $self->serve_static( $cgi, "$FindBin::Bin/../" );
    }
}

FileServer->new->run;