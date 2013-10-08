package InvTime;
#printf "YOU ARE HERE:". __LINE__."\n";
use strict;
use warnings;
use Data::Dumper;
require Exporter;

our @ISA = qw(Exporter);
our @EXPORT=qw(&process_ptp ptp_dict);

sub ptp_dict (&)   # ref to result
{

	my ($result) = @_;
    %$result = (
					_DESCRIPTION=>"PTP config details",
					PARENT_MAC => "Ethernet MAC Address of Parent",
					MASTER_MAC => "Ethernet MAC Address of Master",
				);
}

sub process_ptp ($$&)   # Basedir and hostname , ref to result
{ 
	my $success=0;
	my ($basedir,$host,$result) = @_;
	%$result = ( 
					PARENT_MAC => "unknown",
					MASTER_MAC => "unknown",
				);

	my $uname_file="$basedir/$host/ptp"; 
	if ( -r $uname_file && open(INPUT,"<",$uname_file)) {
		while (<INPUT>) {	
			chomp;
			my @parts=split(/\s+/);
			next if ( $#parts < 0);
			if ( $parts[1] =~ /parentUuid/ ) {
				$result->{ PARENT_MAC }=$parts[2];
			}
			if ( $parts[1] =~ /masterUuid/ ) {
				$result->{ MASTER_MAC }=$parts[2];
			}
		}
		close INPUT;
		$success=1;
	} else {
		print STDERR "$host: Can't open \"$uname_file\" : $!\n";
	} 
	return $success;
}


$|=1;
##
#my %result = ();
#ptp_dict('/var/www/Inventory',$ARGV[0],\%result);
#print Dumper(%result);
#process_ptp('/var/www/Inventory',$ARGV[0],\%result);
#print Dumper(%result);

# vim: ts=4  sw=4 autoindent
