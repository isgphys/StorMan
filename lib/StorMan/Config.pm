package StorMan::Config;

use 5.010;
use strict;
use warnings;
use Cwd qw( abs_path );
use File::Basename;
use File::Find::Rule;
use POSIX qw( strftime );
use YAML::Tiny qw( LoadFile DumpFile );

use Data::Dumper;

use Exporter 'import';
our @EXPORT = qw(
    $prefix
    $servername
    %servers
    $globalconfig
    %serverconfig
    get_globalconfig
    get_serverconfig
);

our $prefix     = dirname( abs_path($0) );
our %servers;
our %global;
our $globalconfig;
our %serverconfig;
our $servername = `hostname -s`;
chomp $servername;

sub get_globalconfig {
    my ($prefix_arg) = @_;

    undef $globalconfig;
    $prefix        = $prefix_arg if $prefix_arg;
    $global{path_configs}      = "$prefix/etc";
    $global{config_defaults}   = "$global{path_configs}/defaults.yaml";
    $global{path_serverconfig} = "$global{path_configs}/servers";

    $globalconfig = LoadFile( $global{config_defaults} );

    # preprend full path where needed
    foreach my $key (qw( path_serverconfig path_logs )) {
        $globalconfig->{$key} = "$global{path_configs}/$globalconfig->{$key}";
    }

    return 1;
}

sub get_serverconfig {
    my ($server) = @_;
    $server ||= '*';

    undef %servers;
    undef %serverconfig;
    # get info about all servers
    my @serverconfigs = _find_configs( "$server\_defaults\.yaml", $global{path_serverconfig} );

    foreach my $serverconfigfile (@serverconfigs) {
        my ($server) = _split_server_configname($serverconfigfile);
        my ($serverconfig) = _read_server_configfile($server);

        $servers{"$server"} = {
            'configfile'   => $serverconfigfile,
            'serverconfig' => $serverconfig,
        };
    }

    # copy info about localhost to separate hash for easier retrieval
    foreach my $key ( keys %{ $servers{$servername}{serverconfig} } ) {
        $serverconfig{$key} = $servers{$servername}{serverconfig}->{$key};
    }

    return 1;
}

sub _find_configs {
    my ($query, $searchpath) = @_;

    my @files;
    my $ffr_obj = File::Find::Rule->file()
    ->name($query)
    ->relative
    ->maxdepth(1)
    ->start($searchpath);

    while ( my $file = $ffr_obj->match() ) {
        push( @files, $file );
    }

    return @files;
}

sub _split_server_configname {
    my ($configfile) = @_;

    my ($server) = $configfile =~ /^([\w\d-]+)_defaults\.yaml/;

    return ($server);
}

sub _read_server_configfile {
    my ($server) = @_;

    my %configfile;
    my $settings        = LoadFile( "$global{path_serverconfig}/${server}_defaults.yaml" );
    $configfile{server} = "$global{path_serverconfig}/${server}_defaults.yaml";

    return ($settings);
}

sub _sanityfilecheck {
    my ($file) = @_;

    if ( !-f "$file" ) {
        # logit("000000","localhost","INTERNAL", "$file NOT available");
        return 0;    # FIXME CLI should check return value
    } else {
        return 1;
    }
}

1;
