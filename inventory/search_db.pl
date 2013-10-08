#!/usr/bin/perl
#printf "YOU ARE HERE:". __LINE__."\n";
use strict;
use warnings;
use Getopt::Std;

use Cwd 'abs_path';
use File::Basename;
use lib dirname(abs_path($0)).'/modules';
use POSIX qw(strftime);
use Data::Dumper;

our $basedir="/var/www/Inventory";
our $datadir="$basedir/.reports";
my $host_db=require "$datadir/host_db.txt";

print Data::Dumper->Dump([$host_db->{_DICTIONARY}], [qw(_DICTIONARY)]);


