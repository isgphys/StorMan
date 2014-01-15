package StorMan::Routes;

use 5.010;
use strict;
use warnings;
use Dancer ':syntax';
use StorMan::Common;
use StorMan::Hosts;

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


