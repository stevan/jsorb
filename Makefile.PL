#!/usr/bin/env perl
use inc::Module::Install;

name 'JSORB';
all_from 'lib/JSORB.pm';

requires 'Moose'                    => 0;
requires 'MooseX::AttributeHelpers' => 0;
requires 'MooseX::Traits'           => 0;

requires 'JSON::RPC::Common'        => 0;
requires 'Path::Router'             => 0;

# for JSORB::Server::Simple
requires 'HTTP::Engine'             => 0;

# for Catalyst::Action::JSORB
requires 'Catalyst'                 => 0;

WriteAll;
