package Liane::DB::Profile;

use strict;
use warnings;
use utf8;

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my $self = {
        GENERAL => {
            'name'       => '',
            'age'        => '',
            'date'       => '',
            'identifier' => '',
            'situation'  => '',
        },
        UTTERANCES => {
            'total'      => 0,
            'analyzable' => 0,
        },
        WORDCLASSES => {
            'noun'             => 0,
            'article'          => 0,
            'adjective'        => 0,
            'pronoun_personal' => 0,
            'pronoun_other'    => 0,
            
            'combination_ar_no'    => 0,
            'combination_ad_no'    => 0,
            'combination_ar_ad_no' => 0,
            
            'verb'      => 0,
            'auxiliary' => 0,
            'modal'     => 0,
            'copular'   => 0,
            
            'adverb'      => 0,
            'preposition' => 0,
            'conjunction' => 0,            
        },
        STRUCTURES => {
            'two_all'     => 0,
            'two_no_verb' => 0,
            'two_inf'     => 0,
            
            'more_all'       => 0,
            'more_inf'       => 0,
            'more_vtwo_conj' => 0,
            'more_vtwo_aux'  => 0,
            'more_other'     => 0,
            
            'combination' => 0,
        },
        VERBFLECTION_PRESENT => {
            'inf'        => 0,
            'inf_rel'    => 0,            
            'e'          => 0,
            'e_correct'  => 0,            
            'o'          => 0,
            'o_correct'  => 0,           
            'st'         => 0,
            'st_correct' => 0,
            'en'         => 0,
            'en_correct' => 0,                   
            't'          => 0,
            't_correct'  => 0,
        },     
        VERBFLECTION_PAST_PARTICIPLE => {
            'no_change_en'         => 0,
            'no_change_en_correct' =>0,
            'change_en'            => 0,
            'change_en_correct'    => 0,
            'no_change_t'          => 0,
            'no_change_t_correct'  => 0,
        },
        CASE_AGREEMENT => {
            'acc_acc'         => 0,
            'acc_acc_correct' => 0,
            'acc_nom'         => 0,  
            'ac_nom_correct'  => 0,        
            'dat_dat'         => 0,
            'dat_dat_correct' => 0,
            'dat_nom'         => 0,
            'dat_nom_correct' => 0,
            'dat_acc'         => 0,
            'dat_acc_correct' => 0,
        },
        ELISIONS => {
            'subject'     => 0,
            'article'     => 0,
            'verb'        => 0,
            'copular'     => 0,
            'auxiliary'   => 0,
            'preposition' => 0,
        },
        SVI => {
            'question'               => 0,
            'question_correct'       => 0,
            'topicalization'         => 0,
            'topicalization_correct' => 0,
        },
    };
    
    bless ( $self, $proto );
    return $self;
}
######################################################################

# Getters / Setters

sub general {
    my $self = shift;
    if( @_ ) { $self->{GENERAL} = shift }
    return $self->{GENERAL};
}

sub utterances {
    my $self = shift;
    if( @_ ) { $self->{UTTERANCES} = shift }
    return $self->{UTTERANCES};
}

sub wordclasses {
    my $self = shift;
    if( @_ ) { $self->{WORDCLASSES} = shift }
    return $self->{WORDCLASSES};
}

sub structures {
    my $self = shift;
    if( @_ ) { $self->{STRUCTURES} = shift }
    return $self->{STRUCTURES};
}

sub verbflection_present {
    my $self = shift;
    if( @_ ) { $self->{VERBFLECTION_PRESENT} = shift }
    return $self->{VERBFLECTION_PRESENT};
}

sub verbflection_past_participle {
    my $self = shift;
    if( @_ ) { $self->{VERBFLECTION_PAST_PARTICIPLE} = shift }
    return $self->{VERBFLECTION_PAST_PARTICIPLE};
}

sub case_agreement {
    my $self = shift;
    if( @_ ) { $self->{CASE_AGREEMENT} = shift }
    return $self->{CASE_AGREEMENT};
}

sub elisions {
    my $self = shift;
    if( @_ ) { $self->{ELISIONS} = shift }
    return $self->{ELISIONS};
}

sub svi {
    my $self = shift;
    if( @_ ) { $self->{SVI} = shift }
    return $self->{SVI};
}

1;
