#!/usr/bin/perl

use strict;
use warnings;

use FBP::Perl;

# 'dialog' for Wx::Dialog or
# 'frame'  fpr Wx::Frame
my $formtype = $ARGV[0];
# Name of the frame/dialog, as set in
# wxFormBuilders object properties.
my $name     = $ARGV[1];
# Filename of the fpb-File.
my $filename = $ARGV[2];

die 'fbp2pm.pl dialog|frame [name] [filename]' unless defined $filename;

# Strip extension.
$filename =~ s{\.[^.]+$}{};

# Create FBP-Object and parse fbp-File
my $fbp = FBP->new;
$fbp->parse_file( $filename.'.fbp' );

# Create Generator
my $generator = FBP::Perl->new( project => $fbp->project );

# Open pm-File for output
open( FILE, '>', $filename.'.pm');

# The actual generator command differs
# slightly depending on the type
# of form used!
if ( $formtype eq 'dialog' ) {
    print FILE $generator->flatten( $generator->dialog_class( $fbp->dialog( $name ) ) );
}
elsif ( $formtype eq 'frame' ) {
    print FILE $generator->flatten( $generator->frame_class( $fbp->form( $name ) ) );
}

close FILE;
