package StorMan::Routes;

use 5.010;
use strict;
use warnings;
use Dancer ':syntax';
use Dancer::Plugin::Auth::Extensible;
use StorMan::Config;
use StorMan::Hosts;
use StorMan::Routes_Docs;
use StorMan::Routes_Config;
use StorMan::Routes_Maint;
use StorMan::Routes_Btrfs;
use StorMan::Routes_Iscsi;


prefix undef;

get '/' => require_role config->{admin_role} => sub {
    get_serverconfig();

    template 'dashboard.tt', {
        section => 'dashboard',
        servername   => $servername,
        perf_mon_url => $serverconfig{perf_mon_url},
    };
};

get '/fsinfo_report/?:servergroup?' => require_role config->{admin_role} => sub {
    my $servergroup = param("servergroup") || "";
    get_serverconfig();

    template 'dashboard-fsinfo' => {
        fsinfo  => get_fsinfo($servergroup),
        servergroup   => $servergroup,
        servers => \%servers,
        },{
        layout => 0 };
};

get '/perf_mon' => require_role config->{admin_role} => sub {
    get_serverconfig();

    template 'perf-mon' => {
        servername   => $servername,
        perf_mon_url => $serverconfig{perf_mon_url},
        },{
        layout => 0 };
};

get '/login' => sub {
    session 'return_url' => params->{return_url} || '/';

    template 'login' => {
    };
};

post '/login' => sub {
    my ($authenticated, $realm) = authenticate_user( params->{username}, params->{password} );

    if ( $authenticated ) {
        session logged_in_user_realm => $realm;
        session logged_in_user       => param('username');
        session logged_in_fullname   => logged_in_user()->{'cn'};
        session logged_in_admin      => user_has_role( param('username'), config->{admin_role} ) ? 1 : 0;

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
