package Liane::Wx::FBP::Analyzer;

use 5.008005;
use utf8;
use strict;
use warnings;
use Wx 0.98 ':everything';

our $VERSION = '0.01';
our @ISA     = 'Wx::Dialog';

sub new {
	my $class  = shift;
	my $parent = shift;

	my $self = $class->SUPER::new(
		$parent,
		-1,
		"Transkriptanalyse",
		wxDefaultPosition,
		[ 1000, 699 ],
		wxDEFAULT_DIALOG_STYLE | wxMAXIMIZE_BOX | wxRESIZE_BORDER,
	);

	$self->{rad_structure_none} = Wx::RadioButton->new(
		$self,
		500,
		"nicht bestimmt",
		wxDefaultPosition,
		wxDefaultSize,
		wxRB_GROUP,
	);
	$self->{rad_structure_none}->SetValue(1);

	$self->{m_staticline3} = Wx::StaticLine->new(
		$self,
		-1,
		wxDefaultPosition,
		wxDefaultSize,
		wxLI_HORIZONTAL,
	);

	$self->{rad_structure_two} = Wx::RadioButton->new(
		$self,
		510,
		"Zweiwortsatz ohne Verb",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_structure_two_verb} = Wx::RadioButton->new(
		$self,
		511,
		"Zweiwortsatz mit Verb",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{m_staticline1} = Wx::StaticLine->new(
		$self,
		-1,
		wxDefaultPosition,
		wxDefaultSize,
		wxLI_HORIZONTAL,
	);

	$self->{rad_structure_more_inf} = Wx::RadioButton->new(
		$self,
		520,
		"Mehrwortsatz mit Infinitiv",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_structure_more_vtwo_conj} = Wx::RadioButton->new(
		$self,
		521,
		"Mehrwortsatz mit V2-Stellung eines",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{lbl_structure_more_vtwo_conj} = Wx::StaticText->new(
		$self,
		-1,
		"konjugierten Verbs",
	);

	$self->{rad_structure_more_vtwo_aux} = Wx::RadioButton->new(
		$self,
		522,
		"Mehrwortsatz mit V2-Stellung eines",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{lbl_structure_more_vtwo_aux} = Wx::StaticText->new(
		$self,
		-1,
		"Auxiliarverbs und Endstellung eines\nVerbs im Infinitiv oder Partizip",
	);

	$self->{rad_structure_more_other} = Wx::RadioButton->new(
		$self,
		523,
		"Anderer Mehrwortsatz",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{m_staticline2} = Wx::StaticLine->new(
		$self,
		-1,
		wxDefaultPosition,
		wxDefaultSize,
		wxLI_HORIZONTAL,
	);

	$self->{rad_structure_complex} = Wx::RadioButton->new(
		$self,
		530,
		"Satzgef\x{fc}ge",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{lbl_cagreement_acc} = Wx::StaticText->new(
		$self,
		-1,
		"Im Akkusativkontext",
	);

	$self->{lbl_cagreement_acc_acc} = Wx::StaticText->new(
		$self,
		600,
		"Akkusativ",
	);

	$self->{txt_cagreement_acc_acc} = Wx::TextCtrl->new(
		$self,
		600,
		"0",
		wxDefaultPosition,
		[ 40, -1 ],
		wxTE_RIGHT,
	);
	$self->{txt_cagreement_acc_acc}->SetMaxLength(3);

	$self->{lbl_cagreement_acc_nom} = Wx::StaticText->new(
		$self,
		601,
		"Nominativ",
	);

	$self->{txt_cagreement_acc_nom} = Wx::TextCtrl->new(
		$self,
		601,
		"0",
		wxDefaultPosition,
		[ 40, -1 ],
		wxTE_RIGHT,
	);
	$self->{txt_cagreement_acc_nom}->SetMaxLength(3);

	$self->{lbl_cagreement_dat} = Wx::StaticText->new(
		$self,
		-1,
		"Im Dativkontext",
	);

	$self->{lbl_cagreement_dat_dat} = Wx::StaticText->new(
		$self,
		610,
		"Dativ",
	);

	$self->{txt_cagreement_dat_dat} = Wx::TextCtrl->new(
		$self,
		610,
		"0",
		wxDefaultPosition,
		[ 40, -1 ],
		wxTE_RIGHT,
	);
	$self->{txt_cagreement_dat_dat}->SetMaxLength(3);

	$self->{lbl_cagreement_dat_nom} = Wx::StaticText->new(
		$self,
		611,
		"Nominativ",
	);

	$self->{txt_cagreement_dat_nom} = Wx::TextCtrl->new(
		$self,
		611,
		"0",
		wxDefaultPosition,
		[ 40, -1 ],
		wxTE_RIGHT,
	);
	$self->{txt_cagreement_dat_nom}->SetMaxLength(3);

	$self->{lbl_cagreement_dat_acc} = Wx::StaticText->new(
		$self,
		612,
		"Akkusativ",
	);

	$self->{txt_cagreement_dat_acc} = Wx::TextCtrl->new(
		$self,
		612,
		"0",
		wxDefaultPosition,
		[ 40, -1 ],
		wxTE_RIGHT,
	);
	$self->{txt_cagreement_dat_acc}->SetMaxLength(3);

	$self->{chk_elision_subject} = Wx::CheckBox->new(
		$self,
		700,
		"Subjekt",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{chk_elision_copular} = Wx::CheckBox->new(
		$self,
		703,
		"Kopulaverb",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{chk_elision_article} = Wx::CheckBox->new(
		$self,
		701,
		"Artikel",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{chk_elision_auxiliary} = Wx::CheckBox->new(
		$self,
		704,
		"Auxiliarverb",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{chk_elision_verb} = Wx::CheckBox->new(
		$self,
		702,
		"Vollverb",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{chk_elision_preposition} = Wx::CheckBox->new(
		$self,
		705,
		"Pr\x{e4}position",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{chk_svi_used} = Wx::CheckBox->new(
		$self,
		800,
		"vorhanden",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_svi_question} = Wx::RadioButton->new(
		$self,
		810,
		"Frage",
		wxDefaultPosition,
		wxDefaultSize,
		wxRB_GROUP,
	);
	$self->{rad_svi_question}->SetValue(1);

	$self->{rad_svi_topicalization} = Wx::RadioButton->new(
		$self,
		811,
		"Topikalisierung",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{m_staticline6} = Wx::StaticLine->new(
		$self,
		-1,
		wxDefaultPosition,
		wxDefaultSize,
		wxLI_HORIZONTAL,
	);

	$self->{rad_svi_correct} = Wx::RadioButton->new(
		$self,
		821,
		"korrekt",
		wxDefaultPosition,
		wxDefaultSize,
		wxRB_GROUP,
	);
	$self->{rad_svi_correct}->SetValue(1);

	$self->{rad_svi_incorrect} = Wx::RadioButton->new(
		$self,
		820,
		"nicht korrekt",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{lst_utterances} = Wx::ListCtrl->new(
		$self,
		-1,
		wxDefaultPosition,
		wxDefaultSize,
		wxLC_REPORT,
	);

	$self->{lst_words} = Wx::ListCtrl->new(
		$self,
		-1,
		wxDefaultPosition,
		[ 150, 150 ],
		wxLC_REPORT,
	);

	$self->{rad_wordclass_none} = Wx::RadioButton->new(
		$self,
		200,
		"nicht bestimmt",
		wxDefaultPosition,
		wxDefaultSize,
		wxRB_GROUP,
	);
	$self->{rad_wordclass_none}->SetValue(1);

	$self->{rad_wordclass_noun} = Wx::RadioButton->new(
		$self,
		210,
		"Nomen",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_wordclass_verb} = Wx::RadioButton->new(
		$self,
		220,
		"Vollverb",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_wordclass_adverb} = Wx::RadioButton->new(
		$self,
		230,
		"Adverb",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_wordclass_article} = Wx::RadioButton->new(
		$self,
		211,
		"Artikel",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_wordclass_auxiliary} = Wx::RadioButton->new(
		$self,
		221,
		"Auxiliar",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_wordclass_preposition} = Wx::RadioButton->new(
		$self,
		231,
		"Pr\x{e4}position",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_wordclass_adjective} = Wx::RadioButton->new(
		$self,
		212,
		"Adjektiv",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_wordclass_modal} = Wx::RadioButton->new(
		$self,
		222,
		"Modal",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_wordclass_conjunction} = Wx::RadioButton->new(
		$self,
		232,
		"Konjunktion",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_wordclass_pronoun_personal} = Wx::RadioButton->new(
		$self,
		213,
		"Pronomen (Pers.)",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_wordclass_copular} = Wx::RadioButton->new(
		$self,
		223,
		"Kopula",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_wordclass_pronoun_other} = Wx::RadioButton->new(
		$self,
		214,
		"Pronomen (And.)",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{lbl_number} = Wx::StaticText->new(
		$self,
		-1,
		"Numerus",
	);

	$self->{rad_number_none} = Wx::RadioButton->new(
		$self,
		300,
		"nicht bestimmt",
		wxDefaultPosition,
		wxDefaultSize,
		wxRB_GROUP,
	);
	$self->{rad_number_none}->SetValue(1);

	$self->{rad_number_singular} = Wx::RadioButton->new(
		$self,
		301,
		"Singular",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_number_plural} = Wx::RadioButton->new(
		$self,
		302,
		"Plural",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{lbl_case} = Wx::StaticText->new(
		$self,
		-1,
		"Kasus",
	);

	$self->{rad_case_none} = Wx::RadioButton->new(
		$self,
		310,
		"nicht bestimmt",
		wxDefaultPosition,
		wxDefaultSize,
		wxRB_GROUP,
	);
	$self->{rad_case_none}->SetValue(1);

	$self->{rad_case_nominative} = Wx::RadioButton->new(
		$self,
		311,
		"Nominativ",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_case_genitive} = Wx::RadioButton->new(
		$self,
		312,
		"Genitiv",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_case_dative} = Wx::RadioButton->new(
		$self,
		313,
		"Dativ",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_case_accusative} = Wx::RadioButton->new(
		$self,
		314,
		"Akkusativ",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{lbl_gender} = Wx::StaticText->new(
		$self,
		-1,
		"Genus",
	);

	$self->{rad_gender_none} = Wx::RadioButton->new(
		$self,
		320,
		"nicht bestimmt",
		wxDefaultPosition,
		wxDefaultSize,
		wxRB_GROUP,
	);
	$self->{rad_gender_none}->SetValue(1);

	$self->{rad_gender_masculine} = Wx::RadioButton->new(
		$self,
		321,
		"maskulinum",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_gender_feminine} = Wx::RadioButton->new(
		$self,
		322,
		"femininum",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_gender_neuter} = Wx::RadioButton->new(
		$self,
		323,
		"neutrum",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{lbl_tense} = Wx::StaticText->new(
		$self,
		-1,
		"Tempus",
	);

	$self->{rad_tense_none} = Wx::RadioButton->new(
		$self,
		330,
		"nicht bestimmt",
		wxDefaultPosition,
		wxDefaultSize,
		wxRB_GROUP,
	);
	$self->{rad_tense_none}->SetValue(1);

	$self->{rad_tense_present} = Wx::RadioButton->new(
		$self,
		331,
		"Pr\x{e4}sens",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_tense_past_participle} = Wx::RadioButton->new(
		$self,
		332,
		"Partizip Perfekt",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_tense_other} = Wx::RadioButton->new(
		$self,
		333,
		"Anderes",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{lbl_person} = Wx::StaticText->new(
		$self,
		-1,
		"Person",
	);

	$self->{rad_person_none} = Wx::RadioButton->new(
		$self,
		340,
		"nicht bestimmt",
		wxDefaultPosition,
		wxDefaultSize,
		wxRB_GROUP,
	);
	$self->{rad_person_none}->SetValue(1);

	$self->{rad_person_first} = Wx::RadioButton->new(
		$self,
		341,
		"1. Person",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_person_second} = Wx::RadioButton->new(
		$self,
		342,
		"2. Person",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{rad_person_third} = Wx::RadioButton->new(
		$self,
		343,
		"3. Person",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{lbl_verbmarker} = Wx::StaticText->new(
		$self,
		-1,
		"Verbmarkierung",
	);

	$self->{rad_sv_agreement_correct} = Wx::RadioButton->new(
		$self,
		411,
		"kongruent",
		wxDefaultPosition,
		wxDefaultSize,
		wxRB_GROUP,
	);
	$self->{rad_sv_agreement_correct}->SetValue(1);

	$self->{rad_sv_agreement_incorrect} = Wx::RadioButton->new(
		$self,
		410,
		"nicht kongruent",
		wxDefaultPosition,
		wxDefaultSize,
	);

	$self->{cho_verbmarker_present} = Wx::Choice->new(
		$self,
		420,
		wxDefaultPosition,
		wxDefaultSize,
		[
			"Infinitiv",
			"-e",
			"-\x{f8}",
			"-st",
			"-en",
			"-t",
			"Andere",
		],
	);
	$self->{cho_verbmarker_present}->SetSelection(0);

	$self->{cho_verbmarker_past_participle} = Wx::Choice->new(
		$self,
		430,
		wxDefaultPosition,
		wxDefaultSize,
		[
			"ge+ keine Vokal\x{e4}nd. +en",
			"ge+ Vokal\x{e4}nd. +en",
			"ge+ keine Vokal\x{e4}nd. +t",
			"Andere",
		],
	);
	$self->{cho_verbmarker_past_participle}->SetSelection(0);

	$self->{btn_ok} = Wx::BitmapButton->new(
		$self,
		-1,
		wxNullBitmap,
		wxDefaultPosition,
		[ 40, 40 ],
		wxBU_AUTODRAW,
	);
	$self->{btn_ok}->SetDefault;
	$self->{btn_ok}->SetToolTip(
		"Analyse speichern"
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
		"Analyse abbrechen"
	);

	$self->{btn_help} = Wx::BitmapButton->new(
		$self,
		1,
		wxNullBitmap,
		wxDefaultPosition,
		[ 40, 40 ],
		wxBU_AUTODRAW,
	);
	$self->{btn_help}->SetToolTip(
		"Hilfe"
	);

	my $sbSizer8 = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"Satzstruktur",
		),
		wxVERTICAL,
	);
	$sbSizer8->Add( $self->{rad_structure_none}, 0, wxTOP | wxRIGHT | wxLEFT, 5 );
	$sbSizer8->Add( $self->{m_staticline3}, 0, wxEXPAND | wxALL, 5 );
	$sbSizer8->Add( $self->{rad_structure_two}, 0, wxRIGHT | wxLEFT, 5 );
	$sbSizer8->Add( $self->{rad_structure_two_verb}, 0, wxRIGHT | wxLEFT, 5 );
	$sbSizer8->Add( $self->{m_staticline1}, 0, wxEXPAND | wxALL, 5 );
	$sbSizer8->Add( $self->{rad_structure_more_inf}, 0, wxRIGHT | wxLEFT, 5 );
	$sbSizer8->Add( $self->{rad_structure_more_vtwo_conj}, 0, wxRIGHT | wxLEFT, 5 );
	$sbSizer8->Add( $self->{lbl_structure_more_vtwo_conj}, 0, wxRIGHT | wxLEFT, 30 );
	$sbSizer8->Add( $self->{rad_structure_more_vtwo_aux}, 0, wxRIGHT | wxLEFT, 5 );
	$sbSizer8->Add( $self->{lbl_structure_more_vtwo_aux}, 0, wxRIGHT | wxLEFT, 30 );
	$sbSizer8->Add( $self->{rad_structure_more_other}, 0, wxRIGHT | wxLEFT, 5 );
	$sbSizer8->Add( $self->{m_staticline2}, 0, wxEXPAND | wxALL, 5 );
	$sbSizer8->Add( $self->{rad_structure_complex}, 0, wxBOTTOM | wxRIGHT | wxLEFT, 5 );

	my $fgSizer5 = Wx::FlexGridSizer->new( 0, 3, 0, 0 );
	$fgSizer5->SetFlexibleDirection(wxBOTH);
	$fgSizer5->SetNonFlexibleGrowMode(wxFLEX_GROWMODE_SPECIFIED);
	$fgSizer5->Add( $self->{lbl_cagreement_acc}, 0, wxTOP | wxRIGHT | wxLEFT, 5 );
	$fgSizer5->Add( $self->{lbl_cagreement_acc_acc}, 0, wxTOP | wxRIGHT | wxLEFT, 5 );
	$fgSizer5->Add( $self->{txt_cagreement_acc_acc}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer5->Add( 0, 0, 1, wxEXPAND, 5 );
	$fgSizer5->Add( $self->{lbl_cagreement_acc_nom}, 0, wxTOP | wxRIGHT | wxLEFT, 5 );
	$fgSizer5->Add( $self->{txt_cagreement_acc_nom}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer5->Add( $self->{lbl_cagreement_dat}, 0, wxTOP | wxRIGHT | wxLEFT, 5 );
	$fgSizer5->Add( $self->{lbl_cagreement_dat_dat}, 0, wxTOP | wxRIGHT | wxLEFT, 5 );
	$fgSizer5->Add( $self->{txt_cagreement_dat_dat}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer5->Add( 0, 0, 1, wxEXPAND, 5 );
	$fgSizer5->Add( $self->{lbl_cagreement_dat_nom}, 0, wxALL, 5 );
	$fgSizer5->Add( $self->{txt_cagreement_dat_nom}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer5->Add( 0, 0, 1, wxEXPAND, 5 );
	$fgSizer5->Add( $self->{lbl_cagreement_dat_acc}, 0, wxTOP | wxRIGHT | wxLEFT, 5 );
	$fgSizer5->Add( $self->{txt_cagreement_dat_acc}, 0, wxBOTTOM | wxRIGHT | wxLEFT, 5 );

	my $sbSizer9 = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"Kasusmarkierung am Objekt",
		),
		wxVERTICAL,
	);
	$sbSizer9->Add( $fgSizer5, 1, wxEXPAND | wxALL, 5 );

	my $fgSizer31 = Wx::FlexGridSizer->new( 0, 2, 0, 0 );
	$fgSizer31->SetFlexibleDirection(wxBOTH);
	$fgSizer31->SetNonFlexibleGrowMode(wxFLEX_GROWMODE_SPECIFIED);
	$fgSizer31->Add( $self->{chk_elision_subject}, 0, wxTOP | wxRIGHT | wxLEFT, 5 );
	$fgSizer31->Add( $self->{chk_elision_copular}, 0, wxTOP | wxRIGHT | wxLEFT, 5 );
	$fgSizer31->Add( $self->{chk_elision_article}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer31->Add( $self->{chk_elision_auxiliary}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer31->Add( $self->{chk_elision_verb}, 0, wxBOTTOM | wxRIGHT | wxLEFT, 5 );
	$fgSizer31->Add( $self->{chk_elision_preposition}, 0, wxBOTTOM | wxRIGHT | wxLEFT, 5 );

	my $sbSizer10 = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"Auslassungen",
		),
		wxVERTICAL,
	);
	$sbSizer10->Add( $fgSizer31, 1, wxEXPAND | wxALL, 5 );

	my $bSizer6 = Wx::BoxSizer->new(wxHORIZONTAL);
	$bSizer6->Add( $self->{chk_svi_used}, 0, wxTOP | wxRIGHT | wxLEFT, 5 );
	$bSizer6->Add( $self->{rad_svi_question}, 0, wxTOP | wxRIGHT | wxLEFT, 5 );
	$bSizer6->Add( $self->{rad_svi_topicalization}, 0, wxTOP | wxRIGHT | wxLEFT, 5 );

	my $bSizer71 = Wx::BoxSizer->new(wxHORIZONTAL);
	$bSizer71->Add( $self->{rad_svi_correct}, 0, wxBOTTOM | wxRIGHT | wxLEFT, 5 );
	$bSizer71->Add( $self->{rad_svi_incorrect}, 0, wxBOTTOM | wxRIGHT | wxLEFT, 5 );

	my $sbSizer11 = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"Subjekt-Verb-Inversion",
		),
		wxVERTICAL,
	);
	$sbSizer11->Add( $bSizer6, 0, wxEXPAND, 5 );
	$sbSizer11->Add( $self->{m_staticline6}, 0, wxEXPAND | wxALL, 5 );
	$sbSizer11->Add( $bSizer71, 0, wxEXPAND, 5 );

	my $sbSizer71 = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"(A) Analyse auf Satzebene",
		),
		wxVERTICAL,
	);
	$sbSizer71->Add( $sbSizer8, 0, wxEXPAND | wxALL, 10 );
	$sbSizer71->Add( $sbSizer9, 0, wxEXPAND | wxBOTTOM | wxRIGHT | wxLEFT, 10 );
	$sbSizer71->Add( $sbSizer10, 0, wxEXPAND | wxBOTTOM | wxRIGHT | wxLEFT, 10 );
	$sbSizer71->Add( $sbSizer11, 0, wxEXPAND | wxBOTTOM | wxRIGHT | wxLEFT, 10 );

	my $siz_transcript = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"Transkript",
		),
		wxVERTICAL,
	);
	$siz_transcript->Add( $self->{lst_utterances}, 0, wxALL | wxEXPAND, 10 );

	my $bSizer9 = Wx::BoxSizer->new(wxHORIZONTAL);
	$bSizer9->Add( $siz_transcript, 1, wxEXPAND | wxALL, 10 );

	my $sbSizer51 = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"1. Wort ausw\x{e4}hlen",
		),
		wxVERTICAL,
	);
	$sbSizer51->Add( $self->{lst_words}, 0, wxALL, 5 );

	my $fgSizer2 = Wx::FlexGridSizer->new( 0, 4, 0, 0 );
	$fgSizer2->SetFlexibleDirection(wxBOTH);
	$fgSizer2->SetNonFlexibleGrowMode(wxFLEX_GROWMODE_SPECIFIED);
	$fgSizer2->Add( $self->{rad_wordclass_none}, 0, wxRIGHT, 5 );
	$fgSizer2->Add( $self->{rad_wordclass_noun}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer2->Add( $self->{rad_wordclass_verb}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer2->Add( $self->{rad_wordclass_adverb}, 0, wxLEFT, 5 );
	$fgSizer2->Add( 0, 0, 1, wxEXPAND, 5 );
	$fgSizer2->Add( $self->{rad_wordclass_article}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer2->Add( $self->{rad_wordclass_auxiliary}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer2->Add( $self->{rad_wordclass_preposition}, 0, wxLEFT, 5 );
	$fgSizer2->Add( 0, 0, 1, wxEXPAND, 5 );
	$fgSizer2->Add( $self->{rad_wordclass_adjective}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer2->Add( $self->{rad_wordclass_modal}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer2->Add( $self->{rad_wordclass_conjunction}, 0, wxLEFT, 5 );
	$fgSizer2->Add( 0, 0, 1, wxEXPAND, 5 );
	$fgSizer2->Add( $self->{rad_wordclass_pronoun_personal}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer2->Add( $self->{rad_wordclass_copular}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer2->Add( 0, 0, 1, wxEXPAND, 5 );
	$fgSizer2->Add( 0, 0, 1, wxEXPAND, 5 );
	$fgSizer2->Add( $self->{rad_wordclass_pronoun_other}, 0, wxBOTTOM | wxRIGHT | wxLEFT, 5 );

	my $sbSizer5 = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"2. Wortart bestimmen",
		),
		wxVERTICAL,
	);
	$sbSizer5->Add( $fgSizer2, 1, wxALL | wxEXPAND, 10 );

	my $bSizer15 = Wx::BoxSizer->new(wxHORIZONTAL);
	$bSizer15->Add( $sbSizer51, 0, wxEXPAND | wxALL, 10 );
	$bSizer15->Add( $sbSizer5, 1, wxTOP | wxBOTTOM | wxRIGHT | wxEXPAND, 10 );

	my $fgSizer3 = Wx::FlexGridSizer->new( 0, 6, 0, 0 );
	$fgSizer3->SetFlexibleDirection(wxBOTH);
	$fgSizer3->SetNonFlexibleGrowMode(wxFLEX_GROWMODE_SPECIFIED);
	$fgSizer3->Add( $self->{lbl_number}, 0, wxTOP | wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_number_none}, 0, wxTOP | wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_number_singular}, 0, wxTOP | wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_number_plural}, 0, wxTOP | wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( 0, 0, 1, wxEXPAND, 5 );
	$fgSizer3->Add( 0, 0, 1, wxEXPAND, 5 );
	$fgSizer3->Add( $self->{lbl_case}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_case_none}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_case_nominative}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_case_genitive}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_case_dative}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_case_accusative}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{lbl_gender}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_gender_none}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_gender_masculine}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_gender_feminine}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_gender_neuter}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( 0, 0, 1, wxEXPAND, 5 );
	$fgSizer3->Add( $self->{lbl_tense}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_tense_none}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_tense_present}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_tense_past_participle}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_tense_other}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( 0, 0, 1, wxEXPAND, 5 );
	$fgSizer3->Add( $self->{lbl_person}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_person_none}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_person_first}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_person_second}, 0, wxRIGHT | wxLEFT, 5 );
	$fgSizer3->Add( $self->{rad_person_third}, 0, wxRIGHT | wxLEFT, 5 );

	my $sbSizer6 = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"3. Merkmalsklassen bestimmen",
		),
		wxVERTICAL,
	);
	$sbSizer6->Add( $fgSizer3, 1, wxEXPAND | wxALL, 10 );

	my $sbSizer7 = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"4. Verbflexion",
		),
		wxHORIZONTAL,
	);
	$sbSizer7->Add( $self->{lbl_verbmarker}, 0, wxALL, 10 );
	$sbSizer7->Add( $self->{rad_sv_agreement_correct}, 0, wxTOP | wxBOTTOM, 10 );
	$sbSizer7->Add( $self->{rad_sv_agreement_incorrect}, 0, wxALL, 10 );
	$sbSizer7->Add( $self->{cho_verbmarker_present}, 0, wxALL, 5 );
	$sbSizer7->Add( $self->{cho_verbmarker_past_participle}, 0, wxALL, 5 );

	my $siz_words = Wx::StaticBoxSizer->new(
		Wx::StaticBox->new(
			$self,
			-1,
			"(B) Analyse auf Wortebene",
		),
		wxVERTICAL,
	);
	$siz_words->Add( $bSizer15, 1, wxEXPAND, 5 );
	$siz_words->Add( $sbSizer6, 0, wxBOTTOM | wxRIGHT | wxLEFT | wxEXPAND, 10 );
	$siz_words->Add( $sbSizer7, 0, wxEXPAND | wxBOTTOM | wxRIGHT | wxLEFT, 10 );

	my $bSizer5 = Wx::BoxSizer->new(wxHORIZONTAL);
	$bSizer5->Add( $siz_words, 1, wxEXPAND | wxALL, 10 );

	my $bSizer91 = Wx::BoxSizer->new(wxHORIZONTAL);
	$bSizer91->Add( 0, 0, 1, wxEXPAND, 5 );
	$bSizer91->Add( $self->{btn_ok}, 0, wxBOTTOM | wxRIGHT, 10 );
	$bSizer91->Add( $self->{btn_cancel}, 0, wxBOTTOM | wxRIGHT, 10 );
	$bSizer91->Add( $self->{btn_help}, 0, wxBOTTOM | wxRIGHT, 10 );

	my $bSizer7 = Wx::BoxSizer->new(wxVERTICAL);
	$bSizer7->Add( $bSizer9, 0, wxEXPAND, 20 );
	$bSizer7->Add( $bSizer5, 1, wxEXPAND, 5 );
	$bSizer7->Add( 0, 0, 0, wxEXPAND, 5 );
	$bSizer7->Add( $bSizer91, 0, wxEXPAND, 5 );

	my $siz_main = Wx::BoxSizer->new(wxHORIZONTAL);
	$siz_main->Add( $sbSizer71, 0, wxALL, 10 );
	$siz_main->Add( $bSizer7, 1, 0, 10 );

	$self->SetSizer($siz_main);
	$self->Layout;

	return $self;
}

1;
