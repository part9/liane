package Liane::Wx::App;

use strict;
use warnings;

use Liane::Wx::Main;

our @ISA = 'Wx::App';

sub OnInit {
    my $self = shift;
    
    my $main = Liane::Wx::Main->new;
    $main->Show;
    
    return 1;
}

1;

