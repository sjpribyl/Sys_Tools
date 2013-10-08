package InvProc;

use strict;
use warnings;
require Exporter;

our $basedir="/var/www/Inventory";
our $outdir="$basedir/.reports";
our $outfile="output.txt";
our $errfile="-";
our $outopts="f:d:e:";

our @ISA = qw(Exporter);
our @EXPORT=qw($errfile $outopts $outfile $outdir $basedir &process_inventory &twiddle_output &twiddle_output_help);


sub process_inventory (&&) { # header sub ref, line function ref

	my ($print_header,$print_line)= @_;
	my $success=1;

	if (!opendir(DIR,$basedir)) {
		print  STDERR "Can't open the current directory: $!\n";
		$success=0;
	} else {
		my @host_names = readdir(DIR) or die "Unable to read current dir:$!\n";
		closedir(DIR);

		my $result=0;	
		if (defined $print_header) { #print the header
			$success=0 if (!&$print_header());
		}
		if ( $success ) {
			foreach my $host (@host_names) {
				next if ($host eq ".");   # skip the current directory entry
				next if ($host eq "..");  # skip the parent  directory entry
				next if ($host =~ "^\\.");  # skip the parent  directory entry
				
				if (-d "$basedir/$host" ){            # is this a directory?
					if (defined $print_line) { #print the line
						$success=0 if (!&$print_line($host));
					}
				}
			}
		} 
	}
	return $success;
}

sub twiddle_output_help()
{
    print "\t-f output file, - for stdout\n";
	print "\t\tdefault is $outfile\n";
	print "\t-d output directory\n";
	print "\t\tdefault is $outdir\n";
	print "\t-e error output file\n";
	print "\t\tdefault is stderr\n";
}

sub twiddle_output(%)  # Options from get opts,
{
	my (%opts)=%{$_[0]};
	my $out_path;
	my $err_path="";
	my $stderr;
	my $stdout;

	$outdir=$opts{d} if (defined $opts{d});
	if (defined $opts{f}) {
		$stdout=1 if ($opts{f} eq "-");
		if (!defined $opts{d} || substr($opts{f},0,1) eq "/") {
			$outdir="";
		}
		$out_path=$outdir.$opts{f};
	} else {
		$out_path="$outdir/$outfile";
	}
	if (defined $opts{e}) {
		$stderr=1;
		if ($opts{e} eq "-") { #TODO THIS CODE DOES NOT WORK SO DON'T USE IT
			$err_path=">-";
			close STDERR;
			open(STDERR,$err_path) or die "Can't open \"$err_path\" : $! ", __FILE__, ":", __LINE__,"\n";
		} else {
			if (defined $opts{d}) {
				$err_path=$opts{d}."/";
			}
			$err_path.=$opts{e};
			close STDERR;
			open(STDERR,">",$err_path) or die "Can't open \"$err_path\" : $! ", __FILE__, ":", __LINE__,"\n";
		}
	}

	if (!$stdout) {
		close STDOUT;
		open(STDOUT,">",$out_path) or die "Can't open \"$out_path\" : $!\n";
	}

	select STDERR; $| = 1; # make unbuffered
	select STDOUT; $| = 1; # make unbuffered
}
# vim: ts=4  sw=4 autoindent
