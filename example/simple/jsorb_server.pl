#!/usr/bin/perl

use strict;
use warnings;

use lib "$FindBin::Bin/../../lib";

use JSORB;
use JSORB::Server::Simple;
use JSORB::Dispatcher::Path;

JSORB::Server::Simple->new_with_traits(
    port       => 9999,
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