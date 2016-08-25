package Liane::Wx::Analyzer;

use strict;
use warnings;
use utf8;

use Liane::Help;

use Liane::List;

use Switch;

use Wx qw( :everything );
use Wx::Event qw( :everything );

our @ISA = qw( Liane::Wx::FBP::Analyzer );
use Liane::Wx::FBP::Analyzer;

sub new {
    my $class  = shift;
    my $parent = shift;
    # CAVE: this comes by referenc!
	my $transcript = shift;
	
	my $self = Liane::Wx::FBP::Analyzer->new( $parent );
	$self->CenterOnScreen;

	######################################
	# Instance variable initializatition
	######################################    
    
    # Save reference to the hot transcript.
    $self->{transcript} = $transcript;         
    
    # Clone working copy of transcript.
    $self->{transcript_clone} = ${ $self->{transcript} }->clone;    
    
    $self->{transcript_clone}->create_words;   
    
    # So all the grammar functions know where
    # to store the carefully selected information.
    undef $self->{active_analysis};
    undef $self->{active_word};

    ######################################
    # GUI preparation
    ######################################

    # Initialize GUI: list control   
    $self->{lst_utterances}->InsertColumn( 0, 'Sprecher', wxLIST_FORMAT_LEFT, 70 );
    $self->{lst_utterances}->InsertColumn( 1, 'Äußerung', wxLIST_FORMAT_LEFT, 500 );
    
    $self->{lst_words}->InsertColumn( 1, 'Wörter', wxLIST_FORMAT_LEFT, 145 );
	
    $self->{btn_ok}->SetBitmap(
        Wx::Bitmap->new( './Liane/Ressources/save_48.ico', wxBITMAP_TYPE_ICO ) );

    $self->{btn_cancel}->SetBitmap(
        Wx::Bitmap->new( './Liane/Ressources/cancel_48.ico', wxBITMAP_TYPE_ICO ) );
	
	$self->{btn_help}->SetBitmap(
        Wx::Bitmap->new( './Liane/Ressources/help_48.ico', wxBITMAP_TYPE_ICO ) );
	
	
    ######################################
    # EVT handling
    ######################################
	
	# lst_utterances
    EVT_LIST_ITEM_SELECTED(   $self, $self->{lst_utterances}, \&utterance_selected   );
    EVT_LIST_ITEM_DESELECTED( $self, $self->{lst_utterances}, \&utterance_deselected );
    # lst_words
    EVT_LIST_ITEM_SELECTED(   $self, $self->{lst_words}, \&word_selected   );
    EVT_LIST_ITEM_DESELECTED( $self, $self->{lst_words}, \&word_deselected );
	
    # Menu
    EVT_BUTTON( $self, $self->{btn_ok},     \&save_transcript );
    EVT_BUTTON( $self, $self->{btn_cancel}, \&cancel );
    EVT_BUTTON( $self, $self->{btn_help}, \&Liane::Help::help );
    
	EVT_CLOSE( $self, \&cancel );

    # There are so many of them!!
    &attach_analyzer_events( $self );
    &attach_help_events( $self );

    ######################################
    # Finale
    ######################################	
	
	&db_to_gui( $self );
	# Disable all gui fields.	
	&analysis_enable( $self, 0 );
	return $self;	
}

######################################################################
# Events for OK and CANCEL

sub save_transcript {
    my $self = shift;   
        
    &gui_to_db( $self );
    &close_window( $self, 1 );
}

sub cancel {
    my $self = shift;
    

    if ( not Liane::Wx::Dialog->yes_no( $self, 
            "Eventuell Änderungen an der Analyse gehen\n" .
            "beim Abbrechen verloren.\n\n".
            "Dennoch fortfahren?",
            'Analyse beenden' ) ) {
        return;
    }
    
    &close_window( $self, 0 );
}

######################################################################
# List interaction

sub utterance_selected {
    my ( $self, $event ) = @_;
    
    my $id = $event->GetIndex;

    # This points to the utterance
    # according to the list selection.
    $self->{active_analysis} = $self->{transcript_clone}->utterances->[$id]->analysis;
    
    # Homegrown single-selection implementation
    # because wxWidgets stuff does not work.  
    Liane::List->deselect_all_but_this_item(
        $self->{lst_utterances}, $id );   
    
    # If the selected utterance is by a kid.
    # FIXME: please don't hard-code this...!
    if ( $self->{transcript_clone}->utterances->[$id]->speaker eq '*KIN' )
    {
        # List the utterance's words in the word list
        &list_words( $self, $self->{transcript_clone}->utterances->[$id]->analysis->words );
        
        # Enable sentence structure analysis,
        # the other ones are enabled after 
        # selecting the words.
        &analysis_structure_enable( $self, 1 );
        # Set all buttons etc. to the values that
        # might already have been analyzed.
        &analysis_structure_set_values( $self );
    }
}

sub utterance_deselected {
    my ( $self, $event ) = @_;
    
    # Goodbye references.
    # undef both, or disabling gui
    # fields will destroy analysis data!
    undef( $self->{active_analysis} );
    undef( $self->{active_word} );        
    
    # Reset and disable all analysis gui fields
    &analysis_enable( $self, 0 );

    # Flush all words from the list.
    $self->{lst_words}->DeleteAllItems;    
}

sub word_selected {
    my ( $self, $event ) = @_;
    
    my $id = $event->GetIndex;
    
    # This points to the word
    # according to the selection.
    $self->{active_word} = $self->{active_analysis}->words->[$id];
    
    # Homegrown single-selection implementation
    # because wxWidgets stuff does not work.
    Liane::List->deselect_all_but_this_item(
        $self->{lst_words}, $id );
    
    # Enable wordclass fields
    &analysis_wordclass_enable( $self, 1 );
    # And set values that might have
    # been analyzed before.
    &analysis_word_set_values( $self );   
}

sub word_deselected {
    my ( $self, $event ) = @_;
    
    # Goodbye.
    undef( $self->{active_word} );
    
    # Reset and disable word analysis fields
    &analysis_word_enable( $self, 0 );
    
}

######################################################################
# DB-GUI-Interaction (of Liane::DB::Transcript type)
# (only the transcript part of the db of course)

sub db_to_gui {
    my $self = shift;

    # Load utterances in transcript to lst_utterances.
    $self->{lst_utterances}->DeleteAllItems;
    
    my @utterances = $self->{transcript_clone}->list_utterances;
    my $id   = 0;
    foreach my $utterance (@utterances)
    {               
        $self->{lst_utterances}->InsertStringItem( $id,  @{ $utterance }[0] );
        $self->{lst_utterances}->SetItem( $id, 1,        @{ $utterance }[1] );
        
        $id++;
    }
}

# Save everything to the db: by copying the
# clone to the hot transcript.
sub gui_to_db {
    my $self = shift;  
       
    ${ $self->{transcript} } = $self->{transcript_clone};           
}

######################################################################
# Analyzer Elements: ENABLE/DISABLE+reset
#
# Offers subs to enable/disable specific parts
# of the analyzer.
#
# ALSO, when...
# ...disabling, resets analysis data of
#    active_structure/word to defaults.
#
# analysis
# |-structrue
# |-word
# |--class
# |--flection
# |---number
# |---case
# |---gender
# |---tense
# |---person
# |--verbmarker

sub analysis_enable {
    my ( $self, $enable ) = @_;
    
    &analysis_structure_enable( $self, $enable );
    &analysis_word_enable( $self, $enable );
}

sub analysis_structure_enable {
    my ( $self, $enable ) = @_;
    
    # Structure
    $self->{rad_structure_none}->Enable( $enable );
    $self->{rad_structure_two}->Enable( $enable );
    $self->{rad_structure_two_verb}->Enable( $enable );
    $self->{rad_structure_more_inf}->Enable( $enable );
    $self->{rad_structure_more_vtwo_conj}->Enable( $enable );
    $self->{lbl_structure_more_vtwo_conj}->Enable( $enable );
    $self->{rad_structure_more_vtwo_aux}->Enable( $enable );
    $self->{lbl_structure_more_vtwo_aux}->Enable( $enable );
    $self->{rad_structure_more_other}->Enable( $enable );
    $self->{rad_structure_complex}->Enable( $enable );
    
    # Case agreement
    $self->{lbl_cagreement_acc}->Enable( $enable );
    $self->{lbl_cagreement_acc_acc}->Enable( $enable );
    $self->{lbl_cagreement_acc_nom}->Enable( $enable );
    $self->{txt_cagreement_acc_acc}->Enable( $enable );
    $self->{txt_cagreement_acc_nom}->Enable( $enable );
    $self->{lbl_cagreement_dat}->Enable( $enable );
    $self->{lbl_cagreement_dat_dat}->Enable( $enable );
    $self->{lbl_cagreement_dat_nom}->Enable( $enable );
    $self->{lbl_cagreement_dat_acc}->Enable( $enable );    
    $self->{txt_cagreement_dat_dat}->Enable( $enable );
    $self->{txt_cagreement_dat_nom}->Enable( $enable );
    $self->{txt_cagreement_dat_acc}->Enable( $enable );
    
    # Elision
    $self->{chk_elision_subject}->Enable( $enable );
    $self->{chk_elision_article}->Enable( $enable );
    $self->{chk_elision_verb}->Enable( $enable );
    $self->{chk_elision_copular}->Enable( $enable );
    $self->{chk_elision_auxiliary}->Enable( $enable );
    $self->{chk_elision_preposition}->Enable( $enable );
    
    # Subject-verb-inversion
    $self->{chk_svi_used}->Enable( $enable );
    $self->{rad_svi_question}->Enable( $enable );
    $self->{rad_svi_topicalization}->Enable( $enable );
    $self->{rad_svi_correct}->Enable( $enable );
    $self->{rad_svi_incorrect}->Enable( $enable );
    
    return if $enable;
    $self->{rad_structure_none}->SetValue( 1 );
    
    # Case agreement
    $self->{txt_cagreement_acc_acc}->SetValue( 0 );
    $self->{txt_cagreement_acc_nom}->SetValue( 0 );
    $self->{txt_cagreement_dat_dat}->SetValue( 0 );
    $self->{txt_cagreement_dat_nom}->SetValue( 0 );
    $self->{txt_cagreement_dat_acc}->SetValue( 0 );
    
    # Elisions
    $self->{chk_elision_subject}->SetValue( 0 );
    $self->{chk_elision_article}->SetValue( 0 );
    $self->{chk_elision_verb}->SetValue( 0 );
    $self->{chk_elision_copular}->SetValue( 0 );
    $self->{chk_elision_auxiliary}->SetValue( 0 );
    $self->{chk_elision_preposition}->SetValue( 0 );
    
    # Subject-Verb-Inversion
    $self->{chk_svi_used}->SetValue( 0 );
    # SVI context
    $self->{rad_svi_question}->SetValue( 1 );
    # SVI correct
    $self->{rad_svi_correct}->SetValue( 1 );
    
}

sub analysis_word_enable {
    my ( $self, $enable ) = @_;
       
    &analysis_wordclass_enable( $self, $enable );
    &analysis_word_flection_enable( $self, $enable );
    &analysis_word_verbmarker_enable( $self, $enable );
}

sub analysis_wordclass_enable {
    my ( $self, $enable ) = @_;
    
    $self->{rad_wordclass_none}->Enable( $enable );    
    # Declinable
    $self->{rad_wordclass_noun}->Enable( $enable );
    $self->{rad_wordclass_article}->Enable( $enable );
    $self->{rad_wordclass_adjective}->Enable( $enable );
    $self->{rad_wordclass_pronoun_personal}->Enable( $enable );
    $self->{rad_wordclass_pronoun_other}->Enable( $enable );
    # Conjugable
    $self->{rad_wordclass_verb}->Enable( $enable );
    $self->{rad_wordclass_auxiliary}->Enable( $enable );
    $self->{rad_wordclass_modal}->Enable( $enable );
    $self->{rad_wordclass_copular}->Enable( $enable );    
    # Not inflectible (Ininflectible or what?)
    $self->{rad_wordclass_adverb}->Enable( $enable );
    $self->{rad_wordclass_preposition}->Enable( $enable );
    $self->{rad_wordclass_conjunction}->Enable( $enable );
    
    return if $enable;
    $self->{rad_wordclass_none}->SetValue( 1 );
    
    return if not defined $self->{active_word};
    $self->{active_word}->wordclass( 200 );
    
}

sub analysis_word_flection_enable {
    my ( $self, $enable ) = @_;
    
    &analysis_word_flection_number_enable( $self, $enable );
    &analysis_word_flection_case_enable( $self, $enable );
    &analysis_word_flection_gender_enable( $self, $enable );
    &analysis_word_flection_tense_enable( $self, $enable );
    &analysis_word_flection_person_enable( $self, $enable );
}    

sub analysis_word_flection_number_enable {
    my ( $self, $enable ) = @_;
    
    $self->{lbl_number}->Enable( $enable );
    $self->{rad_number_none}->Enable( $enable );
    $self->{rad_number_singular}->Enable( $enable );
    $self->{rad_number_plural}->Enable( $enable );
    
    return if $enable;
    $self->{rad_number_none}->SetValue( 1 );
    
    return if not defined $self->{active_word};
    $self->{active_word}->number( 300 );
}    

sub analysis_word_flection_case_enable {
    my ( $self, $enable ) = @_;    
    
    $self->{lbl_case}->Enable( $enable );
    $self->{rad_case_none}->Enable( $enable );
    $self->{rad_case_nominative}->Enable( $enable );
    $self->{rad_case_genitive}->Enable( $enable );    
    $self->{rad_case_dative}->Enable( $enable );
    $self->{rad_case_accusative}->Enable( $enable );
    
    return if $enable;
    $self->{rad_case_none}->SetValue( 1 );
    
    return if not defined $self->{active_word};
    $self->{active_word}->case( 310 );
}    

sub analysis_word_flection_gender_enable {
    my ( $self, $enable ) = @_;    
    
    $self->{lbl_gender}->Enable( $enable );
    $self->{rad_gender_none}->Enable( $enable );
    $self->{rad_gender_masculine}->Enable( $enable );
    $self->{rad_gender_feminine}->Enable( $enable );
    $self->{rad_gender_neuter}->Enable( $enable );
    
    return if $enable;
    $self->{rad_gender_none}->SetValue( 1 );
    
    return if not defined $self->{active_word};
    $self->{active_word}->gender( 320 );
}    

sub analysis_word_flection_tense_enable {
    my ( $self, $enable ) = @_; 
       
    $self->{lbl_tense}->Enable( $enable );
    $self->{rad_tense_none}->Enable( $enable );    
    $self->{rad_tense_present}->Enable( $enable );
    $self->{rad_tense_past_participle}->Enable( $enable );
    $self->{rad_tense_other}->Enable( $enable );
    
    return if $enable;
    $self->{rad_tense_none}->SetValue( 1 );
    
    return if not defined $self->{active_word};
    $self->{active_word}->tense( 330 );
}    

sub analysis_word_flection_person_enable {
    my ( $self, $enable ) = @_;   
     
    $self->{lbl_person}->Enable( $enable );
    $self->{rad_person_none}->Enable( $enable );
    $self->{rad_person_first}->Enable( $enable );
    $self->{rad_person_second}->Enable( $enable );
    $self->{rad_person_third}->Enable( $enable );
    
    return if $enable;
    $self->{rad_person_none}->SetValue( 1 );
    
    return if not defined $self->{active_word};
    $self->{active_word}->person( 340 );
}

sub analysis_word_verbmarker_enable {
    my ( $self, $enable ) = @_;
    
    $self->{lbl_verbmarker}->Enable( $enable );
    # No matter what - the combo boxes
    # for verbmarker selection are only
    # brought into picture by correct
    # tense selection.
    $self->{cho_verbmarker_present}->Enable( 0 );
    $self->{cho_verbmarker_past_participle}->Enable( 0 );
    
    $self->{rad_sv_agreement_correct}->Enable( $enable );
    $self->{rad_sv_agreement_incorrect}->Enable( $enable );
    
    return if $enable;
    $self->{rad_sv_agreement_correct}->SetValue( 1 );    
    $self->{cho_verbmarker_present}->SetSelection( 0 );    
    $self->{cho_verbmarker_past_participle}->SetSelection( 0 ); 
    
    return if not defined $self->{active_word};
    $self->{active_word}->sv_agreement( 411 );
    $self->{active_word}->verbmarker( 400 );
    
}

######################################################################
# Analyzer Elements: SET VALUES
#
#

# Sets all radiobuttons, checkboxes and
# textfields to the values of the
# $self->{active_analysis}.
sub analysis_structure_set_values {
    my $self = shift;
    
    my ( $value, $gui_object );
    
    # Sentence structure
    $value = $self->{active_analysis}->structure;
    $gui_object = Wx::Window::FindWindowById( $value, $self );
    $gui_object->SetValue( 1 );
    
    # Case agreement
    $self->{txt_cagreement_acc_acc}->SetValue( $self->{active_analysis}->case_acc_acc );
    $self->{txt_cagreement_acc_nom}->SetValue( $self->{active_analysis}->case_acc_nom );
    $self->{txt_cagreement_dat_dat}->SetValue( $self->{active_analysis}->case_dat_dat );
    $self->{txt_cagreement_dat_nom}->SetValue( $self->{active_analysis}->case_dat_nom );
    $self->{txt_cagreement_dat_acc}->SetValue( $self->{active_analysis}->case_dat_acc );    
    
    # Elisions
    $self->{chk_elision_subject}->SetValue( $self->{active_analysis}->elision_subject );
    $self->{chk_elision_article}->SetValue( $self->{active_analysis}->elision_article );
    $self->{chk_elision_verb}->SetValue( $self->{active_analysis}->elision_verb );
    $self->{chk_elision_copular}->SetValue( $self->{active_analysis}->elision_copular );
    $self->{chk_elision_auxiliary}->SetValue( $self->{active_analysis}->elision_auxiliary );
    $self->{chk_elision_preposition}->SetValue( $self->{active_analysis}->elision_preposition );
    
    # Subject-Verb-Inversion
    $self->{chk_svi_used}->SetValue( $self->{active_analysis}->svi_used );
    # SVI context
    $value = $self->{active_analysis}->svi_context;
    $gui_object = Wx::Window::FindWindowById( $value, $self );
    $gui_object->SetValue( 1 );
    # SVI correct
    $value = $self->{active_analysis}->svi_correct;
    $gui_object = Wx::Window::FindWindowById( $value, $self );
    $gui_object->SetValue( 1 );    
}    

sub analysis_word_set_values {
    my $self = shift;

    my ( $value, $gui_object );
    
    # Wordclass
    $value = $self->{active_word}->wordclass;
    $gui_object = Wx::Window::FindWindowById( $value, $self );
    $gui_object->SetValue( 1 );
    # Call the event handler, but not with event
    # but id directly!
    &analyzed_wordclass( $self, undef, $value);
    
    # Number
    $value = $self->{active_word}->number;
    $gui_object = Wx::Window::FindWindowById( $value, $self );
    $gui_object->SetValue( 1 );
    
    # Case
    $value = $self->{active_word}->case;
    $gui_object = Wx::Window::FindWindowById( $value, $self );
    $gui_object->SetValue( 1 );
    
    # Gender
    $value = $self->{active_word}->gender;
    $gui_object = Wx::Window::FindWindowById( $value, $self );
    $gui_object->SetValue( 1 );
    
    # Tense
    $value = $self->{active_word}->tense;
    $gui_object = Wx::Window::FindWindowById( $value, $self );
    $gui_object->SetValue( 1 );
    &analyzed_tense( $self, undef, $value );
    
    # Person
    $value = $self->{active_word}->person;
    $gui_object = Wx::Window::FindWindowById( $value, $self );
    $gui_object->SetValue( 1 );
    
    # SV Agreement
    $value = $self->{active_word}->sv_agreement;
    $gui_object = Wx::Window::FindWindowById( $value, $self );
    $gui_object->SetValue( 1 );
    
    # Verbmarker
    $value = $self->{active_word}->verbmarker;    
    if ( $value >= 430 ) {
        $self->{cho_verbmarker_past_participle}->SetSelection( $value - 430 );
    }
    elsif ( $value >= 420 ) {
        $self->{cho_verbmarker_present}->SetSelection( $value - 420 );
    }
}

# FIXME: oh how golden it would be, if they would
# use some kind of constants and not hardwired integers....
######################################################################
# ANALYZER ELEMENTS: event functions
# 
# The $event->GetId of the object, that
# fires the event, is set to be the code
# of the corresponding grammar phenomenon!
# (e.g. 221 = auxiliary verb etc.)

# Sets analysis and takes care of enabling the 
# fields, that make sense grammatically (e.g.
# no person selection for nouns).
sub analyzed_wordclass {
    my ( $self, $event, $id_arg ) = @_;            
    
    my $id = $id_arg || $event->GetId;    
    
    return if not defined $self->{active_word};
    # Set the active word's analyzed wordclass
    $self->{active_word}->wordclass( $id );
    
    # Enable the according fields.
    # This only makes it easier for the user
    # and serves no higher purpose.
    switch ( $id ) {
        # None or un-in-no-flectible ones.
        case  [200, 230..232] {
            &analyzed_wordclass_enabler( $self, 0, 0, 0, 0, 0 );
            &analysis_word_verbmarker_enable( $self, 0 );
        };
        # Noun, article or adjective or pronouns (other)
        case  [210..212, 214] { 
            &analyzed_wordclass_enabler( $self, 1, 1, 1, 0, 0 );
            &analysis_word_verbmarker_enable( $self, 0 );
        };
        # Pronouns (personal)
        case  213 {
            &analyzed_wordclass_enabler( $self, 1, 1, 1, 0, 1 );
            &analysis_word_verbmarker_enable( $self, 0 );
        };
        # All kinds of verbs
        case  [220..223] { 
            &analyzed_wordclass_enabler( $self, 1, 0, 0, 1, 1 );
            &analysis_word_verbmarker_enable( $self, 1 );
        };
    }            
}

# Takes care of actually enabling/disabling the
# gui objects.
sub analyzed_wordclass_enabler {
    my ( $self, $number, $case, $gender, $tense, $person ) = @_;
    
    &analysis_word_flection_number_enable( $self, $number );
    &analysis_word_flection_case_enable( $self, $case );
    &analysis_word_flection_gender_enable( $self, $gender );
    &analysis_word_flection_tense_enable( $self, $tense );
    &analysis_word_flection_person_enable( $self, $person );    
}

# Set the active word's analyzed ...
sub analyzed_number {
    my ( $self, $event ) = @_;
    return if not defined $self->{active_word};
    $self->{active_word}->number( $event->GetId );    
}

sub analyzed_case {
    my ( $self, $event ) = @_;
    return if not defined $self->{active_word};
    $self->{active_word}->case( $event->GetId );
}

sub analyzed_gender {
    my ( $self, $event ) = @_;
    return if not defined $self->{active_word};    
    $self->{active_word}->gender( $event->GetId );
}

sub analyzed_tense {
    my ( $self, $event, $id_arg ) = @_;
    
    my $id = $id_arg || $event->GetId;
    
    return if not defined $self->{active_word};
    
    $self->{active_word}->tense( $id );    
    
    switch ( $id ) {
        # undef or other
        case [330, 333] {
            $self->{cho_verbmarker_present}->Enable( 0 );
            $self->{cho_verbmarker_past_participle}->Enable( 0 );
        }
        # present
        case 331 {
            $self->{cho_verbmarker_present}->Enable( 1 );
            $self->{cho_verbmarker_past_participle}->Enable( 0 );
            # Enabling the choice control
            # does not fire the event, so
            # we have to set the default here.
            # CAVE: but only, if the set verbmarker category changes!            
            # (in this case from past_participle to present)
            # Otherwise already set values are always overwritten by
            # the default, which sucks, especially when &analysis_word_set_values
            # initiates loading of analyzed values.
            if ( $self->{active_word}->verbmarker >= 430 ) {
                $self->{active_word}->verbmarker( 420 );
            }
        }
        # past participle
        case 332 {
            $self->{cho_verbmarker_present}->Enable( 0 );
            $self->{cho_verbmarker_past_participle}->Enable( 1 );
            # Enabling the choice control
            # does not fire the event, so
            # we have to set the default here.   
            # CAVE: see above.
            if ( $self->{active_word}->verbmarker < 430 ) {         
                $self->{active_word}->verbmarker( 430 );
            }
        }
    }    
}

sub analyzed_person {
    my ( $self, $event ) = @_;
    return if not defined $self->{active_word};
    $self->{active_word}->person( $event->GetId );
}

sub analyzed_sv_agreement {
    my ( $self, $event ) = @_;
    return if not defined $self->{active_word};
    $self->{active_word}->sv_agreement( $event->GetId );
}

sub analyzed_verbmarker {
    my ( $self, $event ) = @_;
    
    return if not defined $self->{active_word};
    
    my $verbmarker = 400;
    
    # 420 thru 426 are present tense markers
    if ( $event->GetId == 420 ) {
        $verbmarker = 420 + $self->{cho_verbmarker_present}->GetSelection;
    }
    # 430 thru 433 are past participle markers
    elsif ( $event->GetId == 430 ) {
        $verbmarker = 430 + $self->{cho_verbmarker_past_participle}->GetSelection;
    }
    
    $self->{active_word}->verbmarker( $verbmarker );
}

# Set active utterance's ...
sub analyzed_structure {
    my ( $self, $event ) = @_;
    return if not defined $self->{active_analysis};    
    $self->{active_analysis}->structure( $event->GetId );
}

sub analyzed_case_agreement {
    my ( $self, $event ) = @_;   

    return if not defined $self->{active_analysis};        
    
    # This is important, so the change
    # in one text field changes only
    # the corresponding data!
    switch ( $event->GetId ) {
        case 600 {    
            $self->{active_analysis}->case_acc_acc( $self->{txt_cagreement_acc_acc}->GetValue );
        }
        case 601 {
            $self->{active_analysis}->case_acc_nom( $self->{txt_cagreement_acc_nom}->GetValue );
        }
        case 610 {
            $self->{active_analysis}->case_dat_dat( $self->{txt_cagreement_dat_dat}->GetValue );
        }
        case 611 {
            $self->{active_analysis}->case_dat_nom( $self->{txt_cagreement_dat_nom}->GetValue );
        }
        case 612 {
            $self->{active_analysis}->case_dat_acc( $self->{txt_cagreement_dat_acc}->GetValue );
        }
    }
}

sub analyzed_elision {
    my ( $self, $event ) = @_;
    
    return if not defined $self->{active_analysis};
    
    switch ( $event->GetId ) {
        case 700 {
            $self->{active_analysis}->elision_subject( $self->{chk_elision_subject}->GetValue );
        }
        case 701 {
            $self->{active_analysis}->elision_article( $self->{chk_elision_article}->GetValue );
        }
        case 702 {
            $self->{active_analysis}->elision_verb( $self->{chk_elision_verb}->GetValue );
        }
        case 703 {
            $self->{active_analysis}->elision_copular( $self->{chk_elision_copular}->GetValue );
        }
        case 704 {
            $self->{active_analysis}->elision_auxiliary( $self->{chk_elision_auxiliary}->GetValue );
        }
        case 705 {
            $self->{active_analysis}->elision_preposition( $self->{chk_elision_preposition}->GetValue );
        }
    }
}

sub analyzed_svi {
    my ( $self, $event ) = @_;
    
    return if not defined $self->{active_analysis};
    
    switch ( $event->GetId ) {
        case 800 {  
            $self->{active_analysis}->svi_used( $self->{chk_svi_used}->GetValue );
        }

        case [810, 811] {
            $self->{active_analysis}->svi_context( $event->GetId ); 
        }

        case [820, 821] {
            $self->{active_analysis}->svi_correct( $event->GetId ); 
        }
    }
}

######################################################################
# Private functions

sub list_words {
    my ( $self, $words ) = @_;

    for ( my $i = 0; $i < scalar( @{ $words } ); $i++ ) {
        $self->{lst_words}->InsertStringItem( $i, $words->[$i]->text );
    }
    
}    

sub close_window {
    my $self    = shift;
    my $ret_val = shift;

    $self->EndModal( $ret_val );
    $self->Destroy;
}

######################################################################
# ANALYZER ELEMENTS: event attaching

sub attach_analyzer_events {
    my $self = shift;   
    
    # Wordclasses
    EVT_RADIOBUTTON( $self, $self->{rad_wordclass_none}, \&analyzed_wordclass );
    EVT_RADIOBUTTON( $self, $self->{rad_wordclass_noun}, \&analyzed_wordclass );
    EVT_RADIOBUTTON( $self, $self->{rad_wordclass_article}, \&analyzed_wordclass );
    EVT_RADIOBUTTON( $self, $self->{rad_wordclass_adjective}, \&analyzed_wordclass );
    EVT_RADIOBUTTON( $self, $self->{rad_wordclass_pronoun_personal}, \&analyzed_wordclass );
    EVT_RADIOBUTTON( $self, $self->{rad_wordclass_pronoun_other}, \&analyzed_wordclass );
    EVT_RADIOBUTTON( $self, $self->{rad_wordclass_verb}, \&analyzed_wordclass );
    EVT_RADIOBUTTON( $self, $self->{rad_wordclass_auxiliary}, \&analyzed_wordclass );
    EVT_RADIOBUTTON( $self, $self->{rad_wordclass_modal}, \&analyzed_wordclass );
    EVT_RADIOBUTTON( $self, $self->{rad_wordclass_copular}, \&analyzed_wordclass );
    EVT_RADIOBUTTON( $self, $self->{rad_wordclass_adverb}, \&analyzed_wordclass );
    EVT_RADIOBUTTON( $self, $self->{rad_wordclass_preposition}, \&analyzed_wordclass );
    EVT_RADIOBUTTON( $self, $self->{rad_wordclass_conjunction}, \&analyzed_wordclass );
    
    # Flection: Number
    EVT_RADIOBUTTON( $self, $self->{rad_number_none}, \&analyzed_number );
    EVT_RADIOBUTTON( $self, $self->{rad_number_singular}, \&analyzed_number );
    EVT_RADIOBUTTON( $self, $self->{rad_number_plural}, \&analyzed_number );
    
    # Flection: Case
    EVT_RADIOBUTTON( $self, $self->{rad_case_none}, \&analyzed_case );
    EVT_RADIOBUTTON( $self, $self->{rad_case_nominative}, \&analyzed_case );
    EVT_RADIOBUTTON( $self, $self->{rad_case_genitive}, \&analyzed_case );
    EVT_RADIOBUTTON( $self, $self->{rad_case_dative}, \&analyzed_case );
    EVT_RADIOBUTTON( $self, $self->{rad_case_accusative}, \&analyzed_case );
    
    # Flection: Gender
    EVT_RADIOBUTTON( $self, $self->{rad_gender_none}, \&analyzed_gender );
    EVT_RADIOBUTTON( $self, $self->{rad_gender_masculine}, \&analyzed_gender );
    EVT_RADIOBUTTON( $self, $self->{rad_gender_feminine}, \&analyzed_gender );
    EVT_RADIOBUTTON( $self, $self->{rad_gender_neuter}, \&analyzed_gender );
    
    # Flection: Tense
    EVT_RADIOBUTTON( $self, $self->{rad_tense_none}, \&analyzed_tense );
    EVT_RADIOBUTTON( $self, $self->{rad_tense_present}, \&analyzed_tense );
    EVT_RADIOBUTTON( $self, $self->{rad_tense_past_participle}, \&analyzed_tense );
    EVT_RADIOBUTTON( $self, $self->{rad_tense_other}, \&analyzed_tense );
    
    # Flection: Person
    EVT_RADIOBUTTON( $self, $self->{rad_person_none}, \&analyzed_person );
    EVT_RADIOBUTTON( $self, $self->{rad_person_first}, \&analyzed_person );
    EVT_RADIOBUTTON( $self, $self->{rad_person_second}, \&analyzed_person );
    EVT_RADIOBUTTON( $self, $self->{rad_person_third}, \&analyzed_person );
    
    # Flection: SV-Agreement
    EVT_RADIOBUTTON( $self, $self->{rad_sv_agreement_correct}, \&analyzed_sv_agreement );
    EVT_RADIOBUTTON( $self, $self->{rad_sv_agreement_incorrect}, \&analyzed_sv_agreement );       
    
    # Flection: Verbmarker
    EVT_CHOICE( $self, $self->{cho_verbmarker_present}, \&analyzed_verbmarker );
    EVT_CHOICE( $self, $self->{cho_verbmarker_past_participle}, \&analyzed_verbmarker );       
    
    # Structure
    EVT_RADIOBUTTON( $self, $self->{rad_structure_none}, \&analyzed_structure );
    EVT_RADIOBUTTON( $self, $self->{rad_structure_two}, \&analyzed_structure );
    EVT_RADIOBUTTON( $self, $self->{rad_structure_two_verb}, \&analyzed_structure );
    EVT_RADIOBUTTON( $self, $self->{rad_structure_more_inf}, \&analyzed_structure );
    EVT_RADIOBUTTON( $self, $self->{rad_structure_more_vtwo_conj}, \&analyzed_structure );
    EVT_RADIOBUTTON( $self, $self->{rad_structure_more_vtwo_aux}, \&analyzed_structure );
    EVT_RADIOBUTTON( $self, $self->{rad_structure_more_other}, \&analyzed_structure );
    EVT_RADIOBUTTON( $self, $self->{rad_structure_complex}, \&analyzed_structure );
    
    # Case agreement
    EVT_TEXT( $self, $self->{txt_cagreement_acc_acc}, \&analyzed_case_agreement );
    EVT_TEXT( $self, $self->{txt_cagreement_acc_nom}, \&analyzed_case_agreement );
    EVT_TEXT( $self, $self->{txt_cagreement_dat_dat}, \&analyzed_case_agreement );
    EVT_TEXT( $self, $self->{txt_cagreement_dat_nom}, \&analyzed_case_agreement );
    EVT_TEXT( $self, $self->{txt_cagreement_dat_acc}, \&analyzed_case_agreement );
    
    # Elision
    EVT_CHECKBOX( $self, $self->{chk_elision_subject}, \&analyzed_elision );
    EVT_CHECKBOX( $self, $self->{chk_elision_article}, \&analyzed_elision );
    EVT_CHECKBOX( $self, $self->{chk_elision_verb}, \&analyzed_elision );
    EVT_CHECKBOX( $self, $self->{chk_elision_copular}, \&analyzed_elision );
    EVT_CHECKBOX( $self, $self->{chk_elision_auxiliary}, \&analyzed_elision );
    EVT_CHECKBOX( $self, $self->{chk_elision_preposition}, \&analyzed_elision );
    
    # Subject verb inversion
    EVT_CHECKBOX( $self, $self->{chk_svi_used}, \&analyzed_svi );
    EVT_RADIOBUTTON( $self, $self->{rad_svi_question}, \&analyzed_svi );
    EVT_RADIOBUTTON( $self, $self->{rad_svi_topicalization}, \&analyzed_svi );
    EVT_RADIOBUTTON( $self, $self->{rad_svi_correct}, \&analyzed_svi );
    EVT_RADIOBUTTON( $self, $self->{rad_svi_incorrect}, \&analyzed_svi );
}

sub attach_help_events {
    my $self = shift;       
    
    # Wordclasses
    EVT_RIGHT_UP( $self->{rad_wordclass_none}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_wordclass_noun}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_wordclass_article}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_wordclass_adjective}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_wordclass_pronoun_personal}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_wordclass_pronoun_other}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_wordclass_verb}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_wordclass_auxiliary}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_wordclass_modal}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_wordclass_copular}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_wordclass_adverb}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_wordclass_preposition}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_wordclass_conjunction}, \&Liane::Help::help );
    
    # Flection: Number
    EVT_RIGHT_UP( $self->{rad_number_none}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_number_singular}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_number_plural}, \&Liane::Help::help );
    
    # Flection: Case
    EVT_RIGHT_UP( $self->{rad_case_none}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_case_nominative}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_case_genitive}, \&Liane::Help::help );    
    EVT_RIGHT_UP( $self->{rad_case_dative}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_case_accusative}, \&Liane::Help::help );
    
    # Flection: Gender
    EVT_RIGHT_UP( $self->{rad_gender_none}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_gender_masculine}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_gender_feminine}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_gender_neuter}, \&Liane::Help::help );
    
    # Flection: Tense
    EVT_RIGHT_UP( $self->{rad_tense_none}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_tense_present}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_tense_past_participle}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_tense_other}, \&Liane::Help::help );
    
    # Flection: Person
    EVT_RIGHT_UP( $self->{rad_person_none}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_person_first}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_person_second}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_person_third}, \&Liane::Help::help );
    
    # Flection: SV-Agreement
    EVT_RIGHT_UP( $self->{rad_sv_agreement_correct}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_sv_agreement_incorrect}, \&Liane::Help::help );       
    
    # Flection: Verbmarker
    EVT_RIGHT_UP( $self->{cho_verbmarker_present}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{cho_verbmarker_past_participle}, \&Liane::Help::help );       
    
    # Structure
    EVT_RIGHT_UP( $self->{rad_structure_none}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_structure_two}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_structure_two_verb}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_structure_more_inf}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_structure_more_vtwo_conj}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_structure_more_vtwo_aux}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_structure_more_other}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_structure_complex}, \&Liane::Help::help );
    
    # Case agreement
    EVT_RIGHT_UP( $self->{lbl_cagreement_acc_acc}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{lbl_cagreement_acc_nom}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{lbl_cagreement_dat_dat}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{lbl_cagreement_dat_nom}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{lbl_cagreement_dat_acc}, \&Liane::Help::help );
    
    # Elision
    EVT_RIGHT_UP( $self->{chk_elision_subject}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{chk_elision_article}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{chk_elision_verb}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{chk_elision_copular}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{chk_elision_auxiliary}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{chk_elision_preposition}, \&Liane::Help::help );
    
    # Subject verb inversion
    EVT_RIGHT_UP( $self->{chk_svi_used}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_svi_question}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_svi_topicalization}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_svi_correct}, \&Liane::Help::help );
    EVT_RIGHT_UP( $self->{rad_svi_incorrect}, \&Liane::Help::help );
}

1;
