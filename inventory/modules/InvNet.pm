package InvNet;
#printf "YOU ARE HERE:". __LINE__."\n";
use strict;
use warnings;
use Data::Dumper;
require Exporter;

our @ISA = qw(Exporter);
our @EXPORT=qw(&process_ip_addr ip_addr_dict);

sub ip_addr_dict (&)   # ref to result
{

	my ($result) = @_;
	$result->{'INTERFACE'}= { 
									_DESCRIPTION=>"Network interface details",
									MASTER => "Master Bond Name",
									IP => "IP Address",
									MASK => "Net Mask",
									ETHER => "Ethernet MAC Address",
								};
	$result->{'_DESCRIPTION'}= "Hash of network interface names";
}

sub process_ip_addr ($$&)   # Basedir and hostname , ref to result
{ 
	my $success=0;
	my ($basedir,$host,$result) = @_;
	%$result = ( ); #list of nics and details

	my $uname_file="$basedir/$host/ip_addr"; 
	if ( -r $uname_file && open(INPUT,"<",$uname_file)) {
		my $nic;
		while (<INPUT>) {	
			chomp;
			my @parts=split(/\s+/);
			if ( $parts[0] =~ /[0-9]+:/ ) {
				chop($parts[0]);
				chop($parts[1]);
				if ( $parts[1] =~ /\@/ ) {
					my ($data,$junk)= split(/\@/,$parts[1],2);
					$nic = $data;
				} else {
					$nic=$parts[1];
				}
				my $master=0;
				foreach my $data (@parts)  {
					if ($master==1) {
						$result->{$nic}->{ MASTER }=$data 
					}
					if ($data =~ "master") {
						$master=1;
					} else {
						$master=0;
					}
				}
			} 
			if ( $parts[1] =~ /^inet$/ ) {
				my ($IP,$MASK)=split(/\//,$parts[2]);
				$result->{$nic}->{ IP }=$IP;
				$result->{$nic}->{ MASK }=$MASK;
			}
			if ( $parts[1] =~ /link/ ) {
				$result->{$nic}->{ ETHER }=$parts[2];
			}
		}
		close INPUT;
		$success=1;
	} else {
		print STDERR "$host: Can't open \"$uname_file\" : $!\n";
	} 
	return $success;
}


#$|=1;
##
#my %result = ();
#process_ip_addr('/var/www/Inventory',$ARGV[0],\%result);
#print Dumper(%result);
#foreach my $key ((keys %result)) {
#	print "$key $result{$key}->{ ETHER } \n";
#}

# vim: ts=4  sw=4 autoindent
