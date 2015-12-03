package StorMan::Iscsi;

use 5.010;
use strict;
use warnings;
use Dancer ':syntax';
use StorMan::Config;
use StorMan::Common;

use Exporter 'import';
our @EXPORT = qw(
    get_iscsi_nodes
    discover_new_target
    login_on_node
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

            my $proto                        = $nodesinfo{$server}{$iqn}{protocol} eq "iser" ? "check_lightgreen" : "check_green";
            $nodesinfo{$server}{$iqn}{login} = $proto;
        }
    }
    return \%nodesinfo;
}

sub discover_new_target {
    my ($targetIP, $server) = @_;
    my $return_msg = "Error";
    my $err_code = 0;

    my @tpgts = remotewrapper_command( $server, 'StorMan/iscsi_discovery', $targetIP );

    foreach my $tpgt (@tpgts) {
        $return_msg = "Found new TPGT on $targetIP - $tpgt";
        $err_code = 0;
    }

    info("iSCSI-Discovery Err: $err_code  - $return_msg");

    return ( $err_code, $return_msg );
}

sub login_on_node {
    my ($iqn, $targetIP, $server) = @_;

    my $data = {
        iqn      => $iqn,
        targetip => $targetIP
    };

    my $json_text = to_json($data, { pretty => 0 });
    $json_text    =~ s/"/\\"/g; # needed for correct remotesshwrapper transfer

    my ( $feedback ) = remotewrapper_command( $server, 'StorMan/iscsi_login', $json_text );

    my $feedback_ref = from_json( $feedback );
    my $return_code = $feedback_ref->{'return_code'};
    my $return_msg  = $feedback_ref->{'return_msg'};

    info("iSCSI-Login Err: $return_code  - $return_msg");

    return ( $return_code, $return_msg );
}

1;
