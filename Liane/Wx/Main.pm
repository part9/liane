package Liane::Wx::Main;

use strict;
use warnings;
use utf8;

use Wx qw( :everything );
use Wx::Event qw( :everything );
use Wx::Calendar;
use Wx::DateTime;

use Liane::DateTime;

use Liane::DB;
use Liane::DB::LianeFile;

use Liane::File;

use Liane::List;

use Liane::Profile;

use Liane::Wx::Analyzer;
use Liane::Wx::Dialog;
use Liane::Wx::Editor;
use Liane::Wx::AddTranscript;

our @ISA = qw( Liane::Wx::FBP::Main );
use Liane::Wx::FBP::Main;

sub new {
    my $class = shift;

    my $self = Liane::Wx::FBP::Main->new;
    $self->CentreOnScreen;
    
	######################################
	# Instance variable initializatition
	######################################    

    $self->{DB} = Liane::DB::LianeFile->new;

    ######################################
    # GUI preparation
    ######################################
    
    # Failed with 'No image handler for type nn defined.'
    # on windows - this fixes it.
    Wx::InitAllImageHandlers;
    
    # Title Bar Icon
    $self->SetIcon( Wx::Icon->new( './Liane/Ressources/icon.ico', wxBITMAP_TYPE_ICO ) );
    
    # Load that beautiful image that makes all the difference!
    my $bmp = Wx::Bitmap->new( './Liane/Ressources/banner.png', wxBITMAP_TYPE_PNG );
    $self->{m_bitmapSide}->SetBitmap( $bmp );
    
    $self->{btn_add_transcript}->SetBitmap(
        Wx::Bitmap->new( './Liane/Ressources/new_48.ico', wxBITMAP_TYPE_ICO ) );
        
    $self->{btn_edit_transcript}->SetBitmap(
        Wx::Bitmap->new( './Liane/Ressources/edit_48.ico', wxBITMAP_TYPE_ICO ) );
    
    $self->{btn_delete_transcript}->SetBitmap(
        Wx::Bitmap->new( './Liane/Ressources/delete_48.ico', wxBITMAP_TYPE_ICO ) );
    
    $self->{btn_analyze_transcript}->SetBitmap(
        Wx::Bitmap->new( './Liane/Ressources/analyze_48.ico', wxBITMAP_TYPE_ICO ) );
        
    $self->{btn_show_profile}->SetBitmap(
        Wx::Bitmap->new( './Liane/Ressources/profile_48.ico', wxBITMAP_TYPE_ICO ) );
        
    # List control columns
    $self->{lst_transcripts}->InsertColumn( 0, 'Datum', wxLIST_FORMAT_LEFT, 90 );
    $self->{lst_transcripts}->InsertColumn( 1, 'Situation', wxLIST_FORMAT_LEFT, 505 );    
    
    ######################################
    # EVT handling
    ######################################
    
    # File-Menu
    # TODO: Do something about these IDs maybe?
    # It works but wxID_New would be nicer?
    EVT_MENU( $self, 11, \&new_file ); 
    EVT_MENU( $self, 12, \&open_file );
    EVT_MENU( $self, 13, \&save_file );
    EVT_MENU( $self, 14, \&save_file_as );
    EVT_MENU( $self, 15, \&quit_liane );

    # Help-Menu
    EVT_MENU( $self, 21, \&show_about );
    
    # When closing the Window:
    EVT_CLOSE( $self, \&quit_liane );
    
    # Buttons on the Frame
    EVT_BUTTON( $self, $self->{btn_add_transcript},    \&add_transcript );
    EVT_BUTTON( $self, $self->{btn_edit_transcript},   \&edit_transcript );
    EVT_BUTTON( $self, $self->{btn_delete_transcript}, \&delete_transcript );
    EVT_BUTTON( $self, $self->{btn_analyze_transcript}, \&analyze_transcript );
    EVT_BUTTON( $self, $self->{btn_show_profile},      \&show_profile );
    
    # Whenever text controls change:
    EVT_TEXT( $self, $self->{txt_name},        \&data_changed );
    EVT_TEXT( $self, $self->{txt_phonenumber}, \&data_changed );
    EVT_TEXT( $self, $self->{txt_institution}, \&data_changed );
    EVT_TEXT( $self, $self->{txt_notes},       \&data_changed );
    
    # When the date changes:
    EVT_DATE_CHANGED( $self, $self->{dat_birthdate}, \&data_changed );    
    
    EVT_LIST_ITEM_SELECTED(   $self, $self->{lst_transcripts}, \&transcript_selected );
    EVT_LIST_ITEM_DESELECTED( $self, $self->{lst_transcripts}, \&transcript_deselected );
    EVT_LIST_ITEM_ACTIVATED(  $self, $self->{lst_transcripts}, \&edit_transcript );

    ######################################
    # Finale
    ######################################
   
    &transcript_gui_enable( $self, 0 );
    
    $self->Show( 1 );   
    
    return $self;    
}

######################################################################
# EVT_MENU functions
#
# Each of the following subs
# is associated with one of the menu
# items of the top menu.

# File > New
# Reset db (garbage collector takes care of old, unreferenced data :).
sub new_file {
    my( $self, $event ) = @_;
    
    # Don't discard changes unwillingly.
    return unless &save_if_changed( $self );
    
    $self->{DB} = Liane::DB::LianeFile->new;
    
    # Clear gui by giving this the empty db;
    &db_to_gui( $self );
    $self->{DB}->changed( 0 );
    
    &transcript_gui_enable( $self, 0 );    
}

# File > Open
# Open file, set db and show data.
sub open_file {
    my ( $self, $event ) = @_;
    my $db;
    
    # Don't discard changes unwillingly.
    return unless &save_if_changed( $self );
    
    # open_file needs $self as parent for Wx::FileDialog.
    eval { $db = Liane::File->open_file( $self ) };
    # $@ is set if exception has been thrown.
    if ( $@ ) { Liane::Wx::Dialog->error(
        "Beim Öffnen der Akte ist ein Fehler aufgetreten: $@", 
        'Fehler beim Öffnen' 
    ) }
    
    # $db is not defined after user cancellation
    # or opening an invalid file.
    return unless defined $db;
    
    # IMPORTANT: save reference to db
    # globally or it's lost forever!
    $self->{DB} = $db;
    &db_to_gui( $self );
    # Set changed to 0, because db_to_gui touches
    # the text fields so they set changed to 1!
    $self->{DB}->changed( 0 );
    
    # Now adding transcripts is ok.
    $self->{btn_add_transcript}->Enable;
}

# File > Save
# Saves db to db->filename.
# db is always set, initially 
# as empty new Liane::DB::LianeFile.
sub save_file {
    my ( $self, $event ) = @_;

    # Reasons to return...
    # ...1: no changes to be saved.
    return unless $self->{DB}->changed;
    # ...2: no proper name of the child provided.
    if ( ! &name_is_ok( $self->{txt_name}->GetValue ) ) {
        Liane::Wx::Dialog->message( 'Bitte einen Namen angeben.', 'Akte speichern' );
        return 0;
    }
    # ...3: filename is empty (e.g. this is a new file).
    if ( $self->{DB}->filename eq '' ) {
        return &save_file_as( $self, $event );
    }
    
    # File can be saved / created.
    
    &gui_to_db( $self );
    eval { Liane::File->save_file( $self, $self->{DB} ) };    
    # $@ is set if exception has been thrown.
    if ( $@ ) {
        Liane::Wx::Dialog->error(
            "Beim Speichern der Akte ist ein Fehler aufgetreten: $@", 
            'Fehler beim Speichern'
        );
        return 0;
    }    
    
    $self->{DB}->changed( 0 );

    return 1;
}

# File > Save as
# Requests new db->filename and saves db
# using save_file thereafter.
sub save_file_as {
    my ( $self, $event ) = @_;
    
    # Reasons to return...
    # ...1: no changes to be saved.
    return unless $self->{DB}->changed;
    # ...2: no proper name of the child provided.
    if ( ! &name_is_ok( $self->{txt_name}->GetValue ) ) {
        Liane::Wx::Dialog->message( 'Bitte einen Namen angeben.', 'Akte speichern' );
        return 0;
    }
    
    # User is being asked, if he wants
    # to overwrite existing file (1 as 4th arg).
    my $filename = Liane::File->get_new_filename( $self, 'Akte speichern unter', '*.ldb', 1 );
    # Return if user cancelld.
    return unless defined $filename;       
    
    $self->{DB}->filename( $filename );
    # Call &save_file for the newly set db->filename
    &save_file( $self, $event );        
    
    # Now adding transcripts is ok.
    $self->{btn_add_transcript}->Enable;   
    
    return 1;
}

# File > Quit
sub quit_liane {
    my ( $self, $event ) = @_;

    # Don't discard changes unwillingly.
    return unless &save_if_changed( $self );
    
    &Wx::wxTheApp->ExitMainLoop;
}

# Help > About
sub show_about {
    my ( $self, $event ) = @_;

    Wx::MessageBox(
        "This is liane $main::VERSION of $main::DATE.\n" .
        "Growing and developing since 05/31/2015.\n\n".
        "For more information please contact:\n".
        "liane\@piratenwind.de.\n\n" . 
        "Or visit us on GitHub at:\n" .
        "https://github.com/part9", 'Info' );
}


######################################################################
# EVT_BUTTON functions
#
# Each of the following subs
# is associated with one of the
# buttons on the main frame.

# Uses the AddTranscript dialog to add
# a new transcript to the db; refreshes
# gui thereafter.
sub add_transcript {
    my ( $self, $event ) = @_;    
    my ( $date, $situation );
    
    $self->Disable;
    
    # Create the AddTranscript-dialog and
    # hand it variables by reference.
    my $dialog = Liane::Wx::AddTranscript->new( $self, \$date, \$situation );
    
    # ShowModal shows the dialog and waits
    # right here for the return value!
    my $ret_val = $dialog->ShowModal;
    
    $self->Enable;
    $self->Raise;
    
    # User cancelled.
    return if $ret_val == 0;
    
    # Add the returned transcript values to
    # db and mark it changed.
    $self->{DB}->add_transcript( $date, $situation );
    $self->{DB}->changed( 1 );
    
    # Write text fields to db first, otherwise
    # changes will be overwritten by db_to_gui.
    # Using db_to_gui instead of adding the newly
    # created transcript to the listbox oneself
    # is more convenient, though (e.g. disables
    # the buttons).
    &gui_to_db( $self );
    &db_to_gui( $self );
}

sub edit_transcript {
    my ( $self, $event ) = @_;
    
    my $id = Liane::List->get_selected_index( $self->{lst_transcripts} );
    
    $self->Disable;

    # Create the Editor-dialog.
    my $dialog     = Liane::Wx::Editor->new( 
        $self, \$self->{DB}->transcripts->[$id] );
        
    # ShowModal shows the dialog and waits
    # right here for the return value!
    my $ret_val = $dialog->ShowModal;
    
    $self->Enable;
    $self->Raise;
    
    # User canceled and did not want
    # any changes saved or did not make any.
    return if $ret_val == 0;    
    
    # Changes were being made and are supposed
    # to be saved.
    $self->{DB}->changed( 1 );    
    &db_to_gui( $self );    
}

# Removes the selected transcript from
# the db and refreshes gui thereafter.
sub delete_transcript {
    my ( $self, $event ) = @_;
    
    return unless Liane::Wx::Dialog->yes_no( $self, 'Das ausgewählte Transkript wirklich löschen?', 'Transkript löschen' );
    
    my $list_id = Liane::List->get_selected_index( $self->{lst_transcripts} );
    
    # Remove the selected transcript from
    # db and mark the db changed.
    # CAVE: transcript list has no unique identifiers,
    # we just use the listindex because it should be
    # the same as the elements position in the actual array.
    # This is 'taken care of' by db_to_gui using
    # db->list_transcripts.
    $self->{DB}->delete_transcript( $list_id );
    $self->{DB}->changed( 1 );

    # Write text fields to db first, otherwise
    # changes will be overwritten by db_to_gui.
    # Using db_to_gui instead of deleting the
    # selected listitem oneself is more convenient,
    # though (e.g. disables the buttons).    
    &gui_to_db( $self );
    &db_to_gui( $self );    
}

sub analyze_transcript {
    my ( $self, $event ) = @_;
    
    my $id = Liane::List->get_selected_index( $self->{lst_transcripts} );
    
    # Don't start analyzer for empty transcripts.
    # I know this opens for transcripts that contain
    # e.g. only one comment. It's okay.
    if ( scalar( @{ $self->{DB}->transcripts->[$id]->utterances } ) == 0 ) {
        Liane::Wx::Dialog->message(
            "Das ausgewählte Transkript enthält\n" .
            "keine Äußerungen. Eine Analyse ist\n" .
            "nicht möglich.",
            'Transkript analysieren' );
        return;
    }
            
    $self->Disable;   

    # Create the Editor-dialog.
    my $dialog     = Liane::Wx::Analyzer->new( $self,
        \$self->{DB}->transcripts->[$id] );
        
    # ShowModal shows the dialog and waits
    # right here for the return value!
    my $ret_val = $dialog->ShowModal;
    
    $self->Enable;
    $self->Raise;
    
    # User cancelled..
    return if $ret_val == 0;

    # <> 0 is only returned when user clicked
    # ok and the transcript data has changed.
    $self->{DB}->changed( 1 );    
    &db_to_gui( $self );
}

sub show_profile {
    my ( $self, $event ) = @_;
        
    my $id = Liane::List->get_selected_index( $self->{lst_transcripts} );    
    
    my $file = Liane::File->get_new_filename( $self, 'Profil speichern unter', '*.pdf', 1 );
    return unless defined $file;      
    
    # Creates profile for current student
    # and selected transript.
    my $profile;
    eval {
        $profile = Liane::Profile->create_profile(
            $self->{DB}->student,
            $self->{DB}->transcripts->[$id] );
     };
    if ( $@ ) {
        Liane::Wx::Dialog->error( "Fehler beim Erstellen des Profils: $@", "Fehler beim Erstellen des Profils." );
    };
    
    # Save newly created profile
    # using profile.pdf as template.
    eval {
        Liane::Profile->save_profile(
            $profile,
            './Liane/Ressources/profile.pdf',
            $file )
    };
    if ( $@ ) {
        Liane::Wx::Dialog->error( "Fehler beim Exportieren: $@", "Fehler beim Exportieren" );
    };
}
 
######################################################################
# EVT_TEXT
#
# Called after any of the text-controls
# has changed. This change can be initiated
# by either the user OR the software!
sub data_changed {
    my ( $self, $event ) = @_;
    $self->{DB}->changed( 1 );
}

######################################################################
# EVT_LIST functions

sub transcript_selected {
    my ( $self, $event ) = @_;
    
    # Homegrown single-selection implementation
    # because wxWidgets stuff does not work.
    Liane::List->deselect_all_but_this_item(
        $self->{lst_transcripts}, $event->GetIndex );
    
    # Enable the buttons for transcript
    # modification.
    &transcript_buttons_enable( $self, 1 );
    
}

# Disable buttons whenever list item is deselected.
# I know this is fired by deselection of
# transcript_selected, too, but oh well...
sub transcript_deselected {
    my ( $self, $event ) = @_;
    
    &transcript_buttons_enable( $self, 0 );
}


######################################################################
# More functions

sub name_is_ok {
    my $name = shift;
    
    # Strip all spaces
    $name =~ s/\s//g;
    
    return if length( $name ) < 2;
    
    return 1;    
}

sub transcript_gui_enable {
    my ( $self, $enable ) = @_;
    
    $self->{btn_add_transcript}->Enable( $enable );    
    transcript_buttons_enable( $self, $enable );
}

sub transcript_buttons_enable {
    my ( $self, $enable ) = @_;

    $self->{btn_edit_transcript}->Enable( $enable );
    $self->{btn_delete_transcript}->Enable( $enable ); 
    $self->{btn_analyze_transcript}->Enable( $enable );   
    $self->{btn_show_profile}->Enable( $enable );

}

# If db->changed asks user, if changes should be saved.
# This returns undef if user cancelled somwhere during
# that process to prevent dataloss! Makes cancelling the 
# Save File As... Dialog cancelling Exit/New File etc.
# as well possible.
sub save_if_changed {
    my $self = shift;
    
    return 1 unless $self->{DB}->changed;
    return 1 unless Liane::Wx::Dialog->yes_no( $self, 'Änderungen an dieser Akte speichern?', 'Nicht gespeicherte Änderungen' );
    return &save_file( $self );
}
  
######################################################################
# DB-GUI-Interaction

# Loads db values into gui controls.
sub db_to_gui {
    my $self = shift;
    my $db   = shift || $self->{DB};
    
    # Setting the text fields is easy.
    $self->{txt_name}->SetValue( $db->student->name );
    $self->{txt_phonenumber}->SetValue( $db->student->phonenumber );
    $self->{txt_institution}->SetValue( $db->student->institution );
    $self->{txt_notes}->SetValue( $db->student->notes );    
    
    # Birthdate is saved in ticks, so convert
    # to Wx::DateTime before setting it.
    $self->{dat_birthdate}->SetValue(
            Liane::DateTime::tt2wxdt( $db->student->birthdate ) );    

    # Disable buttons for transcript modification, 
    # because we will lose the current selection anyways.    
    $self->{btn_edit_transcript}->Disable;
    $self->{btn_show_profile}->Disable;
    $self->{btn_delete_transcript}->Disable;
    $self->{btn_analyze_transcript}->Disable;
    
    # Delete all items and insert the ones we got
    # from list_transcripts. (Nota bene: AppendItem
    # does not seem to work here).
    $self->{lst_transcripts}->DeleteAllItems;
    
    # Get all transcripts of current db.
    my @transcripts = $db->list_transcripts;    
        
    my $id   = 0;
    foreach my $transcript (@transcripts)
    {               
        $self->{lst_transcripts}->InsertStringItem( $id,  @{ $transcript }[0] );
        $self->{lst_transcripts}->SetItem( $id, 1,        @{ $transcript }[1] );
        
        $id++;
    }
    
}
 
# Stores data from gui text fields to $db
sub gui_to_db {
    my $self = shift;
    my $db   = shift || $self->{DB};
    
    # Retrieving the text fields is easy.
    $db->student->name(        $self->{txt_name}->GetValue        );
    $db->student->phonenumber( $self->{txt_phonenumber}->GetValue );
    $db->student->institution( $self->{txt_institution}->GetValue );
    $db->student->notes(       $self->{txt_notes}->GetValue       );    
    
    # Convert the DatePickers Wx::DateTime to ticks
    # before storing that in the db!
    $db->student->birthdate(
            Liane::DateTime::wxdt2tt( $self->{dat_birthdate}->GetValue ) );    
}
    
1;
