package StorMan::Routes_Btrfs;

use 5.010;
use strict;
use warnings;
use Dancer ':syntax';
use Dancer::Plugin::Auth::Extensible;
use StorMan::Config;
use StorMan::BTRFS;
use StorMan::Hosts;

my $msg = '';
my $err_code   = '';

prefix '/maint/btrfs';

get '/' => require_login sub {
    template 'maintenance-btrfs' => {
        section      => 'maintenance',
        servername   => $servername,
        perf_mon_url => $serverconfig{perf_mon_url},
    };
};

get '/balance_status' => require_role config->{admin_role} => sub {
    my $mount = param('mount') || "";
    get_serverconfig();

    template 'maintenance-balance_status' => {
        balancestatus => get_btrfs_status("balance", $mount),
        },{
        layout => 0 };
};

get '/scrub_status' => require_role config->{admin_role} => sub {
    get_serverconfig();

    template 'maintenance-scrub_status' => {
        scrubstatus => get_btrfs_status("scrub"),
        },{
        layout => 0 };
};

get '/snapshot_stats' => require_role config->{admin_role} => sub {
    get_serverconfig();

    template 'maintenance-snapshot_stats' => {
        snapshotstats => get_btrfs_status("snapshot"),
        },{
        layout => 0 };
};

get '/replace_status' => require_role config->{admin_role} => sub {
    get_serverconfig();

    template 'maintenance-replace_status' => {
        replacestatus => get_btrfs_status("replace"),
        },{
        layout => 0 };
};

get '/btrfs_fs-details' => require_role config->{admin_role} => sub {
    my $mount = param('mount') || "";
    template 'maintenance-btrfs_fs-details' => {
        section => 'maintenance',
        mount   => $mount,
    };
};

get '/btrfs_mount_info' => require_role config->{admin_role} => sub {
    get_serverconfig();
    my $mount        = param('mount');
    my ($code, $msg) = btrfs_worker("filesystem","df", $mount);

    template 'maintenance-btrfs_mount_info' => {
        servername   => $servername,
        mount        => $mount,
        df           => $msg,
        perf_mon_url => $serverconfig{perf_mon_url},
        },{
        layout => 0 };
};

get '/btrfs_device-list' => require_role config->{admin_role} => sub {
    get_serverconfig();
    my $mount        = param('mount') || "";
    my ($code, $msg) = btrfs_worker("filesystem","show", $mount);
    my $layout       = $mount  ? "0" : "main";

    template 'maintenance-btrfs_device-list' => {
        section => 'maintenance',
        mount   => $mount,
        fs      => $msg,
        },{
        layout  => $layout };
};

get '/btrfs_scrubstats' => require_role config->{admin_role} => sub {
    get_serverconfig();
    my $mount        = param('mount') || "";
    my ($code, $msg) = btrfs_worker("filesystem","show", $mount);
    my $layout       = $mount  ? "0" : "main";

    template 'maintenance-btrfs_scrubstats' => {
        section => 'maintenance',
        mount   => $mount,
        fs      => $msg,
        },{
        layout => $layout };
};

post '/events' => require_role config->{admin_role} => sub {
    get_serverconfig();
    my $tooltype  = param('tooltyp_arg');
    my $event     = param('event_arg');
    my $mount     = param('mount_arg');
    my $updatedby = session('logged_in_user');

    my ($return_code, $return_msg) = btrfs_worker($tooltype, $event, $mount);
    warning "$return_msg by $updatedby!";
};

1;
