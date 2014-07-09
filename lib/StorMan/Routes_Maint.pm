package StorMan::Routes_Maint;

use 5.010;
use strict;
use warnings;
use Dancer ':syntax';
use Dancer::Plugin::Auth::Extensible;
use StorMan::Config;

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

1;
