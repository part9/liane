package Liane::DateTime;

use strict;
use warnings;

use Date::Parse;

# As wxPerls wx::DateTime is missing the GetTicks() 
# function we have to convert to ticks like this.
#
# Nstoring the whole DateTime object segfaults and is
# messy anyways, thus we want to use ticks in the first place.
#
# This method has been suggested by Dave Hayes of perl.wxperl.users
# at http://www.nntp.perl.org/group/perl.wxperl.users/2015/01/msg9392.html

# Converts Wx::DateTime to time ticks.
sub wxdt2tt {
    my $date =  shift;

    my $time_t = str2time($date->FormatDate() . ' ' . $date->FormatTime());
    
    return $time_t;
}

# Converts time ticks to Wx::DateTime
sub tt2wxdt {
    my $time_t = shift;
    
    # Surprisingly there is a dedicated 
    # constructor to do just what we want:
    my $date = Wx::DateTime->newFromTimeT( $time_t );

    return $date;
}

# Returns difference beetween time ticks
# in Year;Month format.
sub diff_ym {
    my ( $time_t_1, $time_t_2 ) = @_;
    
    #  0    1    2     3     4    5     6     7     8
    # ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    
    my @date_1 = localtime( $time_t_1 );
    my @date_2 = localtime( $time_t_2 );
    
    my $diff_y = $date_2[5] - $date_1[5];
    my $diff_m = $date_2[4] - $date_1[4];
    
    # If the difference beetween the months is
    # negative, the fella did not celebrate his
    # birthday this year!
    # FIXME: actually diff_m needs to be decremented
    # if diff_d is negative..
    if ( $diff_m < 0 ) {
        $diff_m = 12 + $diff_m;
        $diff_y--;
    }
    
    return $diff_y . ';' . $diff_m;   
}

# Converts ticks to dd.mm.yyyy .
sub date_dmy {
    my $time_t = shift;
    my @date   = localtime( $time_t );
    
    my $day   = $date[3];
    my $month = $date[4] + 1;
    my $year  = $date[5] + 1900;
    
    return sprintf( "%02d.%02d.%04d", $day, $month, $year );
}

1;
