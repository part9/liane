package Liane::Wx::FBP::Editor;

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
		"Transkript Editor",
		wxDefaultPosition,
		[ 850, 610 ],
		wxDEFAULT_DIALOG_STYLE | wxMAXIMIZE_BOX | wxMINIMIZE_BOX | wxRESIZE_BORDER,
	);

	$self->{m_staticText2} = Wx::StaticText->new(
		$self,
		-1,
		"Datum",
	);

	$self->{m_staticText4} = Wx::StaticText->new(
		$self,
		-1,
		"Situation",
	);

	$self->{dat_date} = Wx::DatePickerCtrl->new(
		$self,
		-1,
		Wx::DateTime->new,
		wxDefaultPosition,
		[ 130, -1 ],
		wxDP_DEFAULT,
	);

	$self->{txt_situation} = Wx::TextCtrl->new(
		$self,
		-1,
		"",
		wxDefaultPosition,
		[ 300, -1 ],
	);
	$self->{txt_situation}->SetMaxLength(100);

	$self->{lst_utterances} = Wx::ListCtrl->new(
		$self,
		-1,
		wxDefaultPosition,
		[ -1, 250 ],
		wxLC_REPORT,
	);

	$self->{rad_spkr_child} = Wx::RadioButton->new(
		$self,
		-1,
		"&Kind (*KIN)",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_spkr_comment} = Wx::RadioButton->new(
		$self,
		-1,
		"Ko&mmentar (%com)",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_spkr_other} = Wx::RadioButton->new(
		$self,
		-1,
		"Anderer &Sprecher (*AND)",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{txt_utterance} = Wx::TextCtrl->new(
		$self,
		-1,
		"",
		wxDefaultPosition,
		wxDefaultSize,
		wxTE_PROCESS_ENTER,
	);
	$self->{txt_utterance}->SetMaxLength(200);

	$self->{btn_add_utterance} = Wx::BitmapButton->new(
		$self,
		-1,
		wxNullBitmap,
		wxDefaultPosition,
		wxDefaultSize,
		wxBU_AUTODRAW,
	);
	$self->{btn_add_utterance}->SetDefault;
	$self->{btn_add_utterance}->SetToolTip(
		"\x{c4}u\x{df}erung hinzuf\x{fc}gen"
	);

	$self->{btn_update_utterance} = Wx::BitmapButton->new(
		$self,
		-1,
		wxNullBitmap,
		wxDefaultPosition,
		wxDefaultSize,
		wxBU_AUTODRAW,
	);
	$self->{btn_update_utterance}->SetToolTip(
		"\x{c4}u\x{df}erung aktualisieren"
	);
	$self->{btn_update_utterance}->Disable;

	$self->{btn_delete_utterance} = Wx::BitmapButton->new(
		$self,
		-1,
		wxNullBitmap,
		wxDefaultPosition,
		wxDefaultSize,
		wxBU_AUTODRAW,
	);
	$self->{btn_delete_utterance}->SetToolTip(
		"\x{c4}u\x{df}erung l\x{f6}schen"
	);
	$self->{btn_delete_utterance}->Disable;

	$self->{m_staticText5} = Wx::StaticText->new(
		$self,
		-1,
		"\x{b7} eine \x{c4}u\x{df}erung pro Zeile\n\x{b7} jede \x{c4}u\x{df}erung mit Satz-\n  zeichen abschlie\x{df}en\n\x{b7} durchweg Kleinschreibung\n\x{b7} Kommas vermeiden\n\x{b7} keine Umlaute (\x{df}=ss)\n\n\x{b7} Auslassungen eines Wortes,\n  die nicht gesprochen werden,\n  werden in runden Klammern\n  dargestellt, z.B. gu(ck) ma(l).\n\n\x{b7} Der korrekte Ersatz f\x{fc}r etwas,\n  das das Kind ungenau sagt, wird \n  in eckigen Klammern dargestellt, \n  z.B. tika[=tiger].",
	);

	$self->{btn_ok} = Wx::BitmapButton->new(
		$self,
		-1,
		wxNullBitmap,
		wxDefaultPosition,
		[ 40, 40 ],
		wxBU_AUTODRAW,
	);
	$self->{btn_ok}->SetToolTip(
		"Speichern"
	);

	$self->{btn_cancel} = Wx::BitmapButton->new(
		$self,
		-1,
		wxNullBitmap,
		wxDefaultPosition,
		[ 40, 40 ],
		wxBU_AUTODRAW,
	);
	$self->{btn_cancel}->SetToolTip(
		"Abbrechen"
	);

	my $fgSizer1 = Wx::FlexGridSizer->new( 0, 2, 5, 20 );
	$fgSizer1->SetFlexibleDirection(wxBOTH);
	$fgSizer1->SetNonFlexibleGrowMode(wxFLEX_GROWMODE_SPECIFIED);
	$fgSizer1->Add( $self->{m_staticText2}, 0, wxTOP | wxRIGHT | wxLEFT, 10 );
	$fgSizer1->Add( $self->{m_staticText4}, 0, wxTOP | wxRIGHT, 10 );
	$fgSizer1->Add( $self->{dat_date}, 0, wxBOTTOM | wxRIGHT | wxLEFT, 10 );
	$fgSizer1->Add( $self->{txt_situation}, 0, wxBOTTOM | wxRIGHT, 10 );

	my $siz_data = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"Transkript Daten",
		),
		wxVERTICAL,
	);
	$siz_data->Add( $fgSizer1, 1, wxEXPAND, 20 );

	my $bSizer6 = Wx::BoxSizer->new(wxHORIZONTAL);
	$bSizer6->Add( $self->{rad_spkr_child}, 0, wxTOP | wxRIGHT | wxLEFT, 10 );
	$bSizer6->Add( $self->{rad_spkr_comment}, 0, wxTOP | wxRIGHT, 10 );
	$bSizer6->Add( $self->{rad_spkr_other}, 0, wxTOP | wxRIGHT, 10 );

	my $bSizer8 = Wx::BoxSizer->new(wxHORIZONTAL);
	$bSizer8->Add( 0, 0, 1, wxEXPAND, 5 );
	$bSizer8->Add( $self->{btn_add_utterance}, 0, wxTOP | wxBOTTOM | wxLEFT, 5 );
	$bSizer8->Add( $self->{btn_update_utterance}, 0, wxTOP | wxBOTTOM | wxLEFT, 5 );
	$bSizer8->Add( $self->{btn_delete_utterance}, 0, wxTOP | wxBOTTOM | wxLEFT, 5 );

	my $sbSizer4 = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"\x{c4}u\x{df}erung",
		),
		wxVERTICAL,
	);
	$sbSizer4->Add( $bSizer6, 0, wxEXPAND, 5 );
	$sbSizer4->Add( $self->{txt_utterance}, 0, wxEXPAND | wxRIGHT | wxLEFT, 10 );
	$sbSizer4->Add( $bSizer8, 0, wxEXPAND | wxRIGHT, 10 );

	my $bSizer2 = Wx::BoxSizer->new(wxVERTICAL);
	$bSizer2->Add( $sbSizer4, 1, wxEXPAND | wxBOTTOM | wxRIGHT | wxLEFT, 10 );

	my $siz_transcript = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"Transkript",
		),
		wxVERTICAL,
	);
	$siz_transcript->Add( $self->{lst_utterances}, 0, wxALL, 10 );
	$siz_transcript->Add( $bSizer2, 1, wxEXPAND, 20 );

	my $sbSizer3 = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"Hinweise zur Notation",
		),
		wxVERTICAL,
	);
	$sbSizer3->Add( $self->{m_staticText5}, 1, wxALL | wxEXPAND, 10 );

	my $bSizer71 = Wx::BoxSizer->new(wxVERTICAL);
	$bSizer71->Add( $sbSizer3, 1, wxEXPAND | wxTOP | wxRIGHT | wxLEFT, 10 );

	my $bSizer7 = Wx::BoxSizer->new(wxHORIZONTAL);
	$bSizer7->Add( $siz_transcript, 0, wxEXPAND | wxTOP | wxLEFT, 10 );
	$bSizer7->Add( $bSizer71, 1, wxEXPAND, 5 );

	my $bSizer5 = Wx::BoxSizer->new(wxHORIZONTAL);
	$bSizer5->Add( 0, 0, 1, wxEXPAND, 5 );
	$bSizer5->Add( $self->{btn_ok}, 0, wxTOP | wxBOTTOM | wxRIGHT, 5 );
	$bSizer5->Add( $self->{btn_cancel}, 0, wxTOP | wxBOTTOM | wxLEFT, 5 );

	my $siz_main = Wx::BoxSizer->new(wxVERTICAL);
	$siz_main->Add( $siz_data, 0, wxEXPAND | wxTOP | wxRIGHT | wxLEFT, 10 );
	$siz_main->Add( $bSizer7, 0, wxEXPAND, 10 );
	$siz_main->Add( 0, 0, 1, wxEXPAND, 5 );
	$siz_main->Add( $bSizer5, 1, wxEXPAND | wxRIGHT | wxLEFT, 10 );

	$self->SetSizer($siz_main);
	$self->Layout;

	return $self;
}

1;
