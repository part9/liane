package Liane::Wx::FBP::AddTranscript;

use 5.008005;
use utf8;
use strict;
use warnings;
use Wx 0.98 ':everything';
use Wx::DateTime ();

our $VERSION = '0.01';
our @ISA     = 'Wx::Dialog';

sub new {
	my $class  = shift;
	my $parent = shift;

	my $self = $class->SUPER::new(
		$parent,
		-1,
		"Neues Transkript",
		wxDefaultPosition,
		wxDefaultSize,
		wxDEFAULT_DIALOG_STYLE | wxRESIZE_BORDER,
	);

	$self->{m_staticText10} = Wx::StaticText->new(
		$self,
		-1,
		"Datum",
	);

	$self->{m_staticText13} = Wx::StaticText->new(
		$self,
		-1,
		"Situation (z.B. Spielen mit dem Playmobilzoo)",
	);

	$self->{dat_date} = Wx::DatePickerCtrl->new(
		$self,
		-1,
		Wx::DateTime->new,
		wxDefaultPosition,
		[ 130, -1 ],
		wxDP_ALLOWNONE | wxDP_DEFAULT,
	);

	$self->{txt_situation} = Wx::TextCtrl->new(
		$self,
		-1,
		"",
		wxDefaultPosition,
		[ 300, -1 ],
	);
	$self->{txt_situation}->SetMaxLength(100);

	$self->{btn_ok} = Wx::BitmapButton->new(
		$self,
		-1,
		wxNullBitmap,
		wxDefaultPosition,
		[ 62, 62 ],
		wxBU_AUTODRAW,
	);
	$self->{btn_ok}->SetDefault;
	$self->{btn_ok}->SetToolTip(
		"Transkript hinzuf\x{fc}gen"
	);

	$self->{btn_cancel} = Wx::BitmapButton->new(
		$self,
		-1,
		wxNullBitmap,
		wxDefaultPosition,
		[ 62, 62 ],
		wxBU_AUTODRAW,
	);
	$self->{btn_cancel}->SetToolTip(
		"Abbrechen"
	);

	my $fgSizer3 = Wx::FlexGridSizer->new( 0, 2, 5, 0 );
	$fgSizer3->SetFlexibleDirection(wxBOTH);
	$fgSizer3->SetNonFlexibleGrowMode(wxFLEX_GROWMODE_SPECIFIED);
	$fgSizer3->Add( $self->{m_staticText10}, 0, wxRIGHT | wxLEFT, 20 );
	$fgSizer3->Add( $self->{m_staticText13}, 0, wxRIGHT | wxLEFT, 20 );
	$fgSizer3->Add( $self->{dat_date}, 0, wxBOTTOM | wxRIGHT | wxLEFT, 20 );
	$fgSizer3->Add( $self->{txt_situation}, 0, wxBOTTOM | wxRIGHT | wxLEFT, 20 );

	my $sbSizer2 = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"Daten",
		),
		wxVERTICAL,
	);
	$sbSizer2->Add( $fgSizer3, 0, wxTOP, 5 );

	my $bSizer6 = Wx::BoxSizer->new(wxHORIZONTAL);
	$bSizer6->Add( 0, 0, 1, wxEXPAND, 5 );
	$bSizer6->Add( $self->{btn_ok}, 0, wxBOTTOM | wxRIGHT | wxLEFT, 5 );
	$bSizer6->Add( $self->{btn_cancel}, 0, wxBOTTOM | wxRIGHT | wxLEFT, 5 );

	my $bSizer5 = Wx::BoxSizer->new(wxVERTICAL);
	$bSizer5->Add( $sbSizer2, 0, wxALL, 20 );
	$bSizer5->Add( $bSizer6, 1, wxEXPAND | wxBOTTOM | wxRIGHT | wxLEFT, 20 );

	$self->SetSizerAndFit($bSizer5);
	$self->Layout;

	return $self;
}

1;
