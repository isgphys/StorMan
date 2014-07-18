package StorMan::BTRFS;

use 5.010;
use strict;
use warnings;
use StorMan::Config;
use StorMan::Common;
use StorMan::Hosts;
use JSON;

use Exporter 'import';
our @EXPORT = qw(
    get_balance_status
    get_scrub_status
);

sub get_balance_status {
    my $fsinfo = get_fsinfo();
    my $server = "phd-bkp-gw";
    my $mounts;

    foreach my $mountpt ( keys %{$fsinfo->{$server}} ) {
        $mounts .= "$fsinfo->{$server}->{$mountpt}{mount}#"; #special serialized
    }

    my ($balance_info) = remotewrapper_command( $server, 'StorMan/btrfs_balance_status', $mounts );
    my $info_ref       = decode_json( $balance_info );

#    print $info_ref->{'/export/backup/group/ipp'}->{'output'};

    return $info_ref;
}

sub get_scrub_status {
    my $fsinfo = get_fsinfo();
    my $server = "phd-bkp-gw";
    my $mounts;

    foreach my $mountpt ( keys %{$fsinfo->{$server}} ) {
        $mounts .= "$fsinfo->{$server}->{$mountpt}{mount}#"; #special serialized
    }

    my ($scrub_info) = remotewrapper_command( $server, 'StorMan/btrfs_scrub_status', $mounts );
    my $info_ref     = decode_json( $scrub_info );

    return $info_ref;
}

1;
