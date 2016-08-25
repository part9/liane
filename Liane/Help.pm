package Liane::Help;

use strict;
use warnings;
use utf8;

use Switch;

sub help {
    my ( $self, $event ) = @_;       
    
    my $text = '';    
    my $id   = $event->GetId;
    
    switch ( $id ) {     
        # Help button
        case   1 { $text = "Um mit der Analyse zu beginnen, muss zunächst eine Äußerung des Kindes aus " .
                            "dem Transkript ausgewählt werden. Sobald eine Äußerung ausgewählt ist, kann " .
                            "im Bereich (A) Analyse auf Satzeben durchgeführt werden.\n\n" .
                            "Im Bereich (B) wird die Analyse auf Wortebene durchgeführt. Dazu muss zunächst " .
                            "ein Wort ausgewählt werden (1). Anschließend können Wortart (2), Merkmalsklasse (3) " .
                            "und ggf. Verbflexion (4) angegeben werden.\n\n" .
                            "Zu jeder der grammatische Kategorien kann Hilfe aufgerufen werden. " .
                            "Dazu die entsprechende Kategorie mit der rechten Maustaste anklicken."; 
        }        
        # Wordclass
        case [200..299] { $text = help_text_wordclass( $id ); }
        case [300..399] { $text = help_text_flection( $id ); }
        case [400..499] { $text = help_text_verbmarker( $id ); }
        case [500..599] { $text = help_text_structure( $id ); }
        case [600..699] { $text = help_text_case_agreement( $id ); }
        case [700..799] { $text = help_text_elisions( $id ); }
        case [800..899] { $text = help_text_svi( $id ); }
        
    }
    
    if ( $text eq '' ) {
        $text = "Für diesen Bereich ist leider\n" .
                "noch keine Hilfe verfügbar.";
    }
    
    Liane::Wx::Dialog->help( $text );
}

######################################################################
# Private help text functions

sub help_text_wordclass {
    my $id = shift;

    my $text = '';
    
    switch ( $id ) {            
        case 210 { $text = 'Synonym für Substantiv, z.B.: Die >Blume< blüht.';
        }
        case 211 { $text = 'Definite (bestimmte) Artikel (der, die, das) und '.
                           'indefinite (unbestimmte) Artikel (einer, eine, eines).'; 
        }
        case 212 { $text = 'Beschreibt Eigenschaften oder Merkmale, z.B.: ' .
                           'Das >große< Kind ist >traurig<.'; 
        }
        case 213 { $text = 'Personalpronomina (persönliche Fürwörter) mit ' .
                           'den Nennformen ich, du, er/sie/es, wir, ihr, sie.' 
        }
        case 214 { $text = 'Wortart, die als Vertreter des Nomens bzw. der ' .
                           'Nominalphrase dient, z.B.: Ich wasche >mich<.' .
                           'Das ist >mein< Buch.' ;
        }
        
        case 220 { $text = 'Verben mit eigener, lexikalischer Bedeutung. ' . 
                           'Können allein das Prädikat des Satzes bilden, ' .
                           'z.B.: Der Mann >lacht<.';
        }
        case 221 { $text = 'Auxiliarverben sind Hilfsverben, die der ' . 
                           'Tempusbildung dienen: haben, sein und werden.';
        }
        case 222 { $text = 'Modalverben drücken eine Modalität ' . 
                           '(Notwendigkeit, Wunsch) aus, z.B. dürfen, ' . 
                           'können, wollen, müssen.';
        }
        case 223 { $text = 'Finite Form von sein oder werden, z.B. ' . 
                           'Lars >ist< Surfer.' ;                           
        }
        
        case 230 { $text = 'Nicht flektierbares Umstandswort, z.B. ' .
                           'abends, hier, also, gern oder ziemlich.';
        }
        case 231 { $text = 'Nicht flektierbares Verhältniswort, z.B. ' . 
                           'auf, bei, während, wegen. Regiert immer einen ' .
                           'oder mehrere Kasus.';
        }
        case 232 { $text = 'Nicht flektierbare Wortart zur Verbindung ' . 
                           'von Sätzen. Man unterscheidet subordinierende ' . 
                           '(unterordnende, z.B. dass, weil, obwohl) und ' .
                           'koordinierende (gleich-/nebenordnende, z.B. ' .
                           'und, aber, oder) Konjunktionen.';
        }
    }
    
    return $text;
}    

sub help_text_flection {
    my $id = shift;

    my $text = '';
    
    switch ( $id ) {
        case 301 { $text = 'Zahlform: Einzahl.'; }
        case 302 { $text = 'Zahlform: Mehrzahl.'; }
        
        case 311 { $text = 'Frageprobe: Wer oder was?'; }
        case 312 { $text = 'Frageprobe: Wessen?'; }
        case 313 { $text = 'Frageprobe: Wen oder was?'; }
        case 314 { $text = 'Frageprobe: Wem oder was?'; }
        
        case 321 { $text = 'Grammatisches Geschlecht: männlich.'; }
        case 322 { $text = 'Grammatisches Geschlecht: weiblich.'; }
        case 323 { $text = 'Grammatisches Geschlecht: sächlich.'; }
        
        case 331 { $text = 'Gegenwartsform, z.B. Sie >lacht<.'; }
        case 332 { $text = 'Wird durch immer durch Präfigierung ' .
                           'und Suffigierung gebildet, z.B. ' .
                           'Sie hat >ge-lach-t<.'; 
        }
        case 333 { $text = 'Im Deutschen gibt es die sechs Tempora Präsens, ' .
                           'Präteritum, Perfekt, Plusquamperfekt, Futur I ' .
                           'und Futur II. Präsens und (Partizip) Perfekt' .
                           'spielen in der Kindersprache die größte Rolle.'; 
        }
        
        case 341 { $text = 'Es werden die drei Personen Sprecher, ' .
                           'Hörer und Unbeteiligte unterschieden, die ' .
                           'sowohl im Singular als auch im Plural auftreten können.\n\n' .
                           '1. Person = Sprecher: ich/wir.'; 
        }
        case 342 { $text = 'Es werden die drei Personen Sprecher, ' .
                           'Hörer und Unbeteiligte unterschieden, die ' .
                           'sowohl im Singular als auch im Plural auftreten können.\n\n' .
                           '2. Person = Hörer: du/ihr.'; 
        }
        case 343 { $text = 'Es werden die drei Personen Sprecher, ' .
                           'Hörer und Unbeteiligte unterschieden, die ' .
                           'sowohl im Singular als auch im Plural auftreten können.\n\n' .
                           '3. Person = Unbeteiligte: er, sie, es/sie.'; 
        }
    }
    
    return $text;    
}  

sub help_text_verbmarker {
    my $id = shift;

    my $text = 'Das Verb muss in Übereinstimmung (morphologischer Kongruenz) ' . 
               'mit dem Subjekt knjugiert werden, dieses Phänomen wird als ' . 
               'Subjekt-Verb-Kongruenz bezeichnet. Die Kongruenz bezieht sich ' .
               'dabei auf die grammatischen Merkmalsklassen, nach denen beide ' . 
               'Wortarten veränderlich sind. Nomen und Verben müssen also im ' . 
               'Numerus kongruieren, z.B. wird der Hund läuf-t im Plural zu ' .
               'die Hund-e lauf-en (das Verb steht jeweils in der 3. Person). ' .
               'Personalpronomen und Verben müssen sowohl im Numerus als auch ' .
               'in der Person kongruieren, z.B. ich lach-e (1. Person Singular) ' .
               'oder ihr lach-t (2. Person Plural).';
    
    return $text;    
}    

sub help_text_structure {
    my $id = shift;

    my $text = '';
    
    switch ( $id ) {
        case 510 { $text = 'Beispiel: Ball da.'; }
        case 511 { $text = 'Beispiel: Ball geben.'; }
        
        case 520 { $text = 'Beispiel: Hund jetzt laufen?'; }
        case 521 { $text = 'Beispiel: Da ist Wasser.'; }
        case 522 { $text = 'Beispiel: Der will ein bisschen spielen. Die hat das ausgetrunken.'; }
        case 523 { $text = 'Beispiel: Das sind schon ganz viele.'; }
        
        case 530 { $text = 'Beispiel: Das ist lustig, weil es ganz schnell ist.'; }
    }
    
    return $text;    
}

sub help_text_case_agreement {
    my $id = shift;

    my $text = "Vollverben und Präpositionen sind rektionsfähig, d.h. " .
               "sie legen den Kasus der Artikel und Bezugssubstantive fest:\n" .
               "(1) Ich stehe auf >der Leiter<.\n" . 
               "(2) Ich steige auf >die Leiter<.\n" .
               "In (1) wird der Akkusativ festgelegt (Akkusativkontext), " .
               "in (2) der Dativ (Dativkontext). Das Objekt steht in diesen " .
               "Beispielen jeweils im korrekten Kasus.\n\n" .
               "In den Eingabefeldern wird angegeben, bei wie vielen Objekten " .
               "im entsprechenden Kontext der betreffenden Kasus markiert wurde." ;
    
    return $text;    
}  

sub help_text_elisions {
    my $id = shift;

    my $text = 'Es wird angegeben, ob obligate Satzelemente ausgelassen wurden. ' .
               'Es ist zu berücksichtigen, dass es im Sinne der Sprachökonomie ' . 
               'häufig zu Auslassungen kommt, die hier nicht notwendigerweise ' . 
               'anegegeben werden müssen.';   
    
    return $text;    
}  

sub help_text_svi {
    my $id = shift;

    my $text = 'Formuliert man einen Aussagesatz (z.B. Sophie lacht.) in eine ' . 
               'Entscheidungsfrage um (Lacht Sophie?), so kommt es zur ' .
               'Subjekt-Verb-Inversion : Das Subjekt und das finite Verb ' .
               'wechseln ihre Stellung im Satz.';
    
    if ( $id == 811 ) { 
        $text = 'Auch bei der Umformulierung des Aussagesatzes >Ich mag ' . 
                'Bananen.< zu >Bananen mag ich.< wechseln das Subjekt ' . 
                'und das finite Verb ihre Stellung im Satz.' ;
    }
    
    return $text;    
}  

1;
