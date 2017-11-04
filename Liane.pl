#!/usr/bin/perl

package main;

$main::VERSION = '1.20';
$main::DATE    = '11/04/2017';

use strict;
use warnings;
use diagnostics;
use utf8;

use Wx::Perl::Packager;
use Wx;

use lib './';

use Liane::Wx::App;

my $liane = Liane::Wx::App->new->MainLoop;
