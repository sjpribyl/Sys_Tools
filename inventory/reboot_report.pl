#!/usr/bin/perl 
#printf "YOU ARE HERE:". __LINE__."\n";
use strict;
use warnings;
use Getopt::Std;

use Cwd 'abs_path';
use File::Basename;
use lib dirname(abs_path($0)).'/modules';
use POSIX qw(strftime);

use InvProc;
use InvRelease;
use InvOS;
use InvHardware;

our $outfile="reboot_schedule.txt";
my (%sched, %thisweek);
my $week = strftime "%W", localtime;

sub print_header() {
	my $now = localtime time;
	print "\n$now\n";
	print "Week #".$week."\n";
	print "Servers with \"+\" are rebooted this week\n\n";

	return 1;
}

#TOOD PROPER exit code
sub process_host($) {  #HANDLE, HOST NAME
	my ($host) = @_;
	my $success=1;
	my $found=0;

	my $file="/var/www/Inventory/$host/cron/root";

	if(open INPUT,$file) {
		while (<INPUT>) {
			chomp;
			s/#.*//g;
			my @cron=split(/ /);
			next if (!defined $cron[5]);
			if ($cron[5] =~/reboot-schedule.sh/ ) {
				if (defined $cron[6]) {
					if (defined $cron[7]) {
						if ( $week%$cron[7] == $cron[6]%$cron[7] ) {
							$thisweek{$host}=1;
						} else {
							#TODO
						}
						push (@{$sched{$cron[7]}}, $host);
					} else {
						if ( $week%2 == $cron[6]%2 ) {
							$thisweek{$host}=1;
						} else {
						}
						push (@{$sched{2}}, $host);
					}
				} else {
					push (@{$sched{1}}, $host);
					$thisweek{$host}=1;
				}
				$found=1;
			} elsif ( $cron[5] =~/\/sbin\/reboot/ || ($cron[5] =~/\/sbin\/init/ && $cron[6] == "6" )) {
				push (@{$sched{1}}, $host);
				$thisweek{$host}=1;
				$found=1;
			} 
		}
		close INPUT
	}
	if(!$found) {
		push (@{$sched{0}}, $host);
	}
		
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

my $success=process_inventory(\&print_header,\&process_host);

foreach my $w_sched(sort { lc($a) cmp lc($b) }(keys(%sched))) {
	if($w_sched==0) {
		print "no reboot: ".($#{$sched{$w_sched}}+1)."+" \n";
	} else {
		print "reboot every ".($w_sched==1?"week":"$w_sched weeks")." : $#{$sched{$w_sched}}\n" if $w_sched>0;
	}
	foreach my $host(sort (@{$sched{$w_sched}})) {
		print "\t$host ";
		my %uptime;
		my $days;
		&process_uptime($basedir,$host,\%uptime);
		if($uptime{UPTIME}=~"day") {
			print $uptime{ UPTIME };
			print " ** reboot missed **" if ($w_sched>0 && (split " ",$uptime{ UPTIME })[0] > $w_sched*7);
		} else {
			print "1 day";
		}
		print (defined $thisweek{$host}?" + ":"");
		print "\n";
	}
	print "\n";
}

exit !$success; #SHELL exit codes are oposite of perl, blarg
# vim: ts=4  sw=4 autoindent
