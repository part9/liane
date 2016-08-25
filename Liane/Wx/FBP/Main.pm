package Liane::Wx::FBP::Main;

use 5.008005;
use utf8;
use strict;
use warnings;
use Wx 0.98 ':everything';
use Wx::DateTime ();
use Wx::Calendar;

our $VERSION = '0.01';
our @ISA     = 'Wx::Frame';

sub new {
	my $class  = shift;
	my $parent = shift;

	my $self = $class->SUPER::new(
		$parent,
		-1,
		"liane v$main::VERSION",
		wxDefaultPosition,
		[ 843, 662 ],
		wxCAPTION | wxCLOSE_BOX | wxTAB_TRAVERSAL,
	);
	$self->SetForegroundColour(
		Wx::SystemSettings::GetColour( wxSYS_COLOUR_WINDOWTEXT )
	);
	$self->SetBackgroundColour(
		Wx::SystemSettings::GetColour( wxSYS_COLOUR_MENU )
	);

	$self->{m_menu1} = Wx::Menu->new;

	my $m_menuItemNew = Wx::MenuItem->new(
		$self->{m_menu1},
		11,
		"Neue Akte\tCtrl+N",
		'',
		wxITEM_NORMAL,
	);

	my $m_menuItemOpen = Wx::MenuItem->new(
		$self->{m_menu1},
		12,
		"\x{d6}ffnen...\tCtrl+O",
		'',
		wxITEM_NORMAL,
	);

	my $m_menuItemSave = Wx::MenuItem->new(
		$self->{m_menu1},
		13,
		"Speichern\tCtrl+S",
		'',
		wxITEM_NORMAL,
	);

	my $m_menuItemSaveAs = Wx::MenuItem->new(
		$self->{m_menu1},
		14,
		"Speichern unter...\tCtrl+Shift+S",
		'',
		wxITEM_NORMAL,
	);

	my $m_menuItemQuit = Wx::MenuItem->new(
		$self->{m_menu1},
		15,
		"Beenden\tCtrl+Q",
		'',
		wxITEM_NORMAL,
	);

	$self->{m_menu1}->Append( $m_menuItemNew );
	$self->{m_menu1}->Append( $m_menuItemOpen );
	$self->{m_menu1}->Append( $m_menuItemSave );
	$self->{m_menu1}->Append( $m_menuItemSaveAs );
	$self->{m_menu1}->AppendSeparator;
	$self->{m_menu1}->Append( $m_menuItemQuit );

	$self->{m_menu2} = Wx::Menu->new;

	my $m_menuItemAbout = Wx::MenuItem->new(
		$self->{m_menu2},
		21,
		"Info\tF1",
		'',
		wxITEM_NORMAL,
	);

	$self->{m_menu2}->Append( $m_menuItemAbout );

	$self->{m_menubar1} = Wx::MenuBar->new(0);

	$self->{m_menubar1}->Append(
		$self->{m_menu1},
		"Datei",
	);
	$self->{m_menubar1}->Append(
		$self->{m_menu2},
		"Hilfe",
	);

	$self->SetMenuBar( $self->{m_menubar1} );

	$self->{m_bitmapSide} = Wx::StaticBitmap->new(
		$self,
		-1,
		wxNullBitmap,
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{m_staticText16} = Wx::StaticText->new(
		$self,
		-1,
		"Name",
	);

	$self->{txt_name} = Wx::TextCtrl->new(
		$self,
		-1,
		"",
		wxDefaultPosition,
		[ 200, -1 ],
	);
	$self->{txt_name}->SetMaxLength(25);

	$self->{m_staticText17} = Wx::StaticText->new(
		$self,
		-1,
		"Geburtsdatum",
	);

	$self->{dat_birthdate} = Wx::DatePickerCtrl->new(
		$self,
		-1,
		Wx::DateTime->new,
		wxDefaultPosition,
		[ 130, -1 ],
		wxDP_DEFAULT,
	);

	$self->{m_staticText19} = Wx::StaticText->new(
		$self,
		-1,
		"Telefon",
	);

	$self->{txt_phonenumber} = Wx::TextCtrl->new(
		$self,
		-1,
		"",
		wxDefaultPosition,
		[ 200, -1 ],
	);
	$self->{txt_phonenumber}->SetMaxLength(20);

	$self->{m_staticText18} = Wx::StaticText->new(
		$self,
		-1,
		"Einrichtung",
	);

	$self->{txt_institution} = Wx::TextCtrl->new(
		$self,
		-1,
		"",
		wxDefaultPosition,
		[ 400, -1 ],
	);
	$self->{txt_institution}->SetMaxLength(50);

	$self->{m_staticText20} = Wx::StaticText->new(
		$self,
		-1,
		"Anmerkungen",
	);

	$self->{txt_notes} = Wx::TextCtrl->new(
		$self,
		-1,
		"",
		wxDefaultPosition,
		[ 400, -1 ],
	);
	$self->{txt_notes}->SetMaxLength(50);

	$self->{lst_transcripts} = Wx::ListCtrl->new(
		$self,
		-1,
		wxDefaultPosition,
		wxDefaultSize,
		wxLC_REPORT,
	);

	$self->{btn_add_transcript} = Wx::BitmapButton->new(
		$self,
		-1,
		wxNullBitmap,
		wxDefaultPosition,
		wxDefaultSize,
		wxBU_AUTODRAW,
	);
	$self->{btn_add_transcript}->SetToolTip(
		"Neues Transkript"
	);

	$self->{btn_edit_transcript} = Wx::BitmapButton->new(
		$self,
		-1,
		wxNullBitmap,
		wxDefaultPosition,
		wxDefaultSize,
		wxBU_AUTODRAW,
	);
	$self->{btn_edit_transcript}->SetToolTip(
		"Transkript bearbeiten"
	);

	$self->{btn_delete_transcript} = Wx::BitmapButton->new(
		$self,
		-1,
		wxNullBitmap,
		wxDefaultPosition,
		wxDefaultSize,
		wxBU_AUTODRAW,
	);
	$self->{btn_delete_transcript}->SetToolTip(
		"Transkript l\x{f6}schen"
	);

	$self->{m_staticline1} = Wx::StaticLine->new(
		$self,
		-1,
		wxDefaultPosition,
		wxDefaultSize,
		wxLI_VERTICAL,
	);

	$self->{btn_analyze_transcript} = Wx::BitmapButton->new(
		$self,
		-1,
		wxNullBitmap,
		wxDefaultPosition,
		wxDefaultSize,
		wxBU_AUTODRAW,
	);
	$self->{btn_analyze_transcript}->SetToolTip(
		"Transkript analysieren"
	);

	$self->{m_staticline11} = Wx::StaticLine->new(
		$self,
		-1,
		wxDefaultPosition,
		wxDefaultSize,
		wxLI_VERTICAL,
	);

	$self->{btn_show_profile} = Wx::BitmapButton->new(
		$self,
		-1,
		wxNullBitmap,
		wxDefaultPosition,
		wxDefaultSize,
		wxBU_AUTODRAW,
	);
	$self->{btn_show_profile}->SetToolTip(
		"Profil speichern"
	);

	my $fgSizer2 = Wx::FlexGridSizer->new( 0, 2, 10, 20 );
	$fgSizer2->SetFlexibleDirection(wxBOTH);
	$fgSizer2->SetNonFlexibleGrowMode(wxFLEX_GROWMODE_SPECIFIED);
	$fgSizer2->Add( $self->{m_staticText16}, 0, 0, 5 );
	$fgSizer2->Add( $self->{txt_name}, 0, 0, 5 );
	$fgSizer2->Add( $self->{m_staticText17}, 0, wxTOP, 5 );
	$fgSizer2->Add( $self->{dat_birthdate}, 0, 0, 5 );
	$fgSizer2->Add( $self->{m_staticText19}, 0, wxTOP, 5 );
	$fgSizer2->Add( $self->{txt_phonenumber}, 0, 0, 5 );
	$fgSizer2->Add( $self->{m_staticText18}, 0, wxTOP, 5 );
	$fgSizer2->Add( $self->{txt_institution}, 0, 0, 5 );
	$fgSizer2->Add( $self->{m_staticText20}, 0, wxTOP, 5 );
	$fgSizer2->Add( $self->{txt_notes}, 0, 0, 5 );

	my $bSizer6 = Wx::BoxSizer->new(wxHORIZONTAL);
	$bSizer6->Add( $fgSizer2, 1, wxEXPAND | wxRIGHT | wxLEFT, 20 );

	my $sbSizerData = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"Pers\x{f6}nliche Daten",
		),
		wxVERTICAL,
	);
	$sbSizerData->Add( $bSizer6, 1, wxEXPAND | wxTOP | wxBOTTOM, 20 );

	my $bSizerMenu2 = Wx::BoxSizer->new(wxHORIZONTAL);
	$bSizerMenu2->Add( $self->{btn_add_transcript}, 0, wxRIGHT, 10 );
	$bSizerMenu2->Add( $self->{btn_edit_transcript}, 0, wxRIGHT | wxLEFT, 10 );
	$bSizerMenu2->Add( $self->{btn_delete_transcript}, 0, wxRIGHT | wxLEFT, 10 );
	$bSizerMenu2->Add( $self->{m_staticline1}, 0, wxEXPAND | wxRIGHT | wxLEFT, 10 );
	$bSizerMenu2->Add( $self->{btn_analyze_transcript}, 0, wxRIGHT | wxLEFT, 10 );
	$bSizerMenu2->Add( $self->{m_staticline11}, 0, wxEXPAND | wxRIGHT | wxLEFT, 10 );
	$bSizerMenu2->Add( $self->{btn_show_profile}, 0, wxLEFT, 10 );

	my $sbSizerTranscripts = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"Transkripte",
		),
		wxVERTICAL,
	);
	$sbSizerTranscripts->Add( $self->{lst_transcripts}, 1, wxEXPAND | wxALL, 20 );
	$sbSizerTranscripts->Add( $bSizerMenu2, 0, wxEXPAND | wxBOTTOM | wxLEFT, 20 );

	my $bSizerWorkplace = Wx::BoxSizer->new(wxVERTICAL);
	$bSizerWorkplace->Add( $sbSizerData, 0, wxEXPAND, 5 );
	$bSizerWorkplace->Add( $sbSizerTranscripts, 1, wxEXPAND | wxTOP, 20 );

	my $bSizerMain = Wx::BoxSizer->new(wxHORIZONTAL);
	$bSizerMain->Add( $self->{m_bitmapSide}, 0, 0, 5 );
	$bSizerMain->Add( $bSizerWorkplace, 1, wxEXPAND | wxALL, 20 );

	$self->SetSizer($bSizerMain);
	$self->Layout;

	return $self;
}

1;
