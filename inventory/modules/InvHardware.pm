package InvHardware;
#printf "YOU ARE HERE:". __LINE__."\n";
use strict;
use warnings;
require Exporter;

our @ISA = qw(Exporter);
our @EXPORT=qw(&process_dmidecode &dmidecode_dict &process_cpuinfo &cpuinfo_dict &process_meminfo &meminfo_dict);

sub dmidecode_dict (&)   # ref to result
{

    my ($result) = @_;
	%$result = (
					_DESCRIPTION=>"Hardware vendor information",
					MANUFACTURER=>"Hardware Manufacturer",
					PRODUCT=>"Product Number",
					SERIAL=>"Serial Number",
					BIOS_VERSION=>"Bios version",
					BIOS_VENDOR=>"Bios Vendor" 
				);
}

sub process_dmidecode ($$&) # basdir, host , ref to result
{
	my ($basedir,$host,$result) = @_;
	%$result = (
					MANUFACTURER=>"unknown",
					PRODUCT=>"unknown",
					SERIAL=>"unknown",
					BIOS_VERSION=>"unknown",
					BIOS_VENDOR=>"unknown" 
				);
	my $dmifile="$basedir/$host/dmidecode"; 
	my $success=0;

	if( -r $dmifile && open(INPUT,"<",$dmifile)) {
		my $sys_block=0;
		my $bios_block=0;
		while (<INPUT>) {	
			chomp;
			my @data = split(/:/);
			if(defined $data[1]) { 
				$data[1] =~ s/^\s+//;
				$data[1]=~ s/\s+$//;
				$data[1]=~ s/,//; # extra commas really foo bar csv files
			}

			$sys_block=1 if ( $_ =~ "System Information" );
			if ($sys_block) {
				if ($_ =~ "Manufacturer") {
					if ( $data[1] eq "Hewlett-Packard") {
						$result->{ MANUFACTURER } = "HP" 
					} elsif ( $data[1] eq "SUN MICROSYSTEMS") {
						$result->{ MANUFACTURER } = "Sun Microsystems" 
					} elsif ( $data[1] eq "Dell Computer Corporation") {
						$result->{ MANUFACTURER } = "Dell Inc." 
					} else {
						$result->{ MANUFACTURER } = $data[1];
					}
				}
				$result->{ PRODUCT } = $data[1] if ($_ =~ "Product Name");
				$result->{ SERIAL } = $data[1] if ($_ =~ "Serial Number");
				$sys_block=0 if ($_ =~ "UUID");
			}
			$bios_block=1 if ( $_ =~ "BIOS Information" );
			if ($bios_block) {
				if ($_ =~ "Vendor") {
					if ( $data[1] eq "Hewlett-Packard") {
						$result->{ BIOS_VENDOR } = "HP" 
					} else {
						$result->{ BIOS_VENDOR } = $data[1];
					}
				}
				$result->{ BIOS_VERSION } = $data[1] if ($_ =~ "Version"); 
				$bios_block=0 if ($_ =~ "Characteristics");
			}

		}
		close INPUT;
		$success=1;
	} else {
		print STDERR "$host: Can't open \"$dmifile\" : $!\n";
	}
	return $success; #TODO RETURN ERROR
}

sub cpuinfo_dict (&)   # ref to result
{

    my ($result) = @_;
    %$result = (
					_DESCRIPTION=>"/proc/cpuinfo summary",
                    VENDOR=>"CPU Vendor",
                    FAMILY=>"CPU Family",
                    MODEL=>"CPU Model",
                    MODEL_NAME=>"CPU Model Name",
                    STEPPING=>"CPU Stepping",
                    CPU_SPEED=>"CPU Speed",
                    CPUS=>"Total CPU Count",
                    CORES=>"Total CPU Cores",
                );

}
sub process_cpuinfo ($$&) # basdir, host , ref to result
{
    my ($basedir,$host,$result) = @_;
    %$result = (
                    VENDOR=>"unknown",
                    FAMILY=>"unknown",
                    MODEL=>"unknown",
                    MODEL_NAME=>"unknown",
                    STEPPING=>"unknown",
                    CPU_SPEED=>"0",
                    CPUS=>"0",
                    CORES=>"0",
                );
    my $cpufile="$basedir/$host/cpuinfo";
    my $success=0;

    if( -r $cpufile && open(INPUT,"<",$cpufile)) {
		my @phy_cpu;
        while (<INPUT>) {
            chomp;
            my @data = split(/:/);
            next if (!defined $data[0]);
            if(defined $data[1]) {
                $data[1] =~ s/^\s+//;
                $data[1]=~ s/\s+$//;
            }
			if ( $_ =~ "processor" ) {
				$result->{ CORES } ++;
				next;
			}
			if ( $_ =~ "vendor_id" ) {
				$result->{ VENDOR } =$data[1];
				next;
			}
			if ( $_ =~ "family" ) {
				$result->{ FAMILY } =$data[1];
				next;
			}
			if ( $_ =~ "model" ) {
				if ( $_ =~ "name" ) {
					$result->{ MODEL_NAME } =$data[1];
				} else {
					$result->{ MODEL } =$data[1];
				}
				next;
			}
			if ( $_ =~ "stepping" ) {
				$result->{ STEPPING } =$data[1];
				next;
			}
			if ( $data[0] =~ "physical" ) {
				next if defined  $phy_cpu[$data[1]];
				$phy_cpu[$data[1]]=1;
				$result->{ CPUS } ++;
				next;
			}
			if ( $_ =~ "MHz" ) {
				$result->{ CPU_SPEED } =$data[1];
				next;
			}
		}
		close INPUT;
		$success=1;
	} else {
		print STDERR "$host: Can't open \"$cpufile\" : $!\n";
	}
	return $success;
}

sub meminfo_dict (&)   # ref to result
{

    my ($result) = @_;
    %$result = (
					_DESCRIPTION=>"/proc/meminfo summary",
                    MEMTOTAL=>"Physical Memory",
                    SWAPTOTAL=>"Swap in use",
                );
}

sub process_meminfo ($$&) # basdir, host , ref to result
{
    my ($basedir,$host,$result) = @_;
    %$result = (
                    MEMTOTAL=>0,
                    SWAPTOTAL=>0,
                );
    my $memfile="$basedir/$host/meminfo";
    my $success=0;

    if( -r $memfile && open(INPUT,"<",$memfile)) {
        my @phy_cpu;
        while (<INPUT>) {
            chomp;
            my @data = split(/:/);
            next if (!defined $data[0]);
            if(defined $data[1]) {
                $data[1] =~ s/\D//g;
                $data[1] =~ s/^\s+//;
                $data[1]=~ s/\s+$//;
            }
            if ( $_ =~ "MemTotal" ) {
                $result->{ MEMTOTAL } = $data[1];
                next;
            }
            if ( $_ =~ "SwapTotal" ) {
                $result->{ SWAPTOTAL } = $data[1];
                next;
            }
		}
		close INPUT;
		$success=1;
	} else {
		print STDERR "$host: Can't open \"$memfile\" : $!\n";
	}
	return $success;
}
# vim: ts=4  sw=4 autoindent
