package StorMan::Routes_Maint;

use 5.010;
use strict;
use warnings;
use Dancer ':syntax';
use Dancer::Plugin::Auth::Extensible;
use StorMan::Config;
use StorMan::BTRFS;

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

get '/balance_status' => require_role isg => sub {
    get_serverconfig('*');

    template 'maintenance-balance_status' => {
        balancestatus => get_btrfs_status("balance"),
        },{
        layout => 0 };
};

get '/scrub_status' => require_role isg => sub {
    get_serverconfig('*');

    template 'maintenance-scrub_status' => {
        scrubstatus => get_btrfs_status("scrub"),
        },{
        layout => 0 };
};

get '/btrfs_mount_info' => require_role isg => sub {
    get_serverconfig('*');
    my $mount = param('mount');
    my ($code, $msg) = btrfs_worker("filesystem","df", $mount);

    template 'maintenance-btrfs_mount_info' => {
        mount => $mount,
        df    => $msg,
    };
};

post '/events' => require_role isg => sub {
    get_serverconfig('*');
    my $tooltype  = param('tooltyp_arg');
    my $event     = param('event_arg');
    my $mount     = param('mount_arg');
    my $updatedby = session('logged_in_user');

    my ($return_code, $return_msg) = btrfs_worker($tooltype, $event, $mount);
    warning "$return_msg by $updatedby!";
};

1;
