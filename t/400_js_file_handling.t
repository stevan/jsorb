#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 8;
use Test::Exception;

use FindBin;
use Path::Class;

BEGIN {
    use_ok('JS::JSORB');
}

my $js_jsorb = JS::JSORB->new;
isa_ok($js_jsorb, 'JS::JSORB');

is(
   $js_jsorb->js_file->absolute,
   file( $FindBin::Bin )->parent->file( 'lib', 'JS', 'JSORB.js' ),
   '... got the correct path'
);

is(
   $js_jsorb->js_text,
   file( $FindBin::Bin, '..', 'lib', 'JS', 'JSORB.js' )->slurp,
   '... got the correct text'
);

my $dest = file( $FindBin::Bin, 'JSORB.js' );

ok(! -e $dest, '... this file doesn\'t exist yet');

lives_ok {
    $js_jsorb->copy_js_file_to( $dest->stringify )
} '... successfully copied JSORB.js file';

ok(-e $dest, '... the file exists now');

is(
   $js_jsorb->js_text,
   $dest->slurp,
   '... and the file is exactly correct'
);

unlink $dest->stringify;