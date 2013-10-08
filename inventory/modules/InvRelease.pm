package InvRelease;
#printf "YOU ARE HERE:". __LINE__."\n";
use strict;
use warnings;
require Exporter;

our @ISA = qw(Exporter);
our @EXPORT=qw(&process_release &release_dict);

sub release_dict (&)   # ref to result
{

    my ($result) = @_;
	%$result =  (
						_DESCRIPTION=>"OS Release Details",
						FULL => "Full release string",
						RELEASE =>"Parsed OS Release",
						DISTRO =>"Parsed OS Distribution",
						TYPE =>"OS Type"
#						LICENSE =>"Licensing info systemid"
#TODO MOVE TO NEW FUNCTION TO PART SYSTEMID FILE						SYSTEMID =>"none"
					);

}

sub process_release ($$&)   # Basedir and hostname , ref to result
{
	my ($basedir,$host,$result) = @_;
	%$result =  (
						FULL => "unknown",
						RELEASE =>"unknown",
						DISTRO =>"unknown",
						TYPE =>"unknown"
#						LICENSE =>"none"
#TODO MOVE TO NEW FUNCTION TO PART SYSTEMID FILE						SYSTEMID =>"none"
					);

	my $redhat_file="$basedir/$host/redhat-release"; 
	my $suse_file="$basedir/$host/SuSE-release"; 
	my $debian_file="$basedir/$host/debian_version"; 
	my $ubuntu_file="$basedir/$host/lsb-release"; 

	my $success=0;
	if ( -r $redhat_file) {
		if(open(INPUT,"<",$redhat_file)) {
			while (<INPUT>) {	
				chomp;
				$result->{ FULL }= $_;
				my @parts= split(" ");		
				if ($parts[0] eq "Fedora") {
					$result->{ DISTRO }= "Fedora";
					$result->{ RELEASE }= $parts[2]; 
					$result->{ TYPE } = "Generic"
				} else {
					$result->{ DISTRO }= "RedHat";
					$result->{ RELEASE }= $parts[6]; 
					$result->{ TYPE } = $parts[4];
					if ( $parts[4] eq "ES" ) {
						$result->{ RELEASE }.=".".substr($parts[$#parts],0,1);
					}
				}
			}
			close INPUT;
			$success=1;
		} else {
			print STDERR "$host: Can't open \"$redhat_file\" : $!\n";
		}
	} elsif ( -r $suse_file) {
		if(open(INPUT,"<",$suse_file)) {
			while (<INPUT>) {	
				chomp;
				my @parts= split(" ");		
				if ( $_ =~ "SUSE" ) {
					$result->{ FULL }= $_ ;
					$result->{ DISTRO }= "SuSE";
					$result->{TYPE}= $parts[3];
				}
				$result->{ RELEASE }= $parts[2]  if ( $_ =~ "VERSION");
				$result->{ RELEASE }.= ".".$parts[2]  if ( $_ =~ "PATCHLEVEL");
			}
			close INPUT;
			$success=1;
		} else {
			print STDERR "$host: Can't open \"$suse_file\" : $!\n";
		}
	} elsif ( -r $debian_file) {
		$result->{ TYPE }="generic";
		if ( -r $ubuntu_file) {
			if(open(INPUT,"<",$ubuntu_file)) {
				$result->{ DISTRO }= "Ubuntu";
				while (<INPUT>) {	
					chomp;
					my @parts= split("=");		
					$result->{ CODENAME }= $parts[1] if ( $_ =~ "DISTRIB_CODENAME");
					$result->{ RELEASE }= $parts[1] if ( $_ =~ "DISTRIB_RELEASE");
					$result->{ FULL }= $parts[1] if ( $_ =~ "DISTRIB_DESCRIPTION");
				}
				close INPUT;
				$success=1;
			}
		} else {
			if(open(INPUT,"<",$debian_file)) {
				$result->{ DISTRO }= "Debian";
				while (<INPUT>) {	
					chomp;
					$result->{ FULL }= $_;
					$result->{ RELEASE }= $_;
				}
				close INPUT;
				$success=1;
			}
		}
	}
	return $success; 
}

#		my $rhn="$basedir/$host/rhn/install-num"; 
#		if ( -f $rhn && open(INPUT,"<",$rhn)) {
#			while (<INPUT>) {	
#				chomp;
#				$result->{ LICENSE }= $_;
#			}
#			close INPUT;
#		} else {
#			print STDERR "$host: Can't open \"$rhn\" : $!\n";
#		}
# vim: ts=4  sw=4 autoindent
