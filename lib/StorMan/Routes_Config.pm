package StorMan::Routes_Config;

use 5.010;
use strict;
use warnings;
use POSIX qw( strftime );
use Dancer ':syntax';
use Dancer::Plugin::Auth::Extensible;
use StorMan::Config;

prefix '/config';

get '/defaults' => require_role config->{admin_role} => sub {
    get_serverconfig();

    template 'configs-defaults' => {
        section        => 'configs',
        servername     => $servername,
        servers        => \%servers,
        remotehost     => request->remote_host,
        webDancerEnv   => config->{run_env},
        serverconfig   => \%serverconfig,
        serverdefaults => get_server_config_defaults(),
        servername     => $servername,
        prefix_path    => $prefix,
    };
};

get '/allservers' => require_role config->{admin_role} => sub {
    get_serverconfig();

    template 'configs-servers' => {
        section      => 'configs',
        servername   => $servername,
        servers      => \%servers,
        remotehost   => request->remote_host,
        webDancerEnv => config->{run_env},
    };
};

1;
