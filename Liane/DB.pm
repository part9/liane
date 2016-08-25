#!/usr/bin/perl

package Liane::DB;

use strict;
use warnings;
use utf8;

use Carp;
# Network order; there is NO nretrieve()
#   nstore \%table, 'file';
#   $hashref = retrieve('file');
use Storable qw( nstore retrieve );

sub load_db_file {
    my $self = shift;
    my $file = shift;
    
    my $db;
    
    # Retrieve throws an exception, if the given file
    # is not a valid Storable file.
    # In that case $@ is set to the exception,
    # otherwise it's false.
    eval { $db = retrieve( $file ) };
    confess $@ if $@;
    
    return if not _valid_db( $db );
    
    # IMPORTANT: set filename, so we can save it again!
    $db->filename( $file );
    return $db;      
}

# Checks, if the retrieved object is of 
# the class Liane::DB::LianeFile.
sub _valid_db {
    my $db = shift;
    # ref returns name of the class the object has been blesses with
    return 1 if ref( $db ) eq 'Liane::DB::LianeFile';
    return 0;
}

# Saves given Liane::DB::LianeFile
# object to db->filename.
sub save_db_file {
    my $self = shift;
    my $db   = shift;
    
    eval { return nstore( $db, $db->filename ) };
    confess $@ if $@;
}


1;
