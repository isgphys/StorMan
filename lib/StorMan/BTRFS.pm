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
    btrfs_worker
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

sub btrfs_worker {
    my ($tooltype, $event, $mount)= @_;
    my $server = "phd-bkp-gw";

    my $data = {
        "tooltype" => $tooltype,
        "event"    => $event,
        "mount"    => $mount,
    };

    my $json   = JSON->new->allow_nonref;
    my $json_text = $json->encode($data);
    $json_text =~ s/"/\\"/g; # needed for correct remotesshwrapper transfer

    my ( $feedback ) = remotewrapper_command( $server, 'StorMan/btrfs_worker', $json_text );

    my $feedback_ref = decode_json( $feedback );
    my $return_code = $feedback_ref->{'return_code'};
    my $return_msg  = $feedback_ref->{'return_msg'};

    return ($return_code, $return_msg);
}

1;
