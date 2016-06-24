package StorMan::Converter;

use 5.010;
use strict;
use warnings;
use Date::Parse;
use POSIX qw( floor );

use Exporter 'import';
our @EXPORT = qw(
    num2human
    time2human
);

sub num2human {
    my ( $num, $base ) = @_;
    $base ||= 1000.;

    # convert large numbers to K, M, G, T notation
    foreach my $unit ( '', qw(k M G T P) ) {
        if ( $num < $base ) {
            if ( $num < 10 && $num > 0 ) {
                return sprintf( '%.2f %s', $num, $unit );    # print small values with 1 decimal
            } else {
                return sprintf( '%.1f %s', $num, $unit );    # print larger values without decimals
            }
        }
        $num = $num / $base;
    }
}

sub time2human {
    my ($minutes) = @_;

    # convert large times in minutes to hours
    if ( $minutes eq '-' ) {
        return '-';
    } else {
        if ( $minutes < 60 ) {
            if ( $minutes < 1 ) {
                return sprintf( '< 1 min', $minutes );
            } else {
                return sprintf( '%d min', $minutes );
            }
        } else {
            return sprintf( '%dh%02dmin', floor( $minutes / 60 ), $minutes % 60 );
        }
    }
}

1;
