package StorMan::Routes_Maint;

use 5.010;
use strict;
use warnings;
use Dancer ':syntax';
use Dancer::Plugin::Auth::Extensible;
use StorMan::Config;
use StorMan::Hosts;

my $msg = '';
my $err_code   = '';

prefix '/maint';

get '/quota' => require_login sub {
    my $mount  = param('mount') || "/export/groupdata";
    my $server = param('server') || "phd-san-gw2";
    my $option = param('option') || "-g";

    template 'maintenance-quota' => {
        section => 'maintenance',
        server  => $server,
        mount   => $mount,
        option  => $option,
    };
};

get '/quota_report' => require_role config->{admin_role} => sub {
    get_serverconfig('*');
    my $mount  = param('mount') || "/export/groupdata";
    my $server = param('server') || "phd-san-gw2";
    my $option = param('option') || "-g";
    my ($code, $msg) = get_quotareport($server, $mount, $option);

    template 'maintenance-quota_report' => {
        mount       => $mount,
        quotareport => $msg,
        },{
        layout => 0 };
};

1;
