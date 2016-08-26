package Liane::Profile;

use strict;
use warnings;
use utf8;

use Carp;

use Liane::DB::Profile;

use Liane::PDF;

######################################################################
# Profile Creation

sub create_profile {
    my ($self, $student, $transcript ) = @_;
    
    my $profile = Liane::DB::Profile->new;

    # General
    #
    eval {
        $profile->general->{name} = $student->name;
        $profile->general->{age} = Liane::DateTime::diff_ym( $student->birthdate, $transcript->date );
        $profile->general->{date} = Liane::DateTime::date_dmy( $transcript->date );
        $profile->general->{identifier} = uc( substr( $student->name, 0, 3 ) ) . ' ' . $profile->general->{age};
        $profile->general->{situation} = $transcript->situation;
    };
    confess $@ if $@;
    
    # Utterances
    #
    eval {
        $profile->utterances->{total} = count_utterances( $transcript );
        $profile->utterances->{total_analyzable} = count_utterances( $transcript, 1 );
    };
    confess $@ if $@; 

    # Wordclasses
    #
    eval {
        $profile->wordclasses->{noun} = &do_word_magic( $transcript, 'wordclass', 210 );
        $profile->wordclasses->{article} = &do_word_magic( $transcript, 'wordclass', 211 );
        $profile->wordclasses->{adjective} = &do_word_magic( $transcript, 'wordclass', 212 );
        $profile->wordclasses->{pronoun_personal} = &do_word_magic( $transcript, 'wordclass', 213 );
        $profile->wordclasses->{pronoun_other} = &do_word_magic( $transcript, 'wordclass', 214 );
        
        $profile->wordclasses->{verb} = &do_word_magic( $transcript, 'wordclass', 220 );
        $profile->wordclasses->{auxiliary} = &do_word_magic( $transcript, 'wordclass', 221 );
        $profile->wordclasses->{modal} = &do_word_magic( $transcript, 'wordclass', 222 );
        $profile->wordclasses->{copular} = &do_word_magic( $transcript, 'wordclass', 223 );
        
        $profile->wordclasses->{adverb} = &do_word_magic( $transcript, 'wordclass', 230 );
        $profile->wordclasses->{preposition} = &do_word_magic( $transcript, 'wordclass', 231 );
        $profile->wordclasses->{conjunction} = &do_word_magic( $transcript, 'wordclass', 232 );
    };
    confess $@ if $@;
    
    # Wordclass combinations
    #
    eval {
        $profile->wordclasses->{combination_ar_no} = &do_word_combination_magic(
            $transcript, 'wordclass', 211, 210 );
        $profile->wordclasses->{combination_ad_no} = &do_word_combination_magic(
            $transcript, 'wordclass', 212, 210 );
        $profile->wordclasses->{combination_ar_ad_no} = &do_word_combination_magic(
            $transcript, 'wordclass', 211, 212, 210 );
        # Adjectiv noun combinations are counted twice (in ad_no and ar_ad_no), so
        # we substract the occurences in ar_ad_no.
        $profile->wordclasses->{combination_ad_no} -= $profile->wordclasses->{combination_ar_ad_no};
        
    };
    confess $@ if $@;

    # Sentence Structure
    #
    eval {
        $profile->structures->{two_no_verb} = &do_analysis_magic( $transcript, 'structure', 510 );
        $profile->structures->{two_inf} = &do_analysis_magic( $transcript, 'structure', 511 );
        $profile->structures->{two_all} = $profile->structures->{two_no_verb} +
                                          $profile->structures->{two_inf};
        
        $profile->structures->{more_inf} = &do_analysis_magic( $transcript, 'structure', 520 );
        $profile->structures->{more_vtwo_conj} = &do_analysis_magic( $transcript, 'structure', 521 );
        $profile->structures->{more_vtwo_aux} = &do_analysis_magic( $transcript, 'structure', 522 );
        $profile->structures->{more_other} = &do_analysis_magic( $transcript, 'structure', 523 );
        $profile->structures->{more_all} = $profile->structures->{more_inf} +
                                           $profile->structures->{more_vtwo_conj} +
                                           $profile->structures->{more_vtwo_aux} +
                                           $profile->structures->{more_other};
            
        $profile->structures->{combination} = &do_analysis_magic( $transcript, 'structure', 530 );
    };
    confess $@ if $@;
    
    # Verbflection present
    # (Do word magic returns absolute values.)
    #
    eval {
        $profile->verbflection_present->{inf} = &do_word_magic( $transcript, 'verbmarker', 420 );
        # inf_rel is the relative prevalence of infitive use
        # among all present tense verbs (present: tense = 331).
        $profile->verbflection_present->{inf_rel} = calc_percentage(
            $profile->verbflection_present->{inf},
            &do_word_magic( $transcript, 'tense', 331 ) );
        
        ( $profile->verbflection_present->{e}, $profile->verbflection_present->{e_correct} )  = 
            &do_word_magic( $transcript, 'verbmarker', 421, 'sv_agreement', 411 );
        ( $profile->verbflection_present->{o}, $profile->verbflection_present->{o_correct} ) = 
            &do_word_magic( $transcript, 'verbmarker', 422, 'sv_agreement', 411 );
        ( $profile->verbflection_present->{st}, $profile->verbflection_present->{st_correct} ) = 
            &do_word_magic( $transcript, 'verbmarker', 423, 'sv_agreement', 411 );
        ( $profile->verbflection_present->{en}, $profile->verbflection_present->{en_correct} ) = 
            &do_word_magic( $transcript, 'verbmarker', 424, 'sv_agreement', 411 );
        ( $profile->verbflection_present->{t}, $profile->verbflection_present->{t_correct} ) = 
            &do_word_magic( $transcript, 'verbmarker', 425, 'sv_agreement', 411 );
    };
    confess $@ if $@;
    
    # Turn absolute into relative correctness.
    #
    eval {
        $profile->verbflection_present->{e_correct} = calc_percentage( 
            $profile->verbflection_present->{e_correct},
            $profile->verbflection_present->{e} );
        
        $profile->verbflection_present->{o_correct} = calc_percentage( 
            $profile->verbflection_present->{o_correct}, 
            $profile->verbflection_present->{o} );
        
        $profile->verbflection_present->{st_correct} = calc_percentage( 
            $profile->verbflection_present->{st_correct},
            $profile->verbflection_present->{st} );
        
        $profile->verbflection_present->{en_correct} = calc_percentage( 
            $profile->verbflection_present->{en_correct},
            $profile->verbflection_present->{en} );
        
        $profile->verbflection_present->{t_correct} = calc_percentage( 
            $profile->verbflection_present->{t_correct},
            $profile->verbflection_present->{t} );
    };
    confess $@ if $@;
    
    # Verbflection past participle
    #
    eval {
        ( $profile->verbflection_past_participle->{no_change_en},
            $profile->verbflection_past_participle->{no_change_en_correct} )  = 
            &do_word_magic( $transcript, 'verbmarker', 430, 'sv_agreement', 411 );
        ( $profile->verbflection_past_participle->{change_en},
            $profile->verbflection_past_participle->{change_en_correct} ) = 
            &do_word_magic( $transcript, 'verbmarker', 431, 'sv_agreement', 411 );
        ( $profile->verbflection_past_participle->{no_change_t},
            $profile->verbflection_past_participle->{no_change_t_correct} ) = 
            &do_word_magic( $transcript, 'verbmarker', 432, 'sv_agreement', 411 );
    };
    confess $@ if $@;
    
    # Calculate percentages.
    #
    eval {
        $profile->verbflection_past_participle->{no_change_en_correct} = calc_percentage(
            $profile->verbflection_past_participle->{no_change_en_correct}, 
            $profile->verbflection_past_participle->{no_change_en} );
        
        $profile->verbflection_past_participle->{change_en_correct} = calc_percentage(
            $profile->verbflection_past_participle->{change_en_correct}, 
            $profile->verbflection_past_participle->{change_en} );
        
        $profile->verbflection_past_participle->{no_change_t_correct} = calc_percentage(
            $profile->verbflection_past_participle->{no_change_t_correct}, 
            $profile->verbflection_past_participle->{no_change_t} );
    };
    confess $@ if $@;
    
    # Case agreement
    #
    eval {
        $profile->case_agreement->{acc_acc} = &do_analysis_sum( $transcript, 'case_acc_acc' );
        $profile->case_agreement->{acc_nom} = &do_analysis_sum( $transcript, 'case_acc_nom' );
        $profile->case_agreement->{dat_dat} = &do_analysis_sum( $transcript, 'case_dat_dat' );
        $profile->case_agreement->{dat_nom} = &do_analysis_sum( $transcript, 'case_dat_nom' );
        $profile->case_agreement->{dat_acc} = &do_analysis_sum( $transcript, 'case_dat_acc' );
        
        $profile->case_agreement->{acc_acc_correct} = calc_percentage(
            $profile->case_agreement->{acc_acc},
            $profile->case_agreement->{acc_acc} +
            $profile->case_agreement->{acc_nom} );
        
        $profile->case_agreement->{dat_dat_correct} = calc_percentage(
            $profile->case_agreement->{dat_dat},
            $profile->case_agreement->{dat_dat} +
            $profile->case_agreement->{dat_nom} +
            $profile->case_agreement->{dat_acc} );
    };
    confess $@ if $@;
    
    # Elisions
    #
    eval {
        $profile->elisions->{subject} = &do_analysis_sum( $transcript, 'elision_subject' );
        $profile->elisions->{article} = &do_analysis_sum( $transcript, 'elision_article' );
        $profile->elisions->{verb} = &do_analysis_sum( $transcript, 'elision_verb' );
        $profile->elisions->{copular} = &do_analysis_sum( $transcript, 'elision_copular' );
        $profile->elisions->{auxiliary} = &do_analysis_sum( $transcript, 'elision_auxiliary' );
        $profile->elisions->{preposition} = &do_analysis_sum( $transcript, 'elision_preposition' );
    };
    confess $@ if $@;
    
    # Subject verb inversion
    # foo will get the sum of all svis used and is not
    # of any worth right now.
    #
    eval {
        my $foo;
        ( $foo, $profile->svi->{question}, $profile->svi->{question_correct} ) =
            &do_analysis_magic( $transcript, 'svi_used', 1, 'svi_context', 810, 'svi_correct', 821 );
        ( $foo, $profile->svi->{topicalization}, $profile->svi->{topicalization_correct} ) =
            &do_analysis_magic( $transcript, 'svi_used', 1, 'svi_context', 811, 'svi_correct', 821 );
        
        $profile->svi->{topicalization_correct} = calc_percentage(
            $profile->svi->{topicalization_correct},
            $profile->svi->{topicalization} );
        
        $profile->svi->{question_correct} = calc_percentage(
            $profile->svi->{question_correct},
            $profile->svi->{question} );
    };
    confess $@ if $@;
    
    return $profile;
}

sub save_profile {
    my ( $self, $profile, $input, $output ) = @_;

    eval { Liane::PDF::create_pdf( $profile, $input, $output ) };
    confess $@ if $@;
    
    return 1;
}

######################################################################
# Private

# Works on transcript->utterances->analysis->words
# Needs...
#    - transcript
#    - category (e.g. 'wordclass') and
#    - id (e.g. 210 for nouns).
# ...to return the sum of categories tagged
#    with the specified id.
#
# Takes...
#    - category2
#    - id2
# ...to return the sum of category2 tagged with
#    id, where category is tagged with id in the SAME WORD.
#    (e.g. to return the sum of verbs marked with
#    -st and the sum of sv_agreement in that 
#    particular scenario)
sub do_word_magic {
    my $transcript = shift;
    my $category   = shift;
    my $id         = shift;
    
    my $category2  = shift;
    my $id2        = shift;       
    
    my ( $utterance, $word );
    my ( $sum, $sum2 ) = ( 0, 0 );
    
    foreach $utterance ( @{ $transcript->utterances } ) {
        
        # we are only interested in the kid's utterances
        next if not $utterance->speaker eq '*KIN';
        
        foreach $word ( @{ $utterance->analysis->words } ) {
            # Increase $sum if id matches (e.g. 210  for nouns).
            # The accessor can be called via the name set
            # in $category - I AM FUCKING AMAZED!
        
            $sum++ if $word->$category == $id;
            
            if ( defined $category2 ) {
                $sum2++ if $word->$category == $id and 
                           $word->$category2 == $id2;
            }                            
        }
    } 
    
    return $sum if not defined $category2;
    
    return ( $sum, $sum2 );
}

# This returns the sum of occurences,
# where combinations of words have
# the specified ids in one
# category in the given order.
# e.g. how many article-noun-combinations
# are used.
sub do_word_combination_magic {

    # something's fishy
    #return -1;

    my $transcript = shift;
    my $category   = shift;
    my $id         = shift;
    my $id2        = shift;
    my $id3        = shift;       
    
    my $sum = 0;
    my ( $utterance, $word_count );
    
    foreach $utterance ( @{ $transcript->utterances } ) {                       
        
        # we are only interested in the kid's utterances
        next if not $utterance->speaker eq '*KIN';                       
        
        # number of words in this utterance
        $word_count = scalar( @{ $utterance->analysis->words } );
        
        # 3 combinations need at least 3 words!
        # 2 combinations need at least 2 words!        
        next if ( ( defined $id3 ) and ( $word_count < 3 ) );        
        next if $word_count < 2;
        
        for ( my $i = 0; $i < $word_count; $i++ ) {       
        
            next if not $utterance->analysis->words->[$i]->$category == $id;
            
            if ( defined $id2 ) {
                # we don't have to look further, if
                # the word cannot be within this utterance
                next if $word_count < $i + 2;
                next if not $utterance->analysis->words->[$i+1]->$category == $id2;
            }
            
            if ( defined $id3 ) {
                # we don't have to look further, if
                # the words cannot be within this utterance
                next if $word_count < $i + 3;
                next if not $utterance->analysis->words->[$i+2]->$category == $id3;
            }            
            
            $sum++;
        }
    } 
    
    return $sum;
}

# Works on transcript->utterances->analysis
# and counts occurences.
# Needs transcript, category (e.g. 'structure')
# and $id (e.g. 510 for two word sentence without verb).
#
# If category/id 2 and/or 3 are set, sum2/sum3 are increased,
# if all categories/ids match:
#
# ...increased, when...
# -----------------------------------------
#   sum         category  == id 
#   sum2        category2 == id2 and sum
#   sum3        category3 == id3 and sum3
sub do_analysis_magic {
    my $transcript = shift;
    my $category   = shift;
    my $id         = shift;
    
    my $category2 = shift;
    my $id2       = shift;
    
    my $category3 = shift;
    my $id3       = shift;
    
    my $utterance;
    my ( $sum, $sum2, $sum3 ) = ( 0, 0, 0 );
    
    foreach $utterance ( @{ $transcript->utterances } ) {
        
        # we are only interested in the kid's utterances
        next if not $utterance->speaker eq '*KIN';
        
        # e.g. if $utterance->analysis->structure == 510
        $sum++ if $utterance->analysis->$category == $id;
        
        if ( defined $category2 ) {
            $sum2++ if $utterance->analysis->$category == $id and
                       $utterance->analysis->$category2 == $id2;
            
        }
        
        if ( defined $category3 ) {
            $sum3++ if $utterance->analysis->$category == $id and
                       $utterance->analysis->$category2 == $id2 and
                       $utterance->analysis->$category3 == $id3;
            
        }
    }        
    
    return $sum if not defined $category2;
    
    return ( $sum, $sum2, $sum3 );
}

# Works on transcript->utterances->analysis
# and adds up saved values.
# E.g. for case_acc_acc.
sub do_analysis_sum {
    my ( $transcript, $category ) = @_;
    
    my $utterance;
    my $sum = 0;
    
    foreach $utterance ( @{ $transcript->utterances } ) {
        
        # we are only interested in the kid's utterances
        next if not $utterance->speaker eq '*KIN';
        
        # Summate stored values.
        $sum += $utterance->analysis->$category;
    }        
    
    return $sum;
}

sub calc_percentage {
    my ( $val1, $val2 ) = @_;
    my $percentage;
    
    # We don't want to watch the world burn.
    return '---' if $val2 == 0;
    
    # sprintf rounds to n.nn
    $percentage = sprintf( "%.2f", $val1 / $val2 ) * 100;
    
    return $percentage;
}

# Returns total or analyzable number of utterances
# depending on $analyzable_only.
sub count_utterances {
    my $transcript      = shift;
    my $analyzable_only = shift || 0;
    
    my ( $utterance, $word );
    my $sum = 0;
    
    foreach $utterance ( @{ $transcript->utterances } ) {
        
        # we are only interested in the kid's utterances
        next if not $utterance->speaker eq '*KIN';

        # Count only analyzable utterances
        # or count them all.
        if ( $analyzable_only == 1 ) {
            
            # We see an utterance as analyzable, if
            # - any of the ->analysis values is not default
            #       OR
            # - analysis->words->[n]->wordclass is not undef (200)
            
            # If it is ugly but it works - it is not ugly?
            # next: jump to next utterance, because each utterance
            # has only to be counted once.
            if ( $utterance->analysis->structure != 500 ) { $sum++; next; }
            if ( $utterance->analysis->case_acc_acc != 0 ) { $sum++; next; }
            if ( $utterance->analysis->case_acc_nom != 0 ) { $sum++; next; }
            if ( $utterance->analysis->case_dat_dat != 0 ) { $sum++; next; }
            if ( $utterance->analysis->case_dat_nom != 0 ) { $sum++; next; }
            if ( $utterance->analysis->case_dat_acc != 0 ) { $sum++; next; }
            if ( $utterance->analysis->elision_subject != 0 ) { $sum++; next; }
            if ( $utterance->analysis->elision_article != 0 ) { $sum++; next; }
            if ( $utterance->analysis->elision_verb != 0 ) { $sum++; next; }
            if ( $utterance->analysis->elision_copular != 0 ) { $sum++; next; }
            if ( $utterance->analysis->elision_auxiliary != 0 ) { $sum++; next; }
            if ( $utterance->analysis->elision_preposition != 0 ) { $sum++; next; }
            if ( $utterance->analysis->svi_used != 0 ) { $sum++; next; }

            # Check if any of the utterances words wordclasses
            # has been analyzed. last jumps to the end of that
            # foreach loop - and to the next utterance in that matter.
            foreach $word ( @{ $utterance->analysis->words } ) {
                # Default: wordclass = 200
                if ( $word->wordclass != 200 ) { $sum++; last; }
            }        
        }
        else {
            # This is where we end up for each utterance,
            # when determining the total number
            $sum++;
        }
    }        
    
    return $sum;
}

1;
