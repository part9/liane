package Liane::DB::Analysis;

use strict;
use warnings;

use Liane::DB::Word;

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my $self = {
        WORDS_CREATED       => 0,
        WORDS               => [],
        STRUCTURE           => 500,
        CASE_ACC_ACC        => 0,
        CASE_ACC_NOM        => 0,
        CASE_DAT_DAT        => 0,
        CASE_DAT_NOM        => 0,
        CASE_DAT_ACC        => 0,
        ELISION_SUBJECT     => 0,
        ELISION_ARTICLE     => 0,
        ELISION_VERB        => 0,
        ELISION_COPULAR     => 0,
        ELISION_AUXILIARY   => 0,
        ELISION_PREPOSITION => 0,
        SVI_USED            => 0,
        SVI_CONTEXT         => 810,
        SVI_CORRECT         => 821,
    };
    
    bless( $self, $class );
    return $self;
}

sub clone {
    my $self = shift;
    my $copy = {
        WORDS_CREATED       => $self->{WORDS_CREATED},
        WORDS               => [],
        STRUCTURE           => $self->{STRUCTURE},
        CASE_ACC_ACC        => $self->{CASE_ACC_ACC},
        CASE_ACC_NOM        => $self->{CASE_ACC_NOM},
        CASE_DAT_DAT        => $self->{CASE_DAT_DAT},
        CASE_DAT_NOM        => $self->{CASE_DAT_NOM},
        CASE_DAT_ACC        => $self->{CASE_DAT_ACC},
        ELISION_SUBJECT     => $self->{ELISION_SUBJECT},
        ELISION_ARTICLE     => $self->{ELISION_ARTICLE},
        ELISION_VERB        => $self->{ELISION_VERB},
        ELISION_COPULAR     => $self->{ELISION_COPULAR},
        ELISION_AUXILIARY   => $self->{ELISION_AUXILIARY},
        ELISION_PREPOSITION => $self->{ELISION_PREPOSITION},
        SVI_USED            => $self->{SVI_USED},
        SVI_CONTEXT         => $self->{SVI_CONTEXT},
        SVI_CORRECT         => $self->{SVI_CORRECT},

    };
            
    # And more love for the words.
    for ( my $i = 0; $i <  scalar( @{ $self->{WORDS} } ); $i++ ) {
        $copy->{WORDS}->[$i] = Liane::DB::Word->new;
        
        $copy->{WORDS}->[$i]->text( $self->{WORDS}->[$i]->text );
        $copy->{WORDS}->[$i]->wordclass( $self->{WORDS}->[$i]->wordclass );
        $copy->{WORDS}->[$i]->number( $self->{WORDS}->[$i]->number );
        $copy->{WORDS}->[$i]->case( $self->{WORDS}->[$i]->case );
        $copy->{WORDS}->[$i]->gender( $self->{WORDS}->[$i]->gender );
        $copy->{WORDS}->[$i]->tense( $self->{WORDS}->[$i]->tense );
        $copy->{WORDS}->[$i]->person( $self->{WORDS}->[$i]->person );
        $copy->{WORDS}->[$i]->sv_agreement( $self->{WORDS}->[$i]->sv_agreement );
        $copy->{WORDS}->[$i]->verbmarker( $self->{WORDS}->[$i]->verbmarker );
    }
    
    bless( $copy, ref( $self ) );
    return $copy;
}

######################################################################
# Getters / Setters

sub words_created {
    my $self = shift;
    if( @_ ) { $self->{WORDS_CREATED} = shift }
    return $self->{WORDS_CREATED};
}


sub words {
    my $self = shift;
    return $self->{WORDS};
}

sub structure {
    my $self = shift;
    if( @_ ) { $self->{STRUCTURE} = shift }
    return $self->{STRUCTURE};
}

sub case_acc_acc {
    my $self = shift;
    if( @_ ) { $self->{CASE_ACC_ACC} = shift }
    return $self->{CASE_ACC_ACC};
}

sub case_acc_nom {
    my $self = shift;
    if( @_ ) { $self->{CASE_ACC_NOM} = shift }
    return $self->{CASE_ACC_NOM};
}

sub case_dat_dat {
    my $self = shift;
    if( @_ ) { $self->{CASE_DAT_DAT} = shift }
    return $self->{CASE_DAT_DAT};
}

sub case_dat_nom {
    my $self = shift;
    if( @_ ) { $self->{CASE_DAT_NOM} = shift }
    return $self->{CASE_DAT_NOM};
}

sub case_dat_acc {
    my $self = shift;
    if( @_ ) { $self->{CASE_DAT_ACC} = shift }
    return $self->{CASE_DAT_ACC};
}

sub elision_subject {
    my $self = shift;
    if( @_ ) { $self->{ELISION_SUBJECT} = shift }
    return $self->{ELISION_SUBJECT};
}

sub elision_article {
    my $self = shift;
    if( @_ ) { $self->{ELISION_ARTICLE} = shift }
    return $self->{ELISION_ARTICLE};
}

sub elision_verb {
    my $self = shift;
    if( @_ ) { $self->{ELISION_VERB} = shift }
    return $self->{ELISION_VERB};
}

sub elision_copular {
    my $self = shift;
    if( @_ ) { $self->{ELISION_COPULAR} = shift }
    return $self->{ELISION_COPULAR};
}

sub elision_auxiliary {
    my $self = shift;
    if( @_ ) { $self->{ELISION_AUXILIARY} = shift }
    return $self->{ELISION_AUXILIARY};
}

sub elision_preposition {
    my $self = shift;
    if( @_ ) { $self->{ELISION_PREPOSITION} = shift }
    return $self->{ELISION_PREPOSITION};
}

sub svi_used {
    my $self = shift;
    if( @_ ) { $self->{SVI_USED} = shift }
    return $self->{SVI_USED};
}

sub svi_context {
    my $self = shift;
    if( @_ ) { $self->{SVI_CONTEXT} = shift }
    return $self->{SVI_CONTEXT};
}

sub svi_correct {
    my $self = shift;
    if( @_ ) { $self->{SVI_CORRECT} = shift }
    return $self->{SVI_CORRECT};
}
######################################################################
# Instance methods

# Parse $text into single words and
# append each on to the WORDS array as
# Liane::DB::Word item.
sub create_words {
    my $self = shift;
    my $text = shift;   
    
    # This does the trick of removing punctuation
    # characters from the string. Amazing use
    # of regexp.
    $text     =~ s/[\.\,\?\!]//g;    
    
    my @words = split( / /, $text );
    my $word;
    my $i     = 0;
    
    # Array should be empty.. but as
    # we are simply overwriting the list
    # elements in the next step this could
    # be a nice precaution. E.g. if
    # this method is called on an utterance
    # that has had its words created already.
    undef @{ $self->words };
    
    foreach $word ( @words ) {
        $self->words->[$i] = Liane::DB::Word->new;
        $self->words->[$i]->text( $word );
        $i++;
    }
    
    return $i;
}

1;
