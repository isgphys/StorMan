package StorMan::BTRFS;

use 5.010;
use strict;
use warnings;
use Dancer ':syntax';
use StorMan::Config;
use StorMan::Common;
use StorMan::Hosts;

use Exporter 'import';
our @EXPORT = qw(
    get_btrfs_status
    btrfs_worker
);

sub get_btrfs_status {
    my ($type, $mount) = @_;
    my $fsinfo = get_fsinfo();
    my $server = "phd-bkp-gw";
    my @mountpts;

    if ( $mount ) {
        push (@mountpts, $mount);
    } else{
        foreach my $mountpt ( keys %{$fsinfo->{$server}} ) {
            push (@mountpts, $fsinfo->{$server}->{$mountpt}{mount});
        }
    }

    my $json_text = to_json(\@mountpts, { pretty => 0 });
    $json_text    =~ s/"/\\"/g; # needed for correct remotesshwrapper transfer

    my ($status_info) = remotewrapper_command( $server, $servers{$server}{serverconfig}{remotewrapper_folder} . "btrfs_${type}_status", $json_text );
    my $status_ref    = from_json( $status_info );

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

    my $json_text = to_json($data, { pretty => 0 });
    $json_text    =~ s/"/\\"/g; # needed for correct remotesshwrapper transfer

    my ( $feedback ) = remotewrapper_command( $server, $servers{$server}{serverconfig}{remotewrapper_folder} . 'btrfs_worker', $json_text );

    my $feedback_ref = from_json( $feedback );
    my $return_code = $feedback_ref->{'return_code'};
    my $return_msg  = $feedback_ref->{'return_msg'};

    return ($return_code, $return_msg);
}

1;
