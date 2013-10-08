#!/usr/bin/perl 
#printf "YOU ARE HERE:". __LINE__."\n";
use strict;
use warnings;
use Getopt::Std;

use Cwd 'abs_path';
use File::Basename;
use lib dirname(abs_path($0)).'/modules';
use POSIX qw(strftime);
use Data::Dumper;

use InvProc;
use InvRelease;
use InvOS;
use InvHardware;
use InvMeta;
use InvNet;
use InvTime;



our $outfile="host_db.txt";

my %host_db=();
my %dictionary=();

sub print_header() { 
	$host_db{ '_DICTIONARY' } -> {'HOST'} -> { _DESCRIPTION } = "Hash of host names";

	my %ip_addr_dict;
	&ip_addr_dict(\%ip_addr_dict);
	$host_db{ '_DICTIONARY' } -> {'HOST'} -> { INTERFACES } = \%ip_addr_dict ;

	my %dmi_dict;
	&dmidecode_dict(\%dmi_dict);
	$host_db{ '_DICTIONARY' } -> {'HOST'} -> {'DMI'} = \%dmi_dict ;

	my %cpuinfo_dict;
	&cpuinfo_dict(\%cpuinfo_dict);
	$host_db{ '_DICTIONARY' } -> {'HOST'} -> {'CPUINFO'} = \%cpuinfo_dict ;

	my %meminfo_dict;
	&meminfo_dict(\%meminfo_dict);
	$host_db{ '_DICTIONARY' } -> {'HOST'} -> {'MEMINFO'} = \%meminfo_dict ;

	my %bcfg_dict;
	&bcfg_dict(\%bcfg_dict);
	$host_db{ '_DICTIONARY' } -> {'HOST'} -> {'BCFG'} = \%bcfg_dict ;

	my %install_date_dict;
	&install_date_dict(\%install_date_dict);
	$host_db{ '_DICTIONARY' } -> {'HOST'} -> {'INSTALL'} = \%install_date_dict ;

	my %uname_dict;
	&uname_dict(\%uname_dict);
	$host_db{ '_DICTIONARY' } -> {'HOST'} -> {'UNAME'} = \%uname_dict ;

	my %release_dict;
	&release_dict(\%release_dict);
	$host_db{ '_DICTIONARY' } -> {'HOST'} -> {'RELEASE'} = \%release_dict ;

	my %uptime_dict;
	&uptime_dict(\%uptime_dict);
	$host_db{ '_DICTIONARY' } -> {'HOST'} -> {'UPTIME'} = \%uptime_dict ;

	my %ptp_dict;
	&ptp_dict(\%ptp_dict);
	$host_db{ '_DICTIONARY' } -> {'HOST'} -> {'PTP'} = \%ptp_dict ;

	print Data::Dumper->Dump([\%host_db], [qw(host_db)]);
	return 1;
}

#TODO PROPER exit code
sub print_line($) {  #HOST NAME
	my ($host) = @_;
	my $success=1;


	my %install_date;
	&process_install_date($basedir,$host,\%install_date);
	$host_db{$host} -> { INSTALL } = \%install_date;

	my %cpu_data;
	&process_cpuinfo($basedir,$host,\%cpu_data);
	$host_db{$host}->{CPUINFO} = \%cpu_data;

	my %mem_data;
	&process_meminfo($basedir,$host,\%mem_data);
	$host_db{$host}->{MEMINFO} = \%mem_data;

	my %dmi_data;
	&process_dmidecode($basedir,$host,\%dmi_data);
	$host_db{$host}->{DMI} = \%dmi_data;

	my %uname;
	&process_uname($basedir,$host,\%uname);
	$host_db{$host}->{UNAME} = \%uname;

	my %release;
	&process_release($basedir,$host,\%release);
	$host_db{$host}->{RELEASE} = \%release;

	my %uptime;
	&process_uptime($basedir,$host,\%uptime);
	$host_db{$host}->{UPTIME} = \%uptime;

	my %bcfg;
	&process_bcfg($basedir,$host,\%bcfg);
	$host_db{$host}->{BCFG} = \%bcfg;
	
	my %ip_addr;
	&process_ip_addr($basedir,$host,\%ip_addr);
	$host_db{$host}->{INTERFACES} = \%ip_addr;

	my %ptp;
	&process_ptp($basedir,$host,\%ptp);
	$host_db{$host}->{PTP} = \%ptp;


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

my $success=process_inventory(\&print_header,\&print_line);

print Data::Dumper->Dump([\%host_db], [qw(host_db)]);

exit !$success; #SHELL exit codes are oposite of perl, blarg
# vim: ts=4  sw=4 autoindent
