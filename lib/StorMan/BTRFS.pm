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
    get_btrfs_status
    btrfs_worker
);

sub get_btrfs_status {
    my ($type) = @_;
    my $fsinfo = get_fsinfo();
    my $server = "phd-bkp-gw";
    my @mountpts;

    foreach my $mountpt ( keys %{$fsinfo->{$server}} ) {
        push (@mountpts, $fsinfo->{$server}->{$mountpt}{mount});
    }

    my $json   = JSON->new->allow_nonref;
    my $json_text = $json->encode(\@mountpts);
    $json_text =~ s/"/\\"/g; # needed for correct remotesshwrapper transfer

    my ($status_info) = remotewrapper_command( $server, "StorMan-dev/btrfs_${type}_status", $json_text );
    my $status_ref       = decode_json( $status_info );

    return $status_ref;
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
