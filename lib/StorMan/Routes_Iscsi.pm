package StorMan::Routes_Iscsi;

use 5.010;
use strict;
use warnings;
use Dancer ':syntax';
use Dancer::Plugin::Auth::Extensible;
use StorMan::Config;
use StorMan::Iscsi;

my $msg = '';
my $err_code   = '';

prefix '/maint/iscsi';

get '/iscsi_nodes_report' => require_role config->{admin_role} => sub {
    get_serverconfig('*');

    template 'dashboard-iscsi_nodes' => {
        nodesinfo => get_iscsi_nodes(),
        servers   => \%servers,
        },{
        layout => 0 };
};

get '/?:errcode?' => require_role config->{admin_role} => sub {
    my $errcode  = param('errcode') || '';
    my $errmsg = '';

    get_serverconfig('*');

    if ( $errcode eq "1" ){
        $errmsg = $msg;
    }
    template 'maintenance-iscsi' => {
        section => 'maintenance',
        errmsg  => $errmsg,
        servers => \%servers,
    };
};

post '/discovery' => require_role config->{admin_role} => sub {
    my $targetIP = param('discover');
    my $server = param('server');

    info("iSCSI-Discovery $targetIP on $server by ". session('logged_in_user'));

    my ($err_code, $return_msg) = discover_new_target( $targetIP, $server );
    $msg = $return_msg;

    redirect "/maint/iscsi/$err_code";
};

1;
