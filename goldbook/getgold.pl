#!/usr/local/bin/perl 
#
#
# Read in input and look for the subject line if it is goldbook create the history files and pipe the
# current message to the current file.
#

umask 022;
undef $DATAFILE;
undef $bodyfound;
undef $gotgold;
$LOGFILE=">/tmp/getgold.log";
open(LOGFILE) || die "can't open $LOGFILE\n";
print LOGFILE "Starting rungold.pl\n";
while(<>)
{
  $line=$_;
  if( $line =~ /^From:/ && $DATAFILE eq "") # only get the first from if you don't know what file name  
  {
    chop($line);
    print LOGFILE "Recived mail from ".$line."\n";
    ($junk,$server)=split(/@/,$line,2);
    print LOGFILE "server=$server junk=$junk\n";
    ($server,$junk)=split(/\./,$server,2);
    print LOGFILE "server=$server junk=$junk\n";
    ($server,$junk)=split(/_/,$server,2);
    print LOGFILE "server=$server junk=$junk\n";
    ($server,$junk)=split(/-/,$server,2);
    print LOGFILE "server=$server junk=$junk\n";
    if($junk =~/con/ ) { $server="$server-$junk"; }
    if ($server eq "") { $server=`hostname`; chomp($server); }
    $DATAFILE=">/usr/adm/goldbook/$server";
    print LOGFILE "Will open file $DATAFILE for output\n";
  }
  elsif( $line =~ /^Subject:/ && $gotgold == 0 ) # if the subject is goldbook age and open file
  {
    chop($line);
    ($junk,$subject)=split(/ /,$line,2);
    if ( $subject eq "goldbook" )
    {
      print LOGFILE "Got goldbook as subject\n";
      $gotgold=1;
      for($index=9;$index>=2;$index--)
      {
        $index2=$index-1;
        system("mv /usr/adm/goldbook/$server.".$index2.".Z /usr/adm/goldbook/$server.$index.Z");
      }
      system("mv /usr/adm/goldbook/$server /usr/adm/goldbook/$server.1");
      system("compress -f /usr/adm/goldbook/$server.1");
      open(DATAFILE) || die "can't open data file\n";
    } else {
      print LOGFILE "Did not get goldbook as subject\n";
    }
  }
  elsif (($line =~ /^$/) && ($gotgold == 1) && ($bodyfound !=1 ))
  {
    print LOGFILE "Found the body of the message\n";
    $bodyfound=1;
  } 
  elsif ($bodyfound==1)
  {
    print DATAFILE $line;
  }
}

if($DATAFILE ne "") { close DATAFILE; } # close the file when finish if it was opened
print LOGFILE "Exiting getgold.pl\n";
