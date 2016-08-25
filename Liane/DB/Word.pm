package Liane::DB::Word;

use strict;
use warnings;

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my $self = {
        TEXT         => '',
        WORDCLASS    => 200,
        NUMBER       => 300,
        CASE         => 310,
        GENDER       => 320,
        TENSE        => 330,
        PERSON       => 340,
        SV_AGREEMENT => 411,
        VERBMARKER   => 400,
    };
    
    bless( $self, $class );
    return $self;
}

######################################################################
# Getters / Setters

# The actual word.
sub text {
    my $self = shift;
    if( @_ ) { $self->{TEXT} = shift }
    return $self->{TEXT};
}

# Wortart
sub wordclass {
    my $self = shift;
    if( @_ ) { $self->{WORDCLASS} = shift }
    return $self->{WORDCLASS};
}

# Numerus
sub number {
    my $self = shift;
    if( @_ ) { $self->{NUMBER} = shift }
    return $self->{NUMBER};
}

# Kasus
sub case {
    my $self = shift;
    if( @_ ) { $self->{CASE} = shift }
    return $self->{CASE};
}

# Genus
sub gender {
    my $self = shift;
    if( @_ ) { $self->{GENDER} = shift }
    return $self->{GENDER};
}

# Tempus
sub tense {
    my $self = shift;
    if( @_ ) { $self->{TENSE} = shift }
    return $self->{TENSE};
}

# Person
sub person {
    my $self = shift;
    if( @_ ) { $self->{PERSON} = shift }
    return $self->{PERSON};
}

# SV-Kongruenz
sub sv_agreement {
    my $self = shift;
    if( @_ ) { $self->{SV_AGREEMENT} = shift }
    return $self->{SV_AGREEMENT};
}

# (Verb-)Markierung
sub verbmarker {
    my $self = shift;
    if( @_ ) { $self->{VERBMARKER} = shift }
    return $self->{VERBMARKER};
}

1;
