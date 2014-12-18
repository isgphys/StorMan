package StorMan::Routes_Docs;

use 5.010;
use strict;
use warnings;
use Dancer ':syntax';
use StorMan::Config;

prefix '/docs';

get '/' => sub {
    redirect '/docs/Index.markdown';
};

get '/:file' => sub {
    my $file = "$prefix/docs/" . param('file');
    open my $MARKDOWN, '<', $file;
    my $markdown = do { local $/; <$MARKDOWN> };
    close $MARKDOWN;
    $markdown =~ s/\\/\\\\/g;    # escape backslashes
    $markdown =~ s/'/\\'/g;      # escape single quotes for JavaScript string
    $markdown =~ s/\n/\\n/g;     # stringify newlines (will be converted by JS)

    template 'documentation' => {
        section      => 'documentation',
        remotehost   => request->remote_host,
        webDancerEnv => config->{run_env},
        content      => $markdown,
    },{ layout       => 0 };
};

1;
