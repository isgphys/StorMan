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
        balancestatus => get_balance_status(),
        },{
        layout => 0 };
};

1;
