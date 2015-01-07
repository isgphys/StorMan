package StorMan::Iscsi;

use 5.010;
use strict;
use warnings;
use StorMan::Config;
use StorMan::Common;

use Exporter 'import';
our @EXPORT = qw(
    get_iscsi_nodes
);

sub get_iscsi_nodes {
    my @nodes;
    my %nodesinfo;
    my @sessions;
    my %sessioninfo;

    foreach my $server ( keys %servers ) {

        @nodes    = remotewrapper_command( $server, 'StorMan/iscsi_nodes' );
        @sessions = remotewrapper_command( $server, 'StorMan/iscsi_sessions' );

        foreach my $node (@nodes) {
            $node =~ qr{
            ^(?<host_ip> [^:]*)
            :(?<port> [^,]+)
            ,(?<nodesessnr>[\d]+)
            \s+(?<iqn> [^\$]+)
            }x;

            $nodesinfo{$server}{$+{iqn}} = {
                'host_ip'    => $+{host_ip},
                'port'       => $+{port},
                'nodesessnr' => $+{nodesessnr},
                'login'      => "check_red",
            };

        }

        foreach my $session (@sessions) {
            $session =~ qr{
            ^(?<protocol> [\w]+):
            \s+\[(?<session_id> [\d]+)\]
            \s+(?<host_ip> [^:]*)
            :(?<port> [^,]+)
            ,(?<whatever>[\d]+)
            \s+(?<iqn> [^\$]+)
            }x;

            my $iqn = $+{iqn};
            $nodesinfo{$server}{$iqn}{session_id} = $+{session_id};
            $nodesinfo{$server}{$iqn}{protocol}   = $+{protocol};
            $nodesinfo{$server}{$iqn}{login}      = "check_green";
        }
    }
    return \%nodesinfo;
}

1;
