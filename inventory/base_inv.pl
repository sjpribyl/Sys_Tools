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
use InvMeta;


our $outfile="base_inv.csv";

my %hw_stats;
my %os_stats;
my %env_stats;
#my %bios_stats;
my $server_count=0;

sub print_header() { 
	return print "Host,S#,Product,Cores(CPUS){GHz},Memory(GB),Bios Version,Install,Arch,Distro,Type,Release,Kernel,uptime,env;\n";
}

#TODO PROPER exit code
sub print_line($) {  #HOST NAME
	my ($host) = @_;
	my $success=1;

	$server_count++;

	my %install_date;
	#$success=1 if (&process_install_date($basedir,$host,\%install_date));
	&process_install_date($basedir,$host,\%install_date);

	my %cpu_data;
	&process_cpuinfo($basedir,$host,\%cpu_data);

	my %mem_data;
	&process_meminfo($basedir,$host,\%mem_data);

	my %dmi_data;
	#$success=1 if (&process_dmidecode($basedir,$host,\%dmi_data));
	&process_dmidecode($basedir,$host,\%dmi_data);
	print "$host,";
	print $dmi_data{ SERIAL }.",";
	$hw_stats{$dmi_data{ MANUFACTURER }}+=1;
	if ( $dmi_data{ PRODUCT } =~ $dmi_data{ MANUFACTURER } ){
		$hw_stats{$dmi_data{ PRODUCT }}+=1;
		print $dmi_data{ PRODUCT }.",";
	} else {
		$hw_stats{$dmi_data{ MANUFACTURER }." ".$dmi_data{ PRODUCT }}+=1;
		print $dmi_data{ MANUFACTURER }." ";
		print $dmi_data{ PRODUCT }.",";
	}
	
	if ( $cpu_data{ CPUS } > 0 ) {
		print $cpu_data{ CORES }."(".$cpu_data{CPUS}.")";
	} else {
		print $cpu_data{ CORES };
	}
	printf ("{%.2f},",($cpu_data{ CPU_SPEED }/1000));
	use integer;
	print ($mem_data{ MEMTOTAL }/(1024**2)+1);
	print ",";
	no integer;
	print $dmi_data{ BIOS_VENDOR }." ".$dmi_data{ BIOS_VERSION }.",";
#	$bios_stats{$dmi_data{ BIOS_VENDOR }." ".$dmi_data{ BIOS_VERSION }}+=1;
	my $time_string = strftime "%m/%d/%Y", localtime($install_date{ DATE });
	print "$time_string,";

	my %uname;
	#$success=1 if(&process_uname($basedir,$host,\%uname));
	&process_uname($basedir,$host,\%uname);
	print $uname{ ARCH }.",";

	#redhat-release
	my %release;
	#$success=1 if(&process_release($basedir,$host,\%release));
	&process_release($basedir,$host,\%release);
	print $release{ DISTRO }.",";
	$os_stats{$release{ DISTRO }}+=1;
	print $release{ TYPE }.",";
	$os_stats{$release{ DISTRO }." ".$release{ TYPE }}+=1;
	print $release{ RELEASE }.",";
	$os_stats{$release{ DISTRO }." ".$release{ RELEASE }}+=1;

	print $uname{ RELEASE }.",";
	#uptime
	my %uptime;
	#$success=1 if(&process_uptime($basedir,$host,\%uptime));
	&process_uptime($basedir,$host,\%uptime);
	print $uptime{ UPTIME }.",";

	my %bcfg;
	&process_bcfg($basedir,$host,\%bcfg);
	# $value can be any regex. be safe
	if ( $host =~ /uschi10/ ) {
	  print "DEV";
	  $env_stats{DEV}+=1;
	} elsif ( $host =~ /test[0-9]/ ) {
	  print "DEV";
	  $env_stats{DEV}+=1;
	} elsif ( grep( /dev-server/, @{($bcfg{GROUPS})} ) ) {
	  print "DEV";
	  $env_stats{DEV}+=1;
	} elsif ( grep( /prod-server/, @{($bcfg{GROUPS})} ) ) {
	  print "PROD";
	  $env_stats{QA}+=1;
	} elsif ( grep( /qa-server/, @{($bcfg{GROUPS})} ) ) {
	  print "QA";
	  $env_stats{QA}+=1;
	} elsif ( grep( /traning-server/, @{($bcfg{GROUPS})} ) ) {
	  print "DEV";
	  $env_stats{QA}+=1;
	} else {
	  print "PROD";
	  $env_stats{PROD}+=1;
	}
	print "";

	print ";\n";
	
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

my $now = localtime time;
print "\n$now\n";
my $success=process_inventory(\&print_header,\&print_line);

print "\nServer Stats\n";
print "Server Count, $server_count\n";
print "Dev Servers, $env_stats{DEV}\n";
print "QA Servers, $env_stats{QA}\n";
print "PROD Servers, $env_stats{PROD}\n";

print "\nHardware, count\n";
foreach my $key (sort((keys %hw_stats))) {
    print "$key,$hw_stats{$key}\n";
}

print "\nOS, count\n";
foreach my $key (sort((keys %os_stats))) {
    print "$key,$os_stats{$key}\n";
}

exit !$success; #SHELL exit codes are oposite of perl, blarg
# vim: ts=4  sw=4 autoindent
