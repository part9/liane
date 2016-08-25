package Liane::DB::LianeFile;

use strict;
use warnings;

use Liane::DB::Student;
use Liane::DB::Transcript;

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my $self  = {
        FILENAME    => '',
        CHANGED     => 0,
        STUDENT     => Liane::DB::Student->new,
        TRANSCRIPTS => [],
    };
    
    bless( $self, $class );
    
    return $self;
}

######################################################################
# Accessors

sub filename {
    my $self = shift;
    if( @_ ) { $self->{FILENAME} = shift }
    return $self->{FILENAME};
}

sub changed {
    my $self = shift;
    if( @_ ) { $self->{CHANGED} = shift }
    return $self->{CHANGED};
}

sub student {
    my $self = shift;
    return $self->{STUDENT};
}

sub transcripts {
    my $self = shift;
    return $self->{TRANSCRIPTS};
}

######################################################################
# Instance methods for Transript Handling

# Append new transcript with given information
# to the transcript array of the current object.
sub add_transcript {
    my $self = shift;
    my ( $date, $situation ) = @_;
    
    # Creates new Transcript List-Item as
    # last element of $self->transcript Array. We have to
    # use this reference notation @{ $self->transcript }.
    # scalar( @array ) returns the number of elements, so
    # it's always one higher than the last item in use.  
    
	my $last_elem = scalar( @{ $self->transcripts } );
		
    $self->transcripts->[$last_elem] = Liane::DB::Transcript->new;
	$self->transcripts->[$last_elem]->date( $date );
	$self->transcripts->[$last_elem]->situation( $situation );
	    
    return 1;
}

sub delete_transcript {
    my $self = shift;
    my $id   = shift;
    
    delete $self->transcripts->[ $id ];    
}
 
# Returns list of transcripts like 
# ( '12.05.2014', 'Situation' )
sub list_transcripts {
    my $self = shift;
    
    # Nothing to do without transripts.
    return unless @{ $self->transcripts };
    
    my @list = ();
    my( $date, $situation );
    
    # Use scalar( @list ) to access last element + 1
    # (returns number of items in list).
    foreach my $transcript ( @{ $self->transcripts } ) {        
        
        $date       = Liane::DateTime::date_dmy( $transcript->date );
        $situation  = $transcript->situation;      
        
        $list[ scalar( @list ) ] = [ ( $date, $situation ) ];
    }
    
    return @list;
}

1;
