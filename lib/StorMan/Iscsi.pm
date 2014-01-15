package StorMan::Iscsi;

use 5.010;
use strict;
use warnings;

use Exporter 'import';
our @EXPORT = qw(
    get_iscsi_sessions
);

my $iscsiadm = '/sbin/iscsiadm';

sub get_iscsi_sessions {
    my @sessions;
    my %sessioninfo;
    my $server = "phd-bkp-gw";

    @sessions =  `$iscsiadm -m session`;

    # tcp: [1] 172.31.108.18:3260,1 iqn.2011-05.ch.ethz.phys:bkp18

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

    return \%sessioninfo;
}

1;
