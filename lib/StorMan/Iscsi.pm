package StorMan::Iscsi;

use 5.010;
use strict;
use warnings;
use StorMan::Hosts;

use Exporter 'import';
our @EXPORT = qw(
    get_iscsi_sessions
);

my $iscsiadm = '/sbin/iscsiadm';

sub get_iscsi_sessions {
    my @sessions;
    my %sessioninfo;

    foreach my $server ( 'phd-bkp-gw','phd-san-gw1','phd-san-gw2' ) {

        @sessions = remotewrapper_command( $server, 'StorMan/iscsi_sessions' );

        foreach my $session (@sessions) {
            $session =~ qr{
            ^(?<protocol> [\w]+):
            \s+\[(?<session_id> [\d]+)\]
            \s+(?<host_ip> [^:]*)
            :(?<port> [^,]+)
            ,(?<whatever>[\d]+)
            \s+(?<iqn> [^\$]+)
            }x;

            $sessioninfo{$server}{$+{session_id}} = {
                'protocol' => $+{protocol},
                'host_ip'  => $+{host_ip},
                'port'     => $+{port},
                'whatever' => $+{whatever},
                'iqn'      => $+{iqn},
            };
        }
    }
    return \%sessioninfo;
}

1;