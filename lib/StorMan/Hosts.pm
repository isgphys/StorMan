package StorMan::Hosts;

use 5.010;
use strict;
use warnings;
use StorMan::Config;
use StorMan::Common;
use Net::Ping;

use Exporter 'import';
our @EXPORT = qw(
    get_fsinfo
    remotewrapper_command
);

sub get_fsinfo {
    my %fsinfo;
    foreach my $server ( keys %servers ) {
        my @mounts;
        @mounts = remotewrapper_command( $server, 'StorMan/bang_df' );

        foreach my $mount (@mounts) {
            $mount =~ qr{
                        ^(?<filesystem> [\/\w\d-]+)
                        \s+(?<fstyp> [\w\d]+)
                        \s+(?<blocks> [\d]+)
                        \s+(?<used> [\d]+)
                        \s+(?<available>[\d]+)
                        \s+(?<usedper> [\d]+)
                        .\s+(?<mountpt> [\/\w\d-]+)
            }x;

            $fsinfo{$server}{$+{mountpt}} = {
                'filesystem' => $+{filesystem},
                'mount'      => $+{mountpt},
                'fstyp'      => $+{fstyp},
                'blocks'     => num2human($+{blocks}),
                'used'       => num2human($+{used}*1024,1024),
                'available'  => num2human($+{available}*1024,1024),
                'freediff'   => "",
                'used_per'   => $+{usedper},
                'css_class'  => check_fill_level($+{usedper}),
            };
        }

        if ($server eq "phd-bkp-gw") {
            @mounts = remotewrapper_command( $server, 'StorMan/bang_di' ) ;
            foreach my $mount (@mounts) {
                $mount =~ qr{
                ^(?<filesystem> [\/\w\d-]+)
                \s+(?<fstyp>[\w\d]+)
                \s+(?<blocks>[\d]+)
                \s+(?<used>[\d]+)
                \s+(?<available>[\d]+)
                \s+(?<free>[\d]+)
                \s+(?<usedper>[\d]+)
                .\s+(?<mountpt>[\/\w\d-]+)
                }x;

                my $freediff    = $+{free} - $+{available};
                my $freediffper = 100 / $+{free} * $freediff;

                $fsinfo{$server}{$+{mountpt}}{freediff} = ( $freediffper > 10 ) ? num2human($freediff*1024,1024) : "" ;
            }
        }

    }

    return \%fsinfo;
}

sub check_fill_level {
    my ($level) = @_;
    my $css_class = '';

    if ( $level > 98 ) {
        $css_class = "alert_red";
    } elsif ( $level > 90 ) {
        $css_class = "alert_orange";
    } elsif ( $level > 80 ) {
        $css_class = "alert_yellow";
    }

    return $css_class;
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
