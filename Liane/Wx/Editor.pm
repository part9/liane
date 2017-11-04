package Liane::Wx::Editor;

use strict;
use warnings;
use utf8;

use Liane::List;

use Wx qw( :everything );
use Wx::Event qw( :everything );

our @ISA = qw( Liane::Wx::FBP::Editor );
use Liane::Wx::FBP::Editor;

sub new {
    my $class  = shift;
    my $parent = shift;    
    # CAVE: this comes by referenc!
	my $transcript = shift;
	
    my $self = Liane::Wx::FBP::Editor->new( $parent );
    $self->CenterOnScreen;      		
	
	######################################
	# Instance variable initializatition
	######################################
	
    # Save reference to the hot transcript.
    $self->{transcript} = $transcript;
    # Clone working copy of transcript.
    $self->{transcript_clone} = ${ $self->{transcript} }->clone;
    
    # Set speaker names for child, other and comment.
    # FIXME: this should be done more globally,
    # because it will be needed by the analyzer
    # (to determine which utterance to analyze).
    # Like some CONSTANT shit i think.
    my %speakers = ( child   => '*KIN',
                     other   => '*AND',
                     comment => '%com' );
    $self->{speakers} = \%speakers;
    
    ######################################
    # GUI preparation
    ######################################
         
    # Load the charming button bitmaps
    $self->{btn_ok}->SetBitmap(
        Wx::Bitmap->new( './Liane/Ressources/save_30.ico', wxBITMAP_TYPE_ICO ) );

    $self->{btn_cancel}->SetBitmap(
        Wx::Bitmap->new( './Liane/Ressources/cancel_30.ico', wxBITMAP_TYPE_ICO ) );        
    
    $self->{btn_add_utterance}->SetBitmap(
        Wx::Bitmap->new( './Liane/Ressources/add.ico', wxBITMAP_TYPE_ICO )
                                          );
    $self->{btn_update_utterance}->SetBitmap(
        Wx::Bitmap->new( './Liane/Ressources/update.ico', wxBITMAP_TYPE_ICO )
                                          );
    $self->{btn_delete_utterance}->SetBitmap(
        Wx::Bitmap->new( './Liane/Ressources/delete.ico', wxBITMAP_TYPE_ICO )
                                          );                                              
    # List control columns
    $self->{lst_utterances}->InsertColumn( 0, 'Sprecher', wxLIST_FORMAT_LEFT, 70 );
    $self->{lst_utterances}->InsertColumn( 1, 'Äußerung', wxLIST_FORMAT_LEFT, 460 );
    
    ######################################
    # EVT handling
    ######################################
    
    # lst_utterances    
    EVT_LIST_ITEM_SELECTED(   $self, $self->{lst_utterances}, \&utterance_selected   );
    EVT_LIST_ITEM_DESELECTED( $self, $self->{lst_utterances}, \&utterance_deselected );
        
    # 
    EVT_DATE_CHANGED( $self, $self->{dat_date}, \&data_changed );    
    EVT_TEXT( $self, $self->{txt_situation},    \&data_changed );   
    
    EVT_BUTTON( $self, $self->{btn_ok},     \&save_transcript );
    EVT_BUTTON( $self, $self->{btn_cancel}, \&cancel );
    
    # utterance buttons (add, change, delete)
    EVT_BUTTON( $self, $self->{btn_add_utterance},    \&add_utterance );
    EVT_BUTTON( $self, $self->{btn_update_utterance}, \&update_utterance );
    EVT_BUTTON( $self, $self->{btn_delete_utterance}, \&delete_utterance );
    
    EVT_TEXT_ENTER( $self, $self->{txt_utterance}, \&add_utterance );

    EVT_CLOSE( $self, \&cancel );
    
    ######################################
    # Finale
    ######################################
    
    &db_to_gui( $self );
    $self->{changed} = 0;
   
    return $self;
}

######################################################################
# EVT_BUTTON

sub save_transcript {
    my $self = shift;
    
    &gui_to_db( $self ) unless $self->{changed} == 0;
    
    # This makes the return value = 0 when 
    # user clicks ok but did not change anything.
    &close_window( $self, $self->{changed} );
}

sub cancel {
    my $self = shift;
    
    if ( $self->{changed} == 1 ) {
        if ( Liane::Wx::Dialog->yes_no( $self, 
                'Änderungen an diesem Transkript speichern?',
                'Nicht gespeicherte Änderungen' ) ) {
            &save_transcript( $self );
            return;
        }
    }
    
    &close_window( $self, 0 );
}

######################################################################
# EVT_TEXT
#
# Called after any of the text-controls
# has changed. This change can be initiated
# by either the user OR the software!
sub data_changed {
    my ( $self, $event ) = @_;
    $self->{changed} = 1;
}

######################################################################
# Utterance Buttons

# Add utterance to the end  of the list.
sub add_utterance {
    my $self = shift;
    
    # Collect data
    my $id      = $self->{lst_utterances}->GetItemCount;    
    my $speaker = &get_selected_speaker( $self );
    my $text    = $self->{txt_utterance}->GetValue;
    
    # Empty utterance? No!
    return if $text eq '';
    
    # Add to list
    $self->{lst_utterances}->InsertStringItem( $id, $speaker );
    $self->{lst_utterances}->SetItem( $id, 1, $text );
    
    # Add to transcript_clone
    $self->{transcript_clone}->add_utterance( $speaker, $text );
    
    $self->{txt_utterance}->SetValue( '' );
    
    $self->{changed} = 1;
}

# Update speaker and utterance
# of selected utterance.
sub update_utterance {
    my $self = shift;
    
    # Collect data
    my $id      = Liane::List->get_selected_index( $self->{lst_utterances} );    
    my $speaker = &get_selected_speaker( $self );
    my $text    = $self->{txt_utterance}->GetValue;

    # Empty utterance? No!
    return if $text eq '';   
    
    # Update list
    $self->{lst_utterances}->SetItem( $id, 0, $speaker );
    $self->{lst_utterances}->SetItem( $id, 1, $text );    
    
    # Update transcript_clone
    $self->{transcript_clone}->update_utterance( $id, $speaker, $text );
    
    $self->{changed} = 1;    
}

# Delete selected utterance
# from lst_utterances.
sub delete_utterance {
    my $self = shift;
    
    # Collect data
    my $id = Liane::List->get_selected_index( $self->{lst_utterances} );
        
    # Delete from list
    $self->{lst_utterances}->DeleteItem( $id );
    
    # Delete from transcript_clone
    $self->{transcript_clone}->delete_utterance( $id );
    
    # No item is selected after deletion,
    # so disabling the buttons seems like
    # a good idea. Moving the selection
    # to the next item might be an 
    # improvement for further releases.
    &utterance_deselected( $self ); 
    
    $self->{changed} = 1;   
}

######################################################################
# EVT_LIST functions

sub utterance_selected {
    my ( $self, $event ) = @_;

    # Homegrown single-selection implementation
    # because wxWidgets stuff does not work.
    Liane::List->deselect_all_but_this_item(
        $self->{lst_utterances}, $event->GetIndex );
    
    # Enable the buttons for utterance
    # modification.
    $self->{btn_update_utterance}->Enable;
    $self->{btn_delete_utterance}->Enable;

    # Get speaker of selected utterance
    # and set the radio buttons accordingly.
    &set_selected_speaker( $self, $event->GetText );
    
    # Set txt_utterance control to selected
    # utterance - GetItemText does not work.
    my $utterance = $self->{lst_utterances}->GetItem( $event->GetIndex, 1 )->GetText;
    $self->{txt_utterance}->SetValue( $utterance );
}

# Disable buttons whenever list item is deselected.
# I know this is fired by deselection of
# utterance_selected, too, but oh well...
sub utterance_deselected {
    my ( $self, $event ) = @_;
        
    $self->{btn_update_utterance}->Disable;
    $self->{btn_delete_utterance}->Disable;
    
    $self->{txt_utterance}->SetValue( '' );    
}

######################################################################
# DB-GUI-Interaction (of Liane::DB::Transcript type)
# (only the transcript part of the db of course)

sub db_to_gui {
    my $self = shift;

    $self->{dat_date}->SetValue(
        Liane::DateTime::tt2wxdt( $self->{transcript_clone}->date ) );
    $self->{txt_situation}->SetValue( $self->{transcript_clone}->situation );
    $self->{txt_utterance}->SetFocus;
    
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

# Save everything to the db: by copy the
# clone to the hot transcript.
sub gui_to_db {
    my $self = shift;  
    
    # Save date and situation description to
    # clone, because actual 'saving' is done in
    # the next step.
    $self->{transcript_clone}->date(
        Liane::DateTime::wxdt2tt( $self->{dat_date}->GetValue ) );
    $self->{transcript_clone}->situation( $self->{txt_situation}->GetValue );
    
    # FIXME maybe.
    # I want the change the reference, but that does not
    # seem to work - maybe, because ANALYSIS is not cloned
    # by transcript->clone yet? Or simply stupid?
    #$self->{transcript} = \{ $self->{transcript_clone} };
    # Simply copying it works fine, though.
    ${ $self->{transcript} } = $self->{transcript_clone};
}    

######################################################################
# Private functions

# Returns the name of the speaker
# according to the selected
# radio button.
sub get_selected_speaker {
    my $self = shift;
    my $speaker;
    
    $speaker = $self->{speakers}->{child}    if ( $self->{rad_spkr_child}->GetValue );
    $speaker = $self->{speakers}->{other}    if ( $self->{rad_spkr_other}->GetValue );
    $speaker = $self->{speakers}->{comment}  if ( $self->{rad_spkr_comment}->GetValue );
    
    return $speaker;
}

sub set_selected_speaker {
    my $self    = shift;
    my $speaker = shift;
    
    $self->{rad_spkr_child}->SetValue(   $speaker eq $self->{speakers}->{child} );
    $self->{rad_spkr_other}->SetValue(   $speaker eq $self->{speakers}->{other} );
    $self->{rad_spkr_comment}->SetValue( $speaker eq $self->{speakers}->{comment} );    
}

sub close_window {
    my $self    = shift;
    my $ret_val = shift;

    $self->EndModal( $ret_val );
    $self->Destroy;
}

1;
