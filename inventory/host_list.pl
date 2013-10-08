#!/usr/bin/perl 
#printf "YOU ARE HERE:". __LINE__."\n";
use strict;
use warnings;
use Getopt::Std;

use Cwd 'abs_path';
use File::Basename;
use lib dirname(abs_path($0)).'/modules';

use InvProc;
use InvRelease;
use InvOS;
use InvHardware;


our $outfile="host_list.txt";

my %hw_stats;
my %os_stats;
#my %bios_stats;
my $server_count=0;

sub print_header() { 
	return 1;
}

#TOOD PROPER exit code
sub print_line($) {  #HANDLE, HOST NAME
	my ($host) = @_;
	my $success=1;


	print "$host\n";
	
	return $success; #TODO NEED TO ACTUALLY CHECK THIS.
}

our $VERSION="1.0.0";

sub HELP_MESSAGE($$) {
    print "\t-h|--help this page\n";
	print "\t-v|--version the version\n";
	twiddle_output_help();
	exit 0;
}

my %opts;
&HELP_MESSAGE if (!getopts($outopts.'h',\%opts));
&HELP_MESSAGE if defined $opts{h};

twiddle_output(\%opts);

my $success=process_inventory(\&print_header,\&print_line);

exit !$success; #SHELL exit codes are oposite of perl, blarg
# vim: ts=4  sw=4 autoindent
