#!perl

# A simple test to check for compilation.

use Test::More tests => 2;

use strict;

require_ok( 'Pod::SST' );

my $parser = Pod::SST->new;
isa_ok( $parser, "Pod::SST" );
