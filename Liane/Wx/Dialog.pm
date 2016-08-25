package Liane::Wx::Dialog;

use strict;
use warnings;
use utf8;

use Wx qw(:everything);
use Wx::Event qw(:everything);

sub message {
	my $self    = shift;
	my $message = shift;
	my $title   = shift || 'Information';
	
	Wx::MessageBox( $message, $title );
	
	return;
}

sub help {
	my $self    = shift;
	my $message = shift;
	my $title   = shift || 'Hilfe';
	
	Wx::MessageBox( $message, $title, wxICON_INFORMATION );
	
	return;
}

sub error {
	my $self    = shift;
	my $message = shift || 'Unbekannter Fehler';
	my $title   = shift || 'Unbekannter Fehler';
	
	Wx::MessageBox( $message, $title, wxICON_EXCLAMATION );
	
	return;
}

sub yes_no {
	my $self    = shift;
	my $liane   = shift;
	my $message = shift;
	my $title   = shift || 'Frage';
	
	my $dialog  = Wx::MessageDialog->new( $liane, $message, $title,	wxYES_NO | wxYES_DEFAULT | wxICON_QUESTION, );

	my $result = ( $dialog->ShowModal == wxID_YES ) ? 1 : 0;
	$dialog->Destroy;

	return $result;
}

1;
