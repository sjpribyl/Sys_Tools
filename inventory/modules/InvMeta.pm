package InvMeta;
#printf "YOU ARE HERE:". __LINE__."\n";
use strict;
use warnings;
use Data::Dumper;
require Exporter;

our @ISA = qw(Exporter);
our @EXPORT=qw(&process_bcfg &bcfg_dict);

sub bcfg_dict (&)   # ref to result
{

    my ($result) = @_;
    %$result = (
					_DESCRIPTION=>"bcfg2 configuration information",
                    PROBES=>"Hash of bcfg2 Probes and values",
                    GROUPS=>"Array of bcfg2 Declared Groups",
                    PROFILE=>"bcfg2 Profile group",
                );
}

sub process_bcfg ($$&)   # Basedir and hostname , ref to result
{
	my ($basedir,$host,$result) = @_;
	%$result =  (
						PROFILE => "unknown",
					);

	my $theFile="$basedir/$host/bcfg2"; 

	my $success=0;
	my $profile=0;
	my $groups=0;
	my $probes=0;

	if(open(INPUT,"<",$theFile)) {
		while (<INPUT>) {	
			chomp;
			my @parts= split(" ");		
			next if($#parts < 0);
			if ($parts[0] =~ "Profile") {
				$profile=1;
				$groups=0;
				$probes=0;
			} elsif ($parts[0] =~ "Groups") {
				$profile=0;
				$groups=1;
				$probes=0;
			} elsif ($parts[0] =~ "Probes") {
				$profile=0;
				$groups=0;
				$probes=1;
			} elsif ($parts[0] eq "*") {
				if($groups == 1) {
					push(@{($result->{ GROUPS })},$parts[1]);
				} elsif ($probes == 1) {
					$result->{ PROBES }{$parts[1]}=$parts[2];
				} elsif ($profile == 1) {
					$result->{ PROFILE }=$parts[1];
				}
			} # Otherwise ignore 
		}
		close INPUT;
		$success=1;
	} else {
		print STDERR "$host: Can't open \"$theFile\" : $!\n";
	}
	return $success; 
}
#$|=1;
#
#my %result = ();
#process_bcfg('/var/www/Inventory',$ARGV[0],\%result);
#print Dumper (%result);
## $value can be any regex. be safe
#if ( grep( /dev-server/, @{($result{GROUPS})} ) ) {
#  print "found dev\n";
#}
#if ( grep( /qa-server/, @{($result{GROUPS})} ) ) {
#  print "found qa\n";
#}

# vim: ts=4  sw=4 autoindent
