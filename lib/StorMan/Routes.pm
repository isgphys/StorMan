package StorMan::Routes;

use 5.010;
use strict;
use warnings;
use Dancer ':syntax';
use Dancer::Plugin::Auth::Extensible;
use Dancer::Plugin::Auth::Extensible::Provider::LDAPphys;
use StorMan::Common;
use StorMan::Hosts;
use StorMan::Iscsi;
use StorMan::Routes_Docs;

prefix undef;

get '/' => require_role isg=> sub {

    template 'dashboard.tt', {
    };
};

get '/fsinfo_report' => require_role isg => sub {

    template 'dashboard-fsinfo' => {
        fsinfo => get_fsinfo(),
        },{
        layout => 0 };
};

get '/iscsi_session_report' => require_role isg => sub {

    template 'dashboard-iscsi_sessions' => {
        sessioninfo => get_iscsi_sessions(),
        },{
        layout => 0 };
};

get '/login' => sub {
    session 'return_url' => params->{return_url} || '/';

    template 'login' => {
    };
};

post '/login' => sub {
    if ( authenticate_user(param('username'), param('password')) ) {
        session logged_in_user       => param('username');
        session logged_in_fullname   => Dancer::Plugin::Auth::Extensible::Provider::LDAPphys::_user_fullname(param('username'));
        session logged_in_roles      => Dancer::Plugin::Auth::Extensible::Provider::LDAPphys::get_user_roles('',param('username'));
        session logged_in_admin      => 'isg' ~~ session('logged_in_roles') || '0';
        session logged_in_user_realm => 'ldap';

        if ( !session('logged_in_admin') && session('return_url') eq '/' ) {
            redirect '/restore';
        } else {
            redirect session('return_url');
        }

        } else {
            debug("Login failed - password incorrect for " . param('username'));
            redirect '/';
    };
};

get '/login/denied' => sub {
    template 'denied' => {
    };
};

get '/logout' => sub {
    session->destroy;
    return redirect '/';
};

1;
