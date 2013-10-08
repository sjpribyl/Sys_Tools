#!/usr/bin/perl
#ION/TT 2 - 1
#UHF 1 - end
#TMG_Spreader 1 - wtf

use warnings;
use strict;
use File::Basename;
use lib '/usr/local/bin/scripts/log_audit';
use log_audit;

select STDERR; $| = 1; # make unbuffered
select STDOUT; $| = 1; # make unbuffered

sub process_file() {
	my ($file, $result) = @_;
	
	my @dirs=split("/",$file);

#	print basename($file);		
#	print dirname($file);
	push( @{$result->{$dirs[$#dirs-1]}},$file) ;#, $dirs[$#dirs]\n;
	return 0;
}

print "\n***** Algibe Audit files *****\n";
exit process_files("/raid/var_data/Algibe/audit/",\&process_file);

