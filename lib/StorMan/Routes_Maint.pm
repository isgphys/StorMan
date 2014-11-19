package StorMan::Routes_Maint;

use 5.010;
use strict;
use warnings;
use Dancer ':syntax';
use Dancer::Plugin::Auth::Extensible;
use StorMan::Config;
use StorMan::BTRFS;
use StorMan::Hosts;

prefix '/maint';

get '/iscsi' => require_login sub {
    template 'maintenance-iscsi' => {
        section      => 'maintenance',
    };
};

get '/btrfs' => require_login sub {
    template 'maintenance-btrfs' => {
        section      => 'maintenance',
    };
};

get '/balance_status' => require_role config->{admin_role} => sub {
    get_serverconfig('*');

    template 'maintenance-balance_status' => {
        balancestatus => get_btrfs_status("balance"),
        },{
        layout => 0 };
};

get '/scrub_status' => require_role config->{admin_role} => sub {
    get_serverconfig('*');

    template 'maintenance-scrub_status' => {
        scrubstatus => get_btrfs_status("scrub"),
        },{
        layout => 0 };
};

get '/snapshot_stats' => require_role config->{admin_role} => sub {
    get_serverconfig('*');

    template 'maintenance-snapshot_stats' => {
        snapshotstats => get_btrfs_status("snapshot"),
        },{
        layout => 0 };
};

get '/btrfs_fs-details' => require_role config->{admin_role} => sub {
    my $mount = param('mount') || "";
    template 'maintenance-btrfs_fs-details' => {
        section      => 'maintenance',
        mount => $mount,
    };
};

get '/quota' => require_login sub {
    template 'maintenance-quota' => {
        section      => 'maintenance',
    };
};

get '/quota_report' => require_role config->{admin_role} => sub {
    get_serverconfig('*');
    my $mount = param('mount') || "/export/groupdata";
    my $server = param('server') || "phd-san-gw2";
    my ($code, $msg) = get_quotareport($server, $mount, "-g");

    template 'maintenance-quota_report' => {
        mount       => $mount,
        quotareport => $msg,
        },{
        layout => 0 };
};

get '/btrfs_mount_info' => require_role config->{admin_role} => sub {
    get_serverconfig('*');
    my $mount = param('mount');
    my ($code, $msg) = btrfs_worker("filesystem","df", $mount);

    template 'maintenance-btrfs_mount_info' => {
        mount => $mount,
        df    => $msg,
        },{
        layout => 0 };
};

get '/btrfs_device-list' => require_role config->{admin_role} => sub {
    get_serverconfig('*');
    my $mount = param('mount') || "";
    my ($code, $msg) = btrfs_worker("filesystem","show", $mount);
    my $layout = $mount  ? "0" : "main";

    template 'maintenance-btrfs_device-list' => {
        section => 'maintenance',
        mount   => $mount,
        fs      => $msg,
        },{
        layout => $layout };
};

post '/events' => require_role config->{admin_role} => sub {
    get_serverconfig('*');
    my $tooltype  = param('tooltyp_arg');
    my $event     = param('event_arg');
    my $mount     = param('mount_arg');
    my $updatedby = session('logged_in_user');

    my ($return_code, $return_msg) = btrfs_worker($tooltype, $event, $mount);
    warning "$return_msg by $updatedby!";
};

1;
