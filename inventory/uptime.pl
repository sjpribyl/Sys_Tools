#!/usr/bin/perl 
#printf "YOU ARE HERE:". __LINE__."\n";
use strict;
use warnings;
use Getopt::Std;

use Cwd 'abs_path';
use File::Basename;
use lib dirname(abs_path($0)).'/modules';

use InvProc;
use InvOS;

#$outdir="."; #TODO REMOVE
our $outfile="uptime.csv";

my %uplist;

#TOOD PROPER exit code
sub process_host($) {  
	my ($host) = @_;
	my $success=1;

	#uptime
	my %uptime;
	my $days;
	&process_uptime($basedir,$host,\%uptime);
	if($uptime{UPTIME}=~"day") {
		my @data=split " ",$uptime{ UPTIME };
		$days=$data[0];
	} else {
		$days=1
	}
	if(defined $uplist{$days}) {
		$uplist{$days}.="\t$host\n";
	} else {
		$uplist{$days}="\t$host\n";
	}
	return $success;
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

my $now = localtime time;
print "\n$now\n";
my $success=process_inventory(undef,\&process_host);

foreach my $key (sort { $b <=> $a } ((keys %uplist))) {
	print "$key\n";
	print "$uplist{$key}\n";
}

exit !$success; #SHELL exit codes are oposite of perl, blarg


# vim: ts=4  sw=4 autoindent
