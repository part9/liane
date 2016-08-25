package Liane::File;

use strict;
use warnings;
use utf8;

use Wx qw(wxFD_OPEN wxFD_SAVE wxFD_FILE_MUST_EXIST wxID_CANCEL);

use File::Spec::Functions qw(catfile);

# Opens LianeDB file (using open-file-dialog!)
# and returns LianeFile object if successful,
#     returns undef            if user cancelled,
#     dies                     if file invalid.
sub open_file {
    my $self  = shift;
    my $parent = shift;

    my $file = &get_new_filename( $self, $parent, 'Liane-Akte öffnen', '*.ldb' );
    return if not defined $file;

    my $db = Liane::DB->load_db_file( $file );    
    
    # If load_db_file returns undef, db is invalid.
    die 'Die ausgewählte Datei ist keine gültige Liane-Akte!' unless defined( $db );

    return $db;
}

sub save_file {
    my $self = shift;
    my ( $parent, $db ) = @_;
        
    Liane::DB->save_db_file( $db )
}

# Returns filename of selected file.
# Behavior varies, if $save is defined!
#
# $save not defined: shows open dialog;
#                    file must exist.
# $save is  defined: shows save dialog;
#                    asks user on overwrite.
sub get_new_filename {
    my $self  = shift;
    my ( $parent, $title, $ftype, $save ) = @_;

    # Set look and feel of dialog
    my ( $dialog, $dialog_style );
    if( defined $save ) { 
        $dialog_style = wxFD_SAVE;
    }
    else {
        $dialog_style = wxFD_OPEN|wxFD_FILE_MUST_EXIST;
    }

    my ( $filename, $dirname, $file );
    my $overwrite = 1;

    # Loop, to give user the chance to
    # select a new file, if he does not
    # want to overwrite the chosen one.
    do {  
        $dialog = Wx::FileDialog->new( $parent, $title, '', '', $ftype, $dialog_style );
        
        # Return undef, if cancelled by the user.
	    return if ( $dialog->ShowModal == wxID_CANCEL );
	
        # Catfile creates OS independent path by taking care of slashes.
	    $filename = $dialog->GetFilename;
	    $dirname  = $dialog->GetDirectory;
	    $file     = catfile( $dirname, $filename );
	
	    # If saving ask, if user wants to overwrite.
        if ( -e $file and defined $save ) {
            $overwrite = Liane::Wx::Dialog->yes_no( $parent, "Die Datei besteht bereits.\nSoll die Datei überschrieben werden?" );
        }    
	
	} until ( $overwrite == 1 );
	
	# Make sure $file really has the reqired
	# file extension!	
	if ( substr( $file, -3 ) ne substr( $ftype, -3 ) ) {
	    $file .= '.' . substr( $ftype, -3 );
	}
	
	return $file;	
}

1;
