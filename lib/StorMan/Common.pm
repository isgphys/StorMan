package StorMan::Common;

use 5.010;
use strict;
use warnings;
use POSIX qw( floor );
use Date::Parse;
use Data::Dumper;

use Exporter 'import';
our @EXPORT = qw(
    remotewrapper_command
);

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
