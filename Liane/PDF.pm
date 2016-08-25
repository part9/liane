package Liane::PDF;

use strict;
use warnings;
use utf8;

use Carp;

use PDF::API2;

######################################################################
# PDF Creation
# http://redgoose.ca/blog/perl-and-pre-filled-pdfs
# and because that did not work on windows - what a surprise - this
# is the source of the recent changes:
# http://www.perlmonks.org/?node_id=990872
# This works :)

sub create_pdf {
    my ( $profile, $file_in, $file_out ) = @_;
    
    # Open PDF template
    my $pdf_in   = PDF::API2->open( $file_in );
    my $pdf      = PDF::API2->new;
    
    my $page_in  = $pdf_in->openpage( 1 );
    my $page     = $pdf->page( 0 );
            
    $page->mediabox( $page_in->get_mediabox );
    $page->trimbox( $page_in->get_trimbox );
    
    my $gfx = $page->gfx;
    my $xo  = $pdf->importPageIntoForm( $pdf_in, 1 );

    $gfx->formimage( $xo,
            0, 0, # x y
            1 );   # scale

    my $text = $page->text();
         
    # Set Font    
    $text->font ( $pdf->corefont( 'Helvetica' ), 9 );
    
    # General
    #
    &write_text( $text,  60, 745, $profile->general->{name} );
    &write_text( $text, 172, 745, $profile->general->{age} );
    &write_text( $text, 204, 745, $profile->general->{date} );
    &write_text( $text, 258, 745, $profile->general->{identifier} );
    &write_text( $text, 307, 745, $profile->general->{situation} );
    
    # Utterances
    #
    $text->font ( $pdf->corefont( 'Helvetica-Bold' ), 7 );
    &write_text( $text,  91, 711, $profile->utterances->{total} );
    &write_text( $text, 156, 711, $profile->utterances->{total_analyzable} );
    
    $text->font ( $pdf->corefont( 'Helvetica' ), 7 );
    
    # Wordclasses
    #
    &write_text( $text, 136, 678, $profile->wordclasses->{noun} );    
    &write_text( $text, 136, 667, $profile->wordclasses->{article} );
    &write_text( $text, 136, 657, $profile->wordclasses->{adjective} );
    &write_text( $text, 136, 646, $profile->wordclasses->{pronoun_personal} );
    &write_text( $text, 136, 635, $profile->wordclasses->{pronoun_other} );
    
    &write_text( $text, 136, 614, $profile->wordclasses->{verb} );
    &write_text( $text, 136, 603, $profile->wordclasses->{auxiliary} );
    &write_text( $text, 136, 592, $profile->wordclasses->{modal} );
    &write_text( $text, 136, 581, $profile->wordclasses->{copular} );
    
    &write_text( $text, 136, 560, $profile->wordclasses->{adverb} );
    &write_text( $text, 136, 549, $profile->wordclasses->{preposition} );
    &write_text( $text, 136, 538, $profile->wordclasses->{conjunction} );
    
    &write_text( $text, 280, 667, $profile->wordclasses->{combination_ar_no} );
    &write_text( $text, 280, 657, $profile->wordclasses->{combination_ad_no} );
    &write_text( $text, 280, 646, $profile->wordclasses->{combination_ar_ad_no} );
    
    # Sentence Structure
    #
    $text->font ( $pdf->corefont( 'Helvetica-Bold' ), 7 );
    &write_text( $text, 281, 506, $profile->structures->{two_all} );
    $text->font ( $pdf->corefont( 'Helvetica' ), 7 );
    &write_text( $text, 281, 496, $profile->structures->{two_no_verb} );
    &write_text( $text, 281, 485, $profile->structures->{two_inf} );
    
    $text->font ( $pdf->corefont( 'Helvetica-Bold' ), 7 );
    &write_text( $text, 281, 463, $profile->structures->{more_all} );
    $text->font ( $pdf->corefont( 'Helvetica' ), 7 );
    &write_text( $text, 281, 453, $profile->structures->{more_inf} );
    &write_text( $text, 281, 431, $profile->structures->{more_vtwo_conj} );
    &write_text( $text, 281, 410, $profile->structures->{more_vtwo_aux} );
    
    $text->font ( $pdf->corefont( 'Helvetica-Bold' ), 7 );
    &write_text( $text,  281, 388, $profile->structures->{combination} );
    $text->font ( $pdf->corefont( 'Helvetica' ), 7 );
    
    # Verbmarker present
    #
    &write_text( $text, 193, 340, $profile->verbflection_present->{inf} );
    &write_text( $text, 233, 340, '[' . $profile->verbflection_present->{inf_rel} . '%]' );
    &write_text( $text, 193, 329, $profile->verbflection_present->{e} );
    &write_text( $text, 233, 329, '(' . $profile->verbflection_present->{e_correct} . '%)' );
    &write_text( $text, 193, 318, $profile->verbflection_present->{o} );
    &write_text( $text, 233, 318, '(' . $profile->verbflection_present->{o_correct} . '%)' );
    &write_text( $text, 193, 308, $profile->verbflection_present->{st} );
    &write_text( $text, 233, 308, '(' . $profile->verbflection_present->{st_correct} . '%)' );
    &write_text( $text, 193, 297, $profile->verbflection_present->{en} );
    &write_text( $text, 233, 297, '(' . $profile->verbflection_present->{en_correct} . '%)' );
    &write_text( $text, 193, 286, $profile->verbflection_present->{t} );
    &write_text( $text, 233, 286, '(' . $profile->verbflection_present->{t_correct} . '%)' );
    
    # Verbmarker past participle
    #
    &write_text( $text, 193, 252, $profile->verbflection_past_participle->{no_change_en} );
    &write_text( $text, 233, 252, '(' . $profile->verbflection_past_participle->{no_change_en_correct} . '%)' );
    &write_text( $text, 193, 242, $profile->verbflection_past_participle->{change_en} );
    &write_text( $text, 233, 242, '(' . $profile->verbflection_past_participle->{change_en_correct} . '%)' );
    &write_text( $text, 193, 231, $profile->verbflection_past_participle->{no_change_t} );
    &write_text( $text, 233, 231, '(' . $profile->verbflection_past_participle->{no_change_t_correct} . '%)' );
    
    # Case agreement
    #
    &write_text( $text, 258, 198, $profile->case_agreement->{acc_acc} );
    &write_text( $text, 266, 198, '(' . $profile->case_agreement->{acc_acc_correct} . '%)' );
    &write_text( $text, 258, 188, $profile->case_agreement->{acc_nom} );
    &write_text( $text, 258, 166, $profile->case_agreement->{dat_dat} );
    &write_text( $text, 266, 166, '(' . $profile->case_agreement->{dat_dat_correct} . '%)' );
    &write_text( $text, 258, 155, $profile->case_agreement->{dat_nom} );
    &write_text( $text, 258, 145, $profile->case_agreement->{dat_acc} );
    
    # Elisions
    #    
    &write_text( $text, 136, 112, $profile->elisions->{subject} );
    &write_text( $text, 136, 101, $profile->elisions->{article} );
    &write_text( $text, 136,  91, $profile->elisions->{verb} );
    &write_text( $text, 280, 112, $profile->elisions->{copular} );
    &write_text( $text, 280, 101, $profile->elisions->{auxiliary} );
    &write_text( $text, 280,  91, $profile->elisions->{preposition} );

    # Subject verb inversion
    #
    &write_text( $text, 396, 112, $profile->svi->{question} );
    &write_text( $text, 421, 112, '(' . $profile->svi->{question_correct} . '%)' );
    &write_text( $text, 396, 101, $profile->svi->{topicalization} );
    &write_text( $text, 421, 101, '(' . $profile->svi->{topicalization_correct} . '%)' );

    eval { $pdf->saveas( $file_out ) };
    confess $@ if $@;   
    
    return 1;
}

sub write_text {
    my ( $texthandle, $pos_x, $pos_y, $text ) = @_;    
    
    $texthandle->translate( $pos_x , $pos_y );
    $texthandle->text( $text );    
}

1;
