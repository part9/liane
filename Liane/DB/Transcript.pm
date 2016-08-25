package Liane::DB::Transcript;

use strict;
use warnings;

use Liane::DB::Utterance;

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my $self  = {
        DATE       => 0,
        SITUATION  => '',
        UTTERANCES => [],
    };
    
    bless( $self, $class );    
    return $self;
}

# This beauty is needed to create
# a 'working copy' of the complete
# object; used by Editor
# http://perldesignpatterns.com/?CloningPattern
sub clone {    
    my $self = shift;
    my $copy = {
        DATE       => $self->{DATE},
        SITUATION  => $self->{SITUATION},
        UTTERANCES => [],
    };        
    
    # Cloning is a little more complex for
    # utterances. This makes cloning deep,
    # I guess.
    for ( my $i = 0; $i <  scalar( @{ $self->{UTTERANCES} } ); $i++ ) {
        $copy->{UTTERANCES}->[$i] = Liane::DB::Utterance->new;
        
        # These are actual copies of the speaker and text
        $copy->{UTTERANCES}->[$i]->speaker( $self->utterances->[$i]->speaker );
        $copy->{UTTERANCES}->[$i]->text( $self->utterances->[$i]->text );        
        
        # And more deep cloning...
        $copy->{UTTERANCES}->[$i]->analysis( $self->utterances->[$i]->analysis->clone );
    }
    
    bless( $copy, ref( $self ) );
    return $copy;
}

######################################################################
# Getters / Setters

sub date {
    my $self = shift;
    if( @_ ) { $self->{DATE} = shift }
    return $self->{DATE};
}

sub situation {
    my $self = shift;
    if( @_ ) { $self->{SITUATION} = shift }
    return $self->{SITUATION};
}

sub utterances {
    my $self = shift;
    return $self->{UTTERANCES};
}


######################################################################
# Instance methods for utterance handling

# Adds new utterance with given speaker
# and text as last element of utterances
# array.
sub add_utterance {
    my $self = shift;
    my ( $speaker, $text ) = @_;
    
    # Use this reference notation @{ $self->utterances }.
    # scalar( @array ) returns the number of elements, so
    # it's always one higher than the last item in use.  
    
	my $last_elem = scalar( @{ $self->utterances } );
		
    $self->utterances->[$last_elem] = Liane::DB::Utterance->new;
	$self->utterances->[$last_elem]->speaker( $speaker );
	$self->utterances->[$last_elem]->text( $text );
	 
    return 1;    
}

sub update_utterance {
    my $self = shift;
    my ( $id, $speaker, $text ) =  @_;
    
    $self->utterances->[$id]->speaker( $speaker );
    $self->utterances->[$id]->text( $text );
    
    # Updating the uttereance means dropping
    # everything we might know about words,
    # wordclasses etc.
    $self->utterances->[$id]->analysis( Liane::DB::Analysis->new );
}

sub delete_utterance {
    my $self = shift;
    my $id   = shift;
    
    # CAVE: only remove 1 item...
    splice( @{ $self->utterances }, $id, 1 );
}

sub list_utterances {
    my $self = shift;  
    
    return unless @{ $self->{UTTERANCES} };
    
    my @list = ();
    
    foreach my $utterance ( @{ $self->utterances } ) {         
        $list[ scalar( @list ) ] = [ ( $utterance->speaker, $utterance->text ) ];
    } 
    
    return @list;    
}

# Call utterance->[]->analysis->create_words( $text )
# for each utterance this has not yet been done for.
# FIXME: only neccessary for child's utterances!!
sub create_words {
    my $self = shift;    
    
    for ( my $i = 0; $i < scalar( @{  $self->utterances } ); $i++ ) {
               
        if ( $self->utterances->[$i]->analysis->words_created == 0 ) {
            $self->utterances->[$i]->analysis->create_words( $self->utterances->[$i]->text );                        
            $self->utterances->[$i]->analysis->words_created( 1 );
        }        
    }
}

1;
