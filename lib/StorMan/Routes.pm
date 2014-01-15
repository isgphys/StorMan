package StorMan::Routes;
use Dancer ':syntax';

get '/' => sub {
    template 'dashboard.tt', {
        };
        };
