package Liane::DB::Utterance;

use strict;
use warnings;

use Liane::DB::Analysis;

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my $self  = {
        SPEAKER  => '',
        TEXT     => '',
        ANALYSIS => Liane::DB::Analysis->new,
    };
    
    bless( $self, $class );    
    return $self;
}

######################################################################
# Getters / Setters

sub speaker {
    my $self = shift;
    if( @_ ) { $self->{SPEAKER} = shift }
    return $self->{SPEAKER};
}

sub text {
    my $self = shift;
    if( @_ ) { $self->{TEXT} = shift }
    return $self->{TEXT};
}

sub analysis {
    my $self = shift;
    if( @_ ) { $self->{ANALYSIS} = shift }    
    return $self->{ANALYSIS};
}

1;
