#!/usr/bin/perl

package main;

$main::VERSION = '1.10';
$main::DATE    = '08/25/2016';

use strict;
use warnings;
use diagnostics;
use utf8;

use Wx::Perl::Packager;
use Wx;

use lib './';

use Liane::Wx::App;

my $liane = Liane::Wx::App->new->MainLoop;
