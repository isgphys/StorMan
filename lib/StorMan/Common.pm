package StorMan::Common;

use 5.010;
use strict;
use warnings;
use POSIX qw( floor );
use Date::Parse;
use Data::Dumper;

use Exporter 'import';
our @EXPORT = qw(
    num2human
    time2human
    remotewrapper_command
);

sub num2human {
    # convert large numbers to K, M, G, T notation
    my ($num, $base) = @_;
    $base ||= 1000.;

    foreach my $unit ( '', qw(K M G T P) ) {
        if ( $num < $base ) {
            if ( $num < 10 && $num > 0 ) {
                return sprintf( "\%.1f \%s", $num, $unit );    # print small values with 1 decimal
            } else {
                return sprintf( "\%.0f \%s", $num, $unit );    # print larger values without decimals
            }
        }
        $num = $num / $base;
    }
}

sub time2human {

    # convert large times in minutes to hours
    my ($minutes) = @_;

    if ( $minutes < 60 ) {
        if ($minutes < 1 ) {
            return sprintf( "< 1 min", $minutes );
        } else {
            return sprintf( "%d min", $minutes );
        }
    } else {
        return sprintf( "\%dh\%02dmin", floor( $minutes / 60 ), $minutes % 60 );
    }
}

#################################
# RemoteWrapper
#
sub remotewrapper_command {
    my ($remoteHost, $remoteCommand, $remoteArgument) = @_;
    $remoteArgument ||= '';

    my $results = `ssh -o IdentitiesOnly=yes -i /var/www/.ssh/remotesshwrapper root\@$remoteHost /usr/local/bin/remotesshwrapper $remoteCommand $remoteArgument 2>/dev/null`;
    my @results = split( "\n", $results );

    return @results;
}

1;
