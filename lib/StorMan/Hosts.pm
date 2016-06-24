package StorMan::Hosts;

use 5.010;
use strict;
use warnings;
use Dancer ':syntax';
use StorMan::Config;
use StorMan::Converter;
use Net::Ping;

use Exporter 'import';
our @EXPORT = qw(
    get_fsinfo
    get_quotareport
);

sub get_fsinfo {
    my %fsinfo;
    foreach my $server ( keys %servers ) {
        my @mounts;
        @mounts = remotewrapper_command( $server, $servers{$server}{serverconfig}{remotewrapper_folder} . 'bang_df' );

        foreach my $mount (@mounts) {
            $mount =~ qr{
                        ^(?<filesystem> [\/\w\d-]+)
                        \s+(?<fstyp> [\w\d]+)
                        \s+(?<blocks> [\d]+)
                        \s+(?<used> [\d]+)
                        \s+(?<available>[\d]+)
                        \s+(?<usedper> [\d]+)
                        .\s+(?<mountpt> [\/\w\d-]+)
            }x;

            $fsinfo{$server}{$+{mountpt}} = {
                filesystem => $+{filesystem},
                mount      => $+{mountpt},
                fstyp      => $+{fstyp},
                blocks     => num2human($+{blocks}*1024,1024),
                used       => num2human($+{used}*1024,1024),
                available  => num2human($+{available}*1024,1024),
                freediff   => "",
                rwstatus   => "",
                usrquota   => "",
                grpquota   => "",
                used_per   => $+{usedper},
                css_class  => check_fill_level($+{usedper}),
            };

        }

        @mounts = remotewrapper_command( $server, $servers{$server}{serverconfig}{remotewrapper_folder} . 'procmounts' ) ;
        foreach my $mount (@mounts) {
            $mount =~ qr{
            ^(?<device>[\/\w\d-]+)
            \s+(?<mountpt>[\/\w\d-]+)
            \s+(?<fstyp>[\w\d]+)
            \s+(?<mountopt>[\w\d\,\=\.\/]+)
            \s+(?<dump>[\d]+)
            \s+(?<pass>[\d]+)$
            }x;

            my $mountpt  = $+{mountpt}  || next;
            my $mountopt = $+{mountopt} || '';
            my $rwstatus = "check_red" if $mountopt =~ /ro/;
            my $usrquota = "hook" if ( $mountopt =~ /usrquota/ || $mountopt =~ /usrjquota/ );
            my $grpquota = "hook" if ( $mountopt =~ /grpquota/ || $mountopt =~ /grpjquota/ );

            $fsinfo{$server}{$mountpt}{rwstatus} = $rwstatus;
            $fsinfo{$server}{$mountpt}{usrquota} = $usrquota;
            $fsinfo{$server}{$mountpt}{grpquota} = $grpquota;
        }

        if ($server eq "phd-bkp-gw") {
            @mounts = remotewrapper_command( $server, $servers{$server}{serverconfig}{remotewrapper_folder} . 'bang_di' ) ;
            foreach my $mount (@mounts) {
                $mount =~ qr{
                ^(?<filesystem> [\/\w\d-]+)
                \s+(?<fstyp>[\w\d]+)
                \s+(?<blocks>[\d]+)
                \s+(?<used>[\d]+)
                \s+(?<available>[\d]+)
                \s+(?<free>[\d]+)
                \s+(?<usedper>[\d]+)
                .\s+(?<mountpt>[\/\w\d-]+)
                }x;

                my $freediff    = $+{free} - $+{available};
                my $freediffper = 100 / $+{free} * $freediff;

                $fsinfo{$server}{$+{mountpt}}{freediff} = ( $freediffper > 10 ) ? num2human($freediff*1024,1024) : "" ;
            }

        }

    }

    return \%fsinfo;
}

sub get_quotareport {
    my ($server, $mount, $option) = @_;

    return unless $option =~ /-[ug]$/;

    my $data = {
        "mount"  => $mount,
        "option" => $option,
    };

    my $json_text = to_json($data, { pretty => 0});
    $json_text    =~ s/"/\\"/g; # needed for correct remotesshwrapper transfer

    my ( $feedback ) = remotewrapper_command( $server, $servers{$server}{serverconfig}{remotewrapper_folder} . 'quotareport', $json_text );

    my $feedback_ref = from_json( $feedback );
    my $return_code = $feedback_ref->{'return_code'};
    my $return_msg  = $feedback_ref->{'return_msg'};

    return ($return_code, $return_msg);

}

sub check_fill_level {
    my ($level) = @_;
    my $css_class = '';

    if ( $level > 98 ) {
        $css_class = "alert_red";
    } elsif ( $level > 90 ) {
        $css_class = "alert_orange";
    } elsif ( $level > 80 ) {
        $css_class = "alert_yellow";
    }

    return $css_class;
}

1;
