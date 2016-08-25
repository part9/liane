package Liane::DB::Student;

use strict;
use warnings;

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my $self  = {
        NAME        => '',
        BIRTHDATE   => 0,  
        PHONENUMBER => '',        
        INSTITUTION => '',        
        NOTES       => '',
    };
    
    bless( $self, $class );
    
    return $self;
}

######################################################################
# Interface Methods

sub name {
    my $self = shift;
    if( @_ ) { $self->{NAME} = shift }
    return $self->{NAME};
}

sub birthdate {
    my $self = shift;
    if( @_ ) { $self->{BIRTHDATE} = shift }
    return $self->{BIRTHDATE};
}

sub phonenumber {
    my $self = shift;
    if( @_ ) { $self->{PHONENUMBER} = shift }
    return $self->{PHONENUMBER};
}

sub institution {
    my $self = shift;
    if( @_ ) { $self->{INSTITUTION} = shift }
    return $self->{INSTITUTION};
}

sub notes {
    my $self = shift;
    if( @_ ) { $self->{NOTES} = shift }
    return $self->{NOTES};
}
1;
