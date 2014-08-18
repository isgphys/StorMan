#!/usr/bin/env perl
use lib '/opt/StorMan/lib';
use Cwd qw( abs_path );
use Dancer;
use StorMan::Routes;

my $prefix = dirname( abs_path($0) );

if ( -e "$prefix/config.yml" ) {
    Dancer->dance;
} else {
    print "Error config.yml missing!\n";
}
