package Liane::Wx::AddTranscript;

use strict;
use warnings;
use utf8;

use Wx qw( :everything );
use Wx::Event qw( :everything );    
use Wx::XRC;

our @ISA = qw( Liane::Wx::FBP::AddTranscript );
use Liane::Wx::FBP::AddTranscript;

sub new {
    my $class  = shift;
    my $parent = shift;  
    
    # Create the new transcript dialog
    # and center it on screen.
    my $self = Liane::Wx::FBP::AddTranscript->new( $parent );
    $self->CenterOnScreen;        
    
	######################################
	# Instance variable initializatition
	######################################        
    # CAVE: these come by reference!
    $self->{date}       = shift;
    $self->{situation}  = shift;  
    
    ######################################
    # GUI preparation
    ######################################
    
    $self->{btn_ok}->SetBitmap(
        Wx::Bitmap->new( './Liane/Ressources/save_30.ico', wxBITMAP_TYPE_ICO ) );

    $self->{btn_cancel}->SetBitmap(
        Wx::Bitmap->new( './Liane/Ressources/cancel_30.ico', wxBITMAP_TYPE_ICO ) );
    
    ######################################
    # EVT handling
    ######################################
    
    EVT_BUTTON( $self, $self->{btn_ok},     \&add_transcript );
    EVT_BUTTON( $self, $self->{btn_cancel}, \&cancel );

    EVT_TEXT_ENTER( $self, $self->{txt_situation}, \&add_transcript );

    EVT_CLOSE( $self, \&cancel );

    ######################################
    # Finale
    ######################################

    return $self;
}

sub add_transcript {
    my $self  = shift;
    my $event = shift;
    
    if ( not &_all_fields_filled( $self ) ) {
        Liane::Wx::Dialog->message( 'Es müssen alle Felder ausgefüllt werden!', 'Transkript anlegen' );
        return;
    }
    
    &_set_return_data( $self );
    &_close_window( $self, 1 );    
}

sub cancel {
    my $self  = shift;
    my $event = shift;
    
    &_close_window( $self, 0 );
}

######################################################################
# Private functions

sub _close_window {
    my $self    = shift;
    my $ret_val = shift;

    $self->EndModal( $ret_val );
    $self->Destroy;
}

sub _all_fields_filled {
    my $self = shift;

    return 1 unless ( 
        # FIXME: is this check necessary?
        #$self->{dat_date}->GetValue eq '' or
        $self->{txt_situation}->GetValue eq '' 
    );
    
    return;
}

sub _set_return_data {
    my $self = shift;    
    
    # Use $ { $self->{...} } to dereference!
    ${ $self->{date} }       = 
        Liane::DateTime::wxdt2tt( $self->{dat_date}->GetValue );
    ${ $self->{situation} }  = $self->{txt_situation}->GetValue;
}

1;
