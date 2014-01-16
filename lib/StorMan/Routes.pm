package StorMan::Routes;

use 5.010;
use strict;
use warnings;
use Dancer ':syntax';
use StorMan::Common;
use StorMan::Hosts;
use StorMan::Iscsi;
use StorMan::Routes_Docs;

prefix undef;

get '/' => sub {

    template 'dashboard.tt', {
    };
};

get '/fsinfo_report' => sub {

    template 'dashboard-fsinfo' => {
        fsinfo => get_fsinfo(),
        },{
        layout => 0 };
};

get '/iscsi_session_report' => sub {

    template 'dashboard-iscsi_sessions' => {
        sessioninfo => get_iscsi_sessions(),
        },{
        layout => 0 };
};

