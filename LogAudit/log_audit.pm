#!/usr/bin/perl
use warnings;
use strict;
use DateTime;
use Date::Simple qw(days_in_month);
use File::Touch;
use POSIX;
use File::Temp qw(tempfile);

sub process_files($$) {
	my ($directory, $process_file) = @_;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$year+=1900; #Fix year
	$mon++; # fix month   localtime is 0-11 , all the functions are 1-12
	$mday= days_in_month($year,$mon);


	my $startdate = DateTime->new( year   => $year,
						   month  => $mon,
						   day    => 01,
						   hour   => 00,
						   minute => 00,
						   second => 00,
						   time_zone => strftime("%z", localtime()),
						 );

	my $enddate = DateTime->new( year   => $year,
						   month  => $mon,
						   day    => $mday,
						   hour   => 23,
						   minute => 59,
						   second => 59,
						   time_zone => strftime("%z", localtime()),
						 );
	print "Directory:\t$directory\n";
	print "Start date:\t$startdate\n";
	print "End date:\t$enddate\n";
	print STDERR  "\tDirectory:\t$directory\n";
	print STDERR  "\tStart date:\t$startdate\n";
	print STDERR  "\tEnd date:\t$enddate\n";

	#touch -t $olddate /tmp/oldfile
	my (undef, $startfile) = tempfile(OPEN => 0);
	my (undef, $endfile) = tempfile(OPEN => 0);

	my $touch_obj = File::Touch->new(
									atime=>$startdate->epoch,
									mtime=>$startdate->epoch,
									);
	$touch_obj->touch($startfile);

	#touch -t $newdate /tmp/newfile
	$touch_obj = File::Touch->new(
									atime=>$enddate->epoch,
									mtime=>$enddate->epoch,
								);
	$touch_obj->touch($endfile);

    my %result;
	open INPUT,"/usr/bin/find $directory -type f  -newer $startfile ! -newer $endfile 2>/dev/null | sort -n |" or die "$!";
	while(<INPUT>) {
		chomp;
		&{$process_file} ($_,\%result) 
#		print $_;
	}
	close INPUT;

	unlink($startfile);
	unlink($endfile);
	my $total=0;
	foreach my $key (sort keys %result) {
		print "$key\n";
		my $cnt=0;
		foreach my $file (sort @{$result{$key}}) {
			print "\t$file\t".(-s $file)."\n";
			$cnt++;
		}
		print "\n\tFile Count:\t$cnt\n\n";
		$total+=$cnt;
	}
	print STDERR "\tFile Count:\t$total\n";

	return 0;
}

1;
