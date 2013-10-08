package InvOS;
#printf "YOU ARE HERE:". __LINE__."\n";
use strict;
use warnings;
require Exporter;

our @ISA = qw(Exporter);
our @EXPORT=qw(&process_uptime &uptime_dict &process_uname &uname_dict &process_install_date &install_date_dict);

sub uptime_dict (&)   # ref to result
{

    my ($result) = @_;
	%$result = ( 
					_DESCRIPTION=>"Uptime",
					FULL=>"Full uptime string",
					UPTIME=>"Parsed uptime"
				 );
}

sub process_uptime ($$&)   # Basedir and hostname , ref to result
{ 
	my ($basedir,$host,$result) = @_;
	%$result = ( 
					FULL=>"Unknown",
					UPTIME=>"Unknown"
				 );
	my $uptime_file="$basedir/$host/uptime"; 
	my $success=0;
	if ( -r $uptime_file && open(INPUT,"<",$uptime_file)) {
		while (<INPUT>) {	
			chomp;
			$result->{ FULL }=$_;
		    my @data = split(" ");
			$data[2] =~ s/,//;
			$result->{ UPTIME }="$data[2] ".substr($data[3], 0, -1);
		}
		close INPUT;
		$success=1;
	} else {
		print STDERR "$host: Can't open \"$uptime_file\" : $!\n";
	} 
	return $success;
}

sub uname_dict (&)   # ref to result
{
    my ($result) = @_;
	%$result = ( 
					_DESCRIPTION=>"uname details",
					FULL=>"Full uname string",
					ARCH=>"uname -i",
					RELEASE=>"uname -r",
					VERSION=>"uname -v"
				 );
}

sub process_uname ($$&)   # Basedir and hostname , ref to result
{ 
	my $success=0;
	my ($basedir,$host,$result) = @_;
	%$result = ( 
					FULL=>"Unknown",
					ARCH=>"Unknown",
					RELEASE=>"Unknown",
					VERSION=>"Unknown"
				 );
	my $uname_file="$basedir/$host/uname"; 
	if ( -r $uname_file && open(INPUT,"<",$uname_file)) {
		while (<INPUT>) {	
			chomp;
			$result->{ FULL }=$_;
		}
		close INPUT;
		$success=1;
	} else {
		print STDERR "$host: Can't open \"$uname_file\" : $!\n";
	} 
	$uname_file="$basedir/$host/uname.arch"; 
	if ( -r $uname_file && open(INPUT,"<",$uname_file)) {
		while (<INPUT>) {	
			chomp;
			$result->{ ARCH }=$_;
		}
		close INPUT;
		$success=1;
	} else {
		print STDERR "$host: Can't open \"$uname_file\" : $!\n";
	} 
	$uname_file="$basedir/$host/uname.release"; 
	if ( -r $uname_file && open(INPUT,"<",$uname_file)) {
		while (<INPUT>) {	
			chomp;
			$result->{ RELEASE }=$_;
		}
		close INPUT;
		$success=1;
	} else {
		print STDERR "$host: Can't open \"$uname_file\" : $!\n";
	} 
	$uname_file="$basedir/$host/uname.version"; 
	if ( -r $uname_file && open(INPUT,"<",$uname_file)) {
		while (<INPUT>) {	
			chomp;
			$result->{ VERSION }=$_;
		}
		close INPUT;
		$success=1;
	} else {
		print STDERR "$host: Can't open \"$uname_file\" : $!\n";
	} 
	return $success;
}

sub install_date_dict (&)   # ref to result
{

    my ($result) = @_;
    %$result = (
					_DESCRIPTION=>"Installed Date",
                    DATE=>"Installed Date"
                 );

}

sub process_install_date ($$&)   # Basedir and hostname , ref to result
{
    my $success=0;
    my ($basedir,$host,$result) = @_;
    %$result = (
                    DATE=>0
                 );
    my $uname_file="$basedir/$host/install_date";
    if ( -r $uname_file && open(INPUT,"<",$uname_file)) {
		while (<INPUT>) {	
			chomp;
			$result->{ DATE }=$_;
		}
		$success=1;
	} else {
		print STDERR "$host: Can't open \"$uname_file\" : $!\n";
	} 
	return $success;
} 
# vim: ts=4  sw=4 autoindent
