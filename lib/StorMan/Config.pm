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
    %serverconfig
    get_serverconfig
    get_server_config_defaults
);

our $prefix = dirname( abs_path($0) );
our %servers;
our %serverconfig;
our $servername = `hostname -s`;
chomp $servername;

sub get_serverconfig {
    my ($prefix_arg) = @_;

    if ($prefix_arg) {
        $prefix     = $prefix_arg;
        $servername = 'bangtestserver' if $prefix_arg eq 't';    # Run test suite with specific server name
    }

    undef %servers;
    undef %serverconfig;
    $serverconfig{path_configs}            = "$prefix/etc";
    $serverconfig{config_defaults_servers} = "$serverconfig{path_configs}/defaults_servers.yaml";
    $serverconfig{path_serverconfig}       = "$serverconfig{path_configs}/servers";
    $serverconfig{build_version}           = _get_build_version();

    # get info about all backup servers
    my @serverconfigs = _find_configs( "*_defaults\.yaml", $serverconfig{path_serverconfig} );

    foreach my $serverconfigfile (@serverconfigs) {
        my $server = _split_server_configname($serverconfigfile);
        my ( $serverconfig, $confighelper ) = _read_server_configfile($server);

        $servers{$server} = {
            configfile   => $serverconfigfile,
            serverconfig => $serverconfig,
            confighelper => $confighelper,
        };
    }

    # copy info about localhost to separate hash for easier retrieval
    foreach my $key ( keys %{$servers{$servername}{serverconfig}} ) {
        $serverconfig{$key} = $servers{$servername}{serverconfig}->{$key};
    }

    # preprend full path where needed
    foreach my $key (qw( path_logs )) {
        $serverconfig{$key} = "$prefix/$serverconfig{$key}";
    }

    return 1;
}

sub get_server_config_defaults {
    my $defaults_server_file = $serverconfig{config_defaults_servers};
    my $settings;
    if ( _sanityfilecheck($defaults_server_file) ) {
        $settings = LoadFile($defaults_server_file);
    }

    return $settings;
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
    my $settings        = LoadFile( $serverconfig{config_defaults_servers} );
    $configfile{server} = "$serverconfig{path_serverconfig}/${server}_defaults.yaml";
    my $settingshelper  = _override_config( $settings, \%configfile, qw( server ) );

    return ( $settings, $settingshelper );
}

sub _override_config {
    my ( $settings, $configfile, @overrides ) = @_;

    my $settingshelper;
    foreach my $config_override (@overrides) {
        if ( _sanityfilecheck( $configfile->{$config_override} ) ) {

            my $settings_override = LoadFile( $configfile->{$config_override} );

            foreach my $key ( keys %{$settings_override} ) {
                $settingshelper->{$key} = $config_override;
                if ( defined $settings->{$key} && ($settings->{$key} eq $settings_override->{$key}) ) {
                    $settingshelper->{$key} = 'same';
                    $settingshelper->{warning} = 1;
                }
                $settings->{$key}       = $settings_override->{$key};
            }
        }
    }

    return ($settingshelper);
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

sub _get_build_version {
    my $tag;
    my $v = "0.0";
    my $git_cmd = `which git &> /dev/null`;
    chomp $git_cmd;

    if ( $git_cmd ){
        if ( $tag=`cd $prefix; $git_cmd describe --tags 2>/dev/null` ) {
            chomp $tag;
            $v="$tag";
        }
    }
    return $v;
}

1;
