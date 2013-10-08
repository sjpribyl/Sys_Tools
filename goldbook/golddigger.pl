#!/usr/bin/perl
#
# Name: golddigger.pl
#
# Description: Process the goldbook files to create a excel readable file.
#
# # Author: Steve Pribyl
# Date: July 25,1997
#
# Modifications:
#
# SJP 05/19/99 - Added logic for Server/HW/OS list
#	       - Added logic for Server/IP list
#
# SJP 02/05/99 - Created logic for new backup software section.
#
# SJP 08/31/98 - Modified patch logic for new patch section format.
#
# MJB 08/14/98 - added patch logic          
#
# SJP 6/22/98 - Added logic for NCR and EMC 4G drives only
#	      - Added logic for HP Fiber Channel
#
# SJP 5/21/98 - Added new Database logic.
#
# SJP 5/20/98 - Corrected a bunch of little bugs.
#
# SJP 5/14/98 - Corrected disk calc logic.  If disk was on 0/xx on HP server
#		It would not get counted.
#
# SJP 4/6/98 - Added logic to create sybase.txt and oracle.txt files
#              From fstab file db is filesystem name.
#
# SJP 3/17/98 - Added logic to create patch.txt file for all patches
#
# SJP 3/12/98 - Added login For EMC Chassis reporting.
# 
# SJP 2/26/98 - Added totals logic.
#
# SJP 12/02/97 - Added logic to check for stale PE on HP disks and send email.
#
# SJP 09/11/97 - added system info logic for NCR servers
#
#
# Wishlist:
#   Add logic to tell what the back tool is.
#
#  Special thanks to Mike Kennedy for the name of the script.
#

$|=1;

$DEBUG=0;
 
$GOLDDIR="/usr/adm/goldbook";

$ALLDIST=$GOLDDIR."/all.dist";
 
$HPDIST=">".$GOLDDIR."/hp.dist";
$HP0904DIST=">".$GOLDDIR."/hp09.04.dist";
$HP1001DIST=">".$GOLDDIR."/hp10.01.dist";
$HP1010DIST=">".$GOLDDIR."/hp10.10.dist";
$HP1020DIST=">".$GOLDDIR."/hp10.20.dist";
$HP1100DIST=">".$GOLDDIR."/hp11.00.dist";
$NCRDIST=">".$GOLDDIR."/ncr.dist";
$OUTFILE=">".$GOLDDIR."/excel.txt";
$OTHERFILE=">".$GOLDDIR."/other.txt"; # used for one shot information.
$BACKUPFILE=">".$GOLDDIR."/backup.txt"; 
$EMCFILE=">".$GOLDDIR."/emc.txt"; 
$EMCDEVFILE=">".$GOLDDIR."/emcDev.txt"; 
$DISKFILE=">".$GOLDDIR."/disks.txt"; 
$PROBFILE=">".$GOLDDIR."/prob.txt";
$PRODUCTFILE=">".$GOLDDIR."/product.txt";
$PATCHFILE=">".$GOLDDIR."/patch.txt";
$ORACLEFILE=">".$GOLDDIR."/oracle.txt";
$SYBASEFILE=">".$GOLDDIR."/sybase.txt";
$CONTACTSFILE=">".$GOLDDIR."/contacts.txt";
$SERVERFILE=">".$GOLDDIR."/server.txt";
$NETWORKFILE=">".$GOLDDIR."/network.txt";

#
# Error messageing routine
#
sub WriteError
{
  print STDERR $errorMessage;
}

#
#
#
sub DiskSize
{
  $foundit=0;
  if ($des=~/EMC/ ) 
  { 
#     if ($os eq "HP-UX") 
#     { 
       if (($des=~/SYMMETRIX/) && ($os eq "HP-UX")) { $diskSize=4;}
       if (($des=~/SYMMETRIX/) && ($os eq "NCR")) { $diskSize=2;} # Can't count alternat links so divied 4 by 2
       if ($des=~/CENTRIPLEX/) { $diskSize=3.5;}
#     }
     $emcDisk=$emcDisk+$diskSize; 
     $foundit=1;
  }
  if ($os eq "NCR")
  {
    if (($des=~/SEAGATE/) || ($des=~/DEC/))
    {
       $spindlDisk=$spindlDisk+$diskSize; 
       $foundit=1;
    } 
    if (($des=~/SYMBIOS/) || ($des=~/NCR/))
    {
       $raidDisk=$raidDisk+$diskSize; 
       $foundit=1;
    } 
  }
  if ( $os eq "HP-UX" )
  {
    if( $des=~/C2300WDR5/ ) 
    { 
      $diskSize=8;
      $raidDisk=$raidDisk+$diskSize; 
      $foundit=1;
    }
    if ($des=~/C2300WDR1/) 
    { 
      $diskSize=2;
      $raidDisk=$raidDisk+$diskSize; 
      $foundit=1;
    }
    if ($des=~/3200 B02/) 
    { 
      $diskSize=20;
      $raidDisk=$raidDisk+$diskSize; 
      $foundit=1;
    }
    if( $des=~/DAS9300/ ) 
    { 
      $diskSize=42;
      $raidDisk=$raidDisk+$diskSize; 
      $foundit=1;
    }
    if (($des=~/C2490/) || ($des=~/FIREBALL-ST2/) ) 
    { 
       $diskSize=2;
       $spindlDisk=$spindlDisk+$diskSize; 
       $foundit=1; 
    }
    if ($des=~/ST34572/)
    {
       $diskSize=4;
       $spindlDisk=$spindlDisk+$diskSize; 
       $foundit=1;
    }
    if (($des=~/ST15150/) || ($des=~/ST34573/)) 
    {
       $diskSize=4;
       $spindlDisk=$spindlDisk+$diskSize; 
       $foundit=1;
    }
    if ($des=~/ST32171W/ ) 
    {  
       $diskSize=2;
       $spindlDisk=$spindlDisk+$diskSize; 
       $foundit=1;
    }
    if ($des=~/ST32430W/ ) 
    {  
       $diskSize=2;
       $spindlDisk=$spindlDisk+$diskSize; 
       $foundit=1;
    }
    if (($des=~/ST32550W/) || ($des=~/VP3215SW/)) 
    { 
       $diskSize=2;
       $spindlDisk=$spindlDisk+$diskSize; 
       $foundit=1; 
    }
    if ($des=~/ST3437/ )
    { 
       $diskSize=4;
       $spindlDisk=$spindlDisk+$diskSize; 
       $foundit=1;
    }
    if ($des=~/ST39173/ )
    { 
       $diskSize=8.5;
       $spindlDisk=$spindlDisk+$diskSize; 
       $foundit=1;
    }
    if (($des=~/C3324A/) || ($des=~/C2247M1/) || ($des=~/DSP3107LS/) || ($des=~/ST31230W/))
    { 
       $diskSize=1;
       $spindlDisk=$spindlDisk+$diskSize; 
       $foundit=1;
    }
  }
  if ( ($foundit == 0) || ($diskSize==0)) 
  {
    $errorMessage="I don't know what $des is worth on $SERVERNAME.\n";
    WriteError;
  }
  else
  {
     $totalDisk=$totalDisk+$diskSize; 
  }
}

#
# Does not count disks not used in LVM
#
sub CalcDisk
{
  %counted="";
  if ($os eq "HP-UX") 
  { 
    foreach $key (sort keys(%hwPath))
    {
      next if ($key eq "");
      #if alternate skip
      if ( !($alternatePath{$key}))
      {
#????   Added inq logic here
 #       ($vg,$dev,$serial,$size,$des)=split(",",$diskList{$key});
 #       $size=((($size)/1024)/1024)+0.5;
 #       ($size,$junk)=split(/\./,$size);
 #       print "diskList{key}=$diskList{$key} key=$key size=$size\n";

        $des=$disks{$key}; # get the description of the disk
        $diskSize=0;
        DiskSize;
        next if ($foundit == 0);
      }
      #if mirrored
      if ((($primary{$hwPath{$key}}) || ($mirror{$hwPath{$key}}))  && !($counted{$key}))
      {
        $mirrored=$mirrored+$diskSize;
        if ($primary{$hwPath{$key}})
        {
          $counted{$devPath{$primary{$hwPath{$key}}}}=$devPath{$primary{$hwPath{$key}}};
        }
        else
        {
          $counted{$devPath{$mirror{$hwPath{$key}}}}=$devPath{$mirror{$hwPath{$key}}};
        }
      }
      $counted{$key}.=$key; # mark this disk as counted already
    }
  }
  if ( $os eq "NCR" )
  {
    %sizes="";
    foreach $key (sort keys(%disks))
    {
      $stuff=$disks{$key}; # get the description of the disk
      ($des,$size)=split(",",$stuff);
      ($prefix,$stuff)=split("d",$key);
      if( !($diskSize=$sizes{$prefix})) 
      {
        $stuff=(((($size)/2)/1024)/1024);
        $stuff=$stuff+0.5;
        ($diskSize,$junk)=split(/\./,$stuff);
        $sizes{$prefix}=$diskSize;
      }
      DiskSize;
    }
  }
}
 
#
# Get the system information
#
sub SystemInfo
{
  if ( $sysline==1 )
  {
    ($os,$serverName,$ver,$rev,$model,$mid,$ul,$junk,$serialNumber)=split(" ",$line,9);
    if ($os ne "HP-UX")
    {
       $os="NCR";
       $ver=$rev;
       $rev="";
       $mid="";
       $serialNumber=$ul;
    }
    $sysline=0;
    if ($os eq "NCR") { print NCRDIST $SERVERNAME."\n";} 
    if ($os eq "HP-UX")
    {
      print HPDIST $SERVERNAME."\n";
      ($junk,$stuff,$lvl)=split(/\./,$ver,3);
      if ( $lvl eq "04" ) { print HP0904DIST $SERVERNAME."\n"; }
      if ( $lvl eq "01" ) { print HP1001DIST $SERVERNAME."\n"; }
      if ( $lvl eq "10" ) { print HP1010DIST $SERVERNAME."\n"; }
      if ( $lvl eq "20" ) { print HP1020DIST $SERVERNAME."\n"; }
      if ( $lvl eq "00" ) { print HP1100DIST $SERVERNAME."\n"; }
    }
  } 
  else
  {
    $sysline=1;
  }
}

#
# Get the IO information
#
sub IoInfo
{
  if ( $ioline==1 )
  {
    if ( $os eq "HP-UX")
    {
      ($class,$instance,$path,$driver,$state,$type,$des)=split(" ",$line,7);
      #
      # Get third line of disk info name only
      #
      if ( $nextLine eq "disk1" )  # get the next line of the disk info
      {
        $diskList{$savePath}=",$class,$diskList{$savePath}";
        $nextLine="";
      }
      #
      # Get second line of disk info Serial # and size
      #
      if ( $nextLine eq "disk" )  # get the next line of the disk info
      {
        ($junk,$info,$serial,$size)=split(":",$line,4);
        $size=~s/\s*//;
        $serial=~s/\s*//;
  #      $diskList{$savePath}="$instance,$path,$diskList{$savePath}";
        $diskList{$savePath}="$serial,$size,$diskList{$savePath}";
        $nextLine="disk1";
      }
      #
      # Get fisrt line of disk info Path, and description
      #
      if ( $class eq "disk" ) 
      { 
        $disks{$path}=$des;  
        $nextLine="disk"; # more information from the next line.
        $savePath=$path;
        $diskList{$path}=$des;
      }
      if ( $class eq "processor" ) { $processor=$processor+1; }
      if ( $class eq "tape" )
      {
        if ($des=~/DLT/ ) { $dlt=$dlt+1; }
        if ($des=~/SD-3/ ) { $redwood=$redwood+1; }
      }
      if ($class eq "lan")
      {
        if (($driver eq "token2") || ($driver eq "token3") || ($driver eq "token1")) { $token=$token+1; next; }
        if (($driver eq "lan2") || ($driver eq "lan3") || ($driver eq "lan1") ) { $ether=$ether+1; next; }
        if ($driver =~/fddi/) { $fddi=$fddi+1; next; }
        if ($driver eq "fcT1_cntl") { $fchan=$fchan+1; next; }
        if (($driver=~/btlan/) || ($driver eq "ivg")) { $fether=$fether+1; next; }
        $errorMessage="I don't know what lan driver $driver is $SERVERNAME.\n";
        WriteError;
      }
      if ( $class eq "Physical" ) #Waiting for goldbook information
      {
        $memory=$path; 
        $memory=$memory/1024;
      }
      if (($line=~/9710/) && ($line=~/STK/))  { $robot="STK 9710"; }
      if (($line=~/9710/) && ($line=~/STK/))  { $robot="STK 9714"; }
    }
    if ( $os eq "NCR")
    {
      ($title,$des)=split(":",$line);
      if ($des eq "")
      {
        ($class,$path)=split("-",$title);
      }
      if (($title=~/LUNs/) && ($ver eq "020300")) # on 2.03 remember lun name
      {
        $path=$des;
      }
      if ($des=~/CPUsubmodule/ ) { $processor=$processor+1; }
      if ($title=~/Component Object Type/) 
      {
        $type=$des;
      }
      if ($title=~/SCSI/) 
      {
        if ($des=~/DLT/ && $des=~/Quantum/) { $dlt=$dlt+1; next;}
        if ($des=~/DLT/ && $des=~/ADIC/) { $robot="ADIC"; next;}
        if (($title=~/Model/) && ($type=~/Disk/)) { $disks{$path}.=$des; }
      } 
      if ($title=~/Disk Capacity/)
      {
        $junk=$disks{$path};
        $disks{$path}="$junk,$des";
      }
      if ($title=~/Active System Memory/) 
      { 
        $des=$des/1024;
        $des=($des+512.5)/1024;
        ($memory,$junk)=split(/\./,$des);
      }
      if ($title=~/Adapter ID/) 
      {
        if ($des=~/0069/) { $fddi=$fddi+1; }
        if ($des=~/61c9/) { $ether=$ether+1; }
        if ($des=~/0a85/) { $token=$token+1; }
      }
    }
    if ($line=~/END\: Hardware/ ) 
    {
      $ioline=0;
    }
  }
  else
  {
    $ioline=1;
    %disks="";  # list of hwpaths and descriptions
  }
}

#
# Process the LVM section
#
sub LVMInfo
{
  if ( $lvmline==1 )
  {
    if ($os eq "HP-UX")
    {
      if ($line=~/VG Name/) { ($junk,$junk,$vgName)=split(" ",$line,3);}
      if ($line=~/LV Name/) { ($junk,$junk,$lvName,$junk)=split(" ",$line,4); }
      if (($line=~/LV Status/) && ($line=~/stale/))
      {
  	$staleFlag=1;
        print PROBFILE "$SERVERNAME:$lvName - Stale PE in Logical Volume\n";
      }
      if (($line=~/Mirror/) || ($mirrorflg==1))
      {
        if($mirrorflg==0)
        {
          $mirrorflg=1;
        }
        else
        {
          ($priDisk,$junk,$mirrorDisk,$junk)=split(" ",$line,4);
          if (($priDisk=~/\/dev\/dsk/) && ($mirrorDisk=~/\/dev\/dsk/))
          {
            $primary{$priDisk}=$mirrorDisk;
            $mirror{$mirrorDisk}=$priDisk;
          }
          if (($line=~/LV Name/) || ($line=~/Physical Name/)) { $mirrorflg=0; }
        }
      }
      if ($line=~/PV Name/ )
      { 
        ($front,$back)=split("-",$line);
        ($junk,$junk,$devDisk)=split(" ",$front);
        ($hwDisk,$alternate)=split(" ",$back);
        if ($diskList{$hwDisk}) { $diskList{$hwDisk}="$vgName$diskList{$hwDisk}"; }
        if($alternate eq "Alternate")
        {
          $primaryPath{$prevDisk}.=$hwDisk;  
          $alternatePath{$hwDisk}.=$prevDisk;
        }
        $prevDisk=$hwDisk;
        $hwPath{$hwDisk}.=$devDisk;
        $devPath{$devDisk}.=$hwDisk;
      }
    }
    if ($os ne "NCR")
    {
    }
    if ($line=~/END\: LVM/ )  { $lvmline=0; }
  }
  else
  { 
    $lvmline=1;
    %primary=""; # list of mirrors index by primary /dev/dsk/*
    %mirror=""; # list of prmary indexed by mirror /dev/dsk/*
    %primaryDisk=""; # list of HW paths used in volume group as index
    %alternatePath=""; # list of alternate links used in volume group as index
    %hwPath=""; # list of /dev/dsk/* names index by hw paths 
    %devPath=""; # list of hw path names index by /dev/dsk/name
  }
}

#
# Network information
#
sub NetInfo
{
  if ($netline==0) { $netline=1; }
  if ($line=~/END\: Network/) { $netline=0; return; }
  ($lan,$type,$junk,$path,$ipadd,$dest,$mac)=split(" ",$line,7);
  if (($lan=~/lan/) || ($lan=~/en/))
  {
    if ($mac eq "" )
    {
      $mac=$ipadd;
      $ipadd="";
    }
    $network{$netcount}.="$ipadd,$lan,$type,$mac"; 
    if ( $ipadd!="" ) {
      print NETWORKFILE "$SERVERNAME,$ipadd;\n";
    }
    $netcount=$netcount+1;
  }
  if ($lan=~/The/)
  {
    $network{$netcount}.="default,$ipadd,,,";
  }
}

#
# Other information
#
sub OtherInfo
{
  if ($otherline==0) { $otherline=1; return; }
  if ($line=~/END\: Other/) { $otherline=0; return;}
  if ($line=~/^#/) {return;}
  if ($line=~/^=/) {return;}
  if ($line=~/^-/) {return;}
  #if ( $otherline==1) { } #serial number
  if ( $otherline==2) { $supportPhone=$line; } #support phone number
  if ( $otherline==3) { $location=$line; } # Location of server
  $otherline=$otherline+1;
}

#
# Contacts information
#
sub ContactsInfo
{
  if ($contactsline==0) { $contactsline=1; }
  if ($line=~/END\: Contacts/) { $contactcount=$contactsline-2; $contactsline=0; return;}
  if ($line=~/^#/) {return;}
  if ($line=~/^=/) {return;}
  if ($line=~/^-/) {return;}
  if ($line=~/^$/) {return;}
  $contacts{$contactsline-1}.=$line;
  $contactsline=$contactsline+1;
}

#
# Checklist
#
sub ChecklistInfo
{
  if ($checklistline==0) { $checklistline=1; }
  if ($line=~/END\: Checklist/) { $checklistline=0; return;}
#  if ( ($line=~/sybase/) && ($dataBase!~/Sybase/)) { $dataBase.="Sybase"; }
#  if ( ($line=~/oracle/) && ($dataBase!~/Oracle/)) { $dataBase.="Oracle"; }
}
  
#
# Product information
#
sub ProductInfo
{
  if ($productline==0) { $productline=1; $productlist=""; }
  if ($line=~/END\: Product/) 
  { 
    print PRODUCTFILE "$SERVERNAME:$os:$ver$rev:$model:$productlist\n";
    $productline=0; return;
  }
  if ($line=~/^#/) {return;}
  if ($line=~/^=/) {return;}
  if ($line=~/^-/) {return;}
  if ($line=~/^$/) {return;}
  if (($line=~/PHCO/) || ($line=~/PHKL/) || ($line=~/PHNE/) || ($line=~/PHSS/))
  {
    ($product,$junk,$rest)=split(" ",$line,3);
    $productlist.="$product,"
  }
}

#####################
# Patch information
#####################
 
sub PatchInfo
{
  if ($patchline==0) { $patchline=1; $patchlist=""; }
  if ($line=~/END\: Patches/) 
  { 
    print PATCHFILE "$SERVERNAME:$os:$ver$rev:$model:$patchlist\n";
    $patchline=0; return;
  }
  if ($line=~/^#/) {return;}
  if ($line=~/^=/) {return;}
  if ($line=~/^-/) {return;}
  if ($line=~/^$/) {return;}

  ($patch,$junk)=split(" ",$line,2);
  ($patch,$junk)=split(/\./,$line,2);
  $patchlist.="$patch,"
}


#
# BackupInfo
#
sub BackupInfo
{
  if ($backupline==0) 
  { 
    $backupline=1; 
    $backuplist=$SERVERNAME;
  }
  if ($line=~/END\: Latest Backup/) 
  { 
    $backupline=0;
    if ($backupfound)
    {
      print BACKUPFILE "$backuplist;\n";
    }
    $backupfound=0;
    return;
  }
  if ($line=~/^#/) {return;}
  if ($line=~/^=/) {return;}
  if ($line=~/^-/) {return;}
  if ($line=~/^$/) {return;}
  $backupfound=1;
  ($path,$nam,$num)=split(":",$line);
  $nam=~s/^ +//;
  $nam=~s/\s+$//;
  $path=~s/^ +//;
  $path=~s/\s+$//;
  $num=~s/^ +//;
  $num=~s/\s+$//;
  $backuplist.=",$path,$nam,$num\n";
}

#
# EMC Info
#
sub EMCInfo
{
  if ($emcline==0) { 
    $emcline=1; 
    $emcdev=0;
    $devName="";
  }
  if ($line=~/END\: Latest EMC/) { 
    $emcline=0;
    $emcdev=0;
    return;
  }
  if ($line=~/^#/) {return;}
  if ($line=~/^$/) {return;}

  if (($line=~/START\: EMC Devices/) || ($emcdev==1)) { 
    $emcdev=1;
    if ($line=~/END\: EMC Devices/) { 
      $emcdev=0; # Done with this section
    } else {
      if ($line=~/Device Physical Name/) { 
        if($devName ne "") {
          print EMCDEVFILE "$symID,$devID,$SERVERNAME,$devName$devBack\n";
        }
        ($junk,$devName)=split(/:/,$line);
        $devID="";
        $symID="";
        $devBack=""; 
      } elsif ($line=~/Symmetrix ID/) { 
        ($junk,$symID)=split(/:/,$line);
      } elsif ($line=~/Device Serial ID/) { 
        ($junk,$devID)=split(/:/,$line);
      } elsif ($line=~/Disk \[Director\,/) { 
        ($junk,$stuff)=split(/:/,$line);
        $devBack.=",$stuff";
      } 
    }
  }
}

#
# Initalize Record variables
#
sub InitRecord
{
  # Control vars
  $sysline=0;
  $ioline=0;
  $lvmline=0;
  $netline=0;
  $otherline=0;
  $contactsline=0; 
  $backupline=0;
  $backupfound=0;
  $productline=0;
  $patchline=0;             
  $checklistline=0;
  $emcline=0;
  $mirrorflg=0;
  $staleFlag=0;

  # Value vars
  $runDate="";
  $location="";
  $os="";
  $ver="";
  $rev="";
  $model="";
  $serialNumber="";
  $mid="";
  $memory=0;
  $processor=0;
  %diskList="";
  $totalDisk=0;
  $emcDisk=0;
  $dataBase="";
  $upTime="";
  $spindlDisk=0;
  $raidDisk=0;
  $mirrored=0;
  $robot="";
  $dlt=0;
  $redwood=0;
  $token=0;
  $ether=0;
  $fddi=0;
  $fchan=0;
  $fether=0;
  %network="";
  $netcount=0;
  $supportPhone="";
  %contacts=""; 
  $contactcount=0;
  %emcList="";
  %emcDiskList="";
}

#
# Print Record variables
#
sub PrintRecord
{
  $output="$SERVERNAME,$os,$ver$rev,$model,$serialNumber,$mid";
  $output.=",$processor,$memory,$totalDisk,$spindlDisk,$emcDisk,$raidDisk,$mirrored";
  $output.=",$token,$ether,$fddi,$fether";
  $output.=",$dlt,$redwood,$robot,$fchan";
  $totalcount=2;
  if ($netcount > $totalcount) {$totalcount=$netcount;}
  if ($contactcount > $totalcount) {$totalcount=$contactcount;}
  for ($index=0;$index<=$totalcount;$index=$index+1)
  {
    ($con1,$con2,$con3,$con4)=split(",",$contacts{$index},4);
#    if ($index<$contactcount) 
#    {
       print CONTACTSFILE "$SERVERNAME,$con1,$con2,$con3,$con4\n"; 
#    }
    if ($index == 0) { $output.="\n$location,$con1,$con2,$con3,$con4,$dataBase,$upTime,,,,,,$network{$index},,"; next;}
    if ($index == 1) { $output.="\n$supportPhone,$con1,$con2,$con3,$con4,,,,,,,,$network{$index},,"; next;}
    if ($index == 2) { $output.="\n$runDate,$con1,$con2,$con3,$con4,,,,,,,,$network{$index},,"; next;}
    $output.="\n,$con1,$con2,$con3,$con4,,,,,,,,$network{$index},,";
  }
  $output=$output.";\n\n";
  print $PRINTEFILE $output; 
  if ($DEBUG==1) { print $output; }
}


#
# Calculate and report on EMC
#
sub CalcEmc
{
  $output="\n\nEMC Information\n\nemc,size,#drives,used,#used,gateway\n";
  print EMCFILE $output;
  if ($DEBUG==1) { print $output; }
  $output=",server,#drives,used,#avail,avail\n";
  print EMCFILE $output;
  if ($DEBUG==1) { print $output; }
  foreach $serial (sort keys(%gEmcDrives))
  {
    $emcNum=substr($serial,0,2);
    $vol=substr($serial,2,3);
    @servers=split(",",$gEmcDrives{$serial});
    $diskfile="\n$emcNum,$vol";
    $counted="no";
    foreach $item (@servers)
    {
      ($name,$path,$dev,$vg,$size)=split("-",$item);
      if ($diskfile!~/$name/)
      { $diskfile.="\n,$name,$dev,$vg"; }
      else
      { $diskfile.=",$dev,$vg"; }

      if (($counted eq "no") && ($vg ne ""))
      {
        $usedEmc{$emcNum}=$usedEmc{$emcNum}+$size;
        $sUsedEmc{$emcNum}=$sUsedEmc{$emcNum}+1;
        if ($emcUsed{$name})
        { $emcUsed{$name}.=",$serial"; }
        else
        { $emcUsed{$name}="$serial"; }
        $counted="yes";
      }

      if ($emcView{$name})
      { if ($emcView{$name}!~/$serial/) { $emcView{$name}.=",$serial"; } }
      else
      { $emcView{$name}=$serial;}

      if ($emcServer{$emcNum})
      {if ($emcServer{$emcNum}!~/$name/){$emcServer{$emcNum}.=",$name";}}
      else
      {$emcServer{$emcNum}=$name;}
    }
    print DISKFILE $diskfile;
  }

  foreach $emcNum (sort keys(%sizeEmc))
  {
    $output="$emcNum,$sizeEmc{$emcNum},$diskEmc{$emcNum},$usedEmc{$emcNum},$sUsedEmc{$emcNum},$gateEmc{$emcNum}\n";
    print EMCFILE $output;
    if ($DEBUG==1) { print $output; }

    @servers=split(",",$emcServer{$emcNum});
    foreach $server (@servers)
    {
      @disks=split(",",$emcUsed{$server});
      $usedCount=0;
      $usedSize=0;
      foreach $serial (@disks) 
      {
        ($item,$junk)=split(",",$gEmcDrives{$serial},2);
        ($name,$path,$dev,$vg,$size)=split("-",$item);
        $num=substr($serial,0,2);
        if (($size != 0) && ($emcNum == $num))
        {
          $usedSize=$usedSize+$size;
          $usedCount=$usedCount+1;
        }
      }

      @disks=split(",",$emcView{$server});
      $viewCount=0;
      $viewSize=0;
      foreach $serial (@disks) 
      {
        ($item,$junk)=split(",",$gEmcDrives{$serial},2);
        ($name,$path,$dev,$vg,$size)=split("-",$item);
        $num=substr($serial,0,2);
        if ( ($size !=0)  && ($emcNum == $num))
        {
          $viewSize=$viewSize+$size;
          $viewCount=$viewCount+1;
        }
      }
      $output=",$server,$usedCount,$usedSize,$viewCount,$viewSize\n";
      print EMCFILE $output;
      if ($DEBUG==1) { print $output; }
    }

    $output=";\n";
    if ($DEBUG==1) { print $output; }
  }
}

#
#
#  Main program 
# 

 
system("ls $GOLDDIR | grep -v .Z | grep -v lost+found | grep -v projects | grep -v contacts | grep -v goldbook | grep -v other | grep -v dist | grep -v txt | grep -v htm > $ALLDIST");

open ALLDIST or die "unable to open $ALLDIST.\n";
open OUTFILE or die "unable to open $OUTFILE.\n";
open HPDIST or die "unable to open $HPDIST.\n";
open HP0904DIST or die "unable to open $HP0904DIST.\n";
open HP1001DIST or die "unable to open $HP1001DIST.\n";
open HP1010DIST or die "unable to open $HP1010DIST.\n";
open HP1020DIST or die "unable to open $HP1020DIST.\n";
open HP1100DIST or die "unable to open $HP1100DIST.\n";
open NCRDIST or die "unable to open $NCRDIST.\n";
open OTHERFILE or die "unable to open $OTHERFILE.\n";
open BACKUPFILE or die "unable to open $BACKUPFILE.\n";
open EMCFILE or die "unable to open $EMCFILE.\n";
open EMCDEVFILE or die "unable to open $EMCDEVFILE.\n";
open DISKFILE or die "unable to open $DISKFILE.\n";
open PROBFILE or die "unable to open $PROBFILE.\n";
open PRODUCTFILE or die "unable to open $PRODUCTFILE.\n";
open PATCHFILE or die "unable to open $PATCHFILE.\n";
open ORACLEFILE or die "unable to open $ORACLEFILE.\n";
open SYBASEFILE or die "unable to open $SYBASEFILE.\n";
open CONTACTSFILE or die "unable to open $CONTACTSFILE.\n";
open SERVERFILE or die "unable to open $SERVERFILE.\n";
open NETWORKFILE or die "unable to open $NETWORKFILE.\n";

$output="Server Name,OS,Version,Model,Serial Number,Machine ID";
$output.=",# Processor,Memory,Total Disk,Spindle Disk,EMC Disk,Raid Disk,Mirrored Disk,Token,Ethernet,FDDI,Fast Ether,# DLT Drives,Redwood Drives,Tape Robot,Fiber\n";
$output.="Location,Application Name,Contact Name,Contact Phone,Contact Pager,DataBase,Uptime,,,,,,IP Address,Lan Interface,Lan Type,Mac Address,,\n";
$output.="Support Modem,,,,,,,,,,,,,,,,,\n";
$output.="Run Date,,,,,,,,,,,,,,,,,;\n";
print OUTFILE $output."\n"; 
print SYBASEFILE $output."\n"; 
print ORACLEFILE $output."\n"; 
if ($DEBUG==1) { print $output."\n"; }

print BACKUPFILE "Server,Path,Software,Version;\n";
print SERVERFILE "Server Name,Serial Number, Machine ID ,Model,OS,Version,Phone #,Run Date,Up Time;\n";
print NETWORKFILE "Server Name,IP address;\n";

#
# Initalize Global totals
#
%sizeEmc="";
%diskEmc="";
%usedEmc="";
%sUsedEmc="";
%gateEmc="";
%gEmcDrives="";
%emcView="";
%emcUsed="";
%emcServer="";

$gProcessor=0;
$gMemory=0;
$gTotalDisk=0;
$gSpindlDisk=0;
$gEmcDisk=0;
$gRaidDisk=0;
$gMirrored=0;
$gToken=0;
$gEther=0;
$gFddi=0;
$gFether=0;
$gDlt=0;
$gRedwood=0;
$printTotal=0;

$sTotalDisk=0;
$sSpindlDisk=0;
$sEmcDisk=0;
$sRaidDisk=0;
$sMirrored=0;

$oTotalDisk=0;
$oSpindlDisk=0;
$oEmcDisk=0;
$oRaidDisk=0;
$oMirrored=0;

# Start processing the all.dist file.
#
while (<ALLDIST>)
{
  InitRecord;

  $SERVERNAME="$_";
  chop($SERVERNAME); 

  $GOLDBOOK="<".$GOLDDIR."/".$SERVERNAME;
  open GOLDBOOK or next; # Open the goldbook file for this server

  $calc=0;
  while (<GOLDBOOK>) # Process the goldbook file.
  {
    next if /^\*/;
    next if /^$/;
    $line=$_;
    chop($line);
    if (($line=~/This report was run/)) 
    {
      ($junk,$junk,$junk,$junk,$junk,$junk,$mon,$day,$junk,$junk,$yr)=split(" ",$line,11);
      $runDate="$mon/$day/$yr";
    }
    if (($line=~/System Information/) || $sysline==1 ) 
    {
      next if /^-/;
      next if /^=/;
      SystemInfo; next; 
    }
    if ($line=~/Uptime\:/)  
    {
      ($junk,$upTime)=split(":",$line);
      next;
    }
    if ($line=~/Database\:/)  
    {
      ($junk,$dataBase)=split(":",$line);
      next;
    }
    if (($line=~/START\: Hardware/) || ($ioline==1)) { IoInfo; next; }
    if (($line=~/START\: Logical/) || ($lvmline==1)) { LVMInfo; $calc=1; next; }
    if (($line=~/START\: Network/) || ($netline==1)) { NetInfo; next; }
    if (($line=~/START\: Other/) || ($otherline>0)) { OtherInfo; next; }
#    if (($line=~/START\: Products/) || ($productline>0)) { ProductInfo; next;}
    if (($line=~/START\: Patches/) || ($patchline>0)) { PatchInfo; next;}     
    if (($line=~/START\: Contacts/) || ($contactsline>0)) { ContactsInfo; next;}
    if (($line=~/START\: Checklist/) || ($checklistline>0)) { ChecklistInfo; next;}
    if (($line=~/START\: Latest Backup/) || ($backupline==1)) { &BackupInfo; next;}
    if (($line=~/START\: Latest EMC/) || ($emcline==1)) { &EMCInfo; next;}
  }
  close GOLDBOOK;

  if (($calc==1) || ($os eq "NCR") ) { CalcDisk; }

  if ($os eq "HP-UX")  
  {
    foreach $path (keys(%diskList))
    {
      ($vg,$dev,$serial,$size,$des)=split(",",$diskList{$path});
      $size=((($size+512)/1024)/1024);
      ($size,$junk)=split(/\./,$size);
      if ( $des=~/SYMMETRIX/)
      {
        $serial=substr($serial,0,5);
        $emcNum=substr($serial,0,2);
        if ( $gEmcDrives{$serial} )
        {
          $gEmcDrives{$serial}.=",$SERVERNAME-$path-$dev-$vg-$size";
        }
        else
        {
          $gEmcDrives{$serial}="$SERVERNAME-$path-$dev-$vg-$size";
          $sizeEmc{$emcNum}=$sizeEmc{$emcNum}+$size;
          if ( $size > 0 )
          { $diskEmc{$emcNum}=$diskEmc{$emcNum}+1; }
          else
          { $gateEmc{$emcNum}=$gateEmc{$emcNum}+1; }
        }
      }
    }
  }

  #    
  # Calculate totals for all fields
  #
  $gProcessor=$gProcessor+$processor;
  $gMemory=$gMemory+$memory;
  $gTotalDisk=$gTotalDisk+$totalDisk;
  $gSpindlDisk=$gSpindlDisk+$spindlDisk;
  $gEmcDisk=$gEmcDisk+$emcDisk; 
  $gRaidDisk=$gRaidDisk+$raidDisk;
  $gMirrored=$gMirrored+$mirrored;
  $gToken=$gToken+$token;
  $gEther=$gEther+$ether;
  $gFddi=$gFddi+$fddi;
  $gFchan=$gFchan+$fchan;
  $gFether=$gFether+$fether;
  $gDlt=$gDlt+$dlt;
  $gRedwood=$gRedwood+$redwood;
 
  if ( $dataBase=~/Sybase/ ) 
  { 
    $sTotalDisk=$sTotalDisk+$totalDisk;
    $sSpindlDisk=$sSpindlDisk+$spindlDisk;
    $sEmcDisk=$sEmcDisk+$emcDisk;
    $sRaidDisk=$sRaidDisk+$raidDisk;
    $sMirrored=$sMirrored+$mirrored;
  }
  if ( $dataBase=~/Oracle/ ) 
  { 
    $oTotalDisk=$oTotalDisk+$totalDisk;
    $oSpindlDisk=$oSpindlDisk+$spindlDisk;
    $oEmcDisk=$oEmcDisk+$emcDisk;
    $oRaidDisk=$oRaidDisk+$raidDisk;
    $oMirrored=$oMirrored+$mirrored;
  }
  #
  #
  #  Print the data
  #
  $PRINTEFILE=OUTFILE;
  if ($serverName ne $SERVERNAME)
  {
    $errorMessage="$SERVERNAME-Name of goldbook file does not match server name.\n";
    WriteError;
  }
  PrintRecord;
  
  if ( $dataBase=~/Sybase/ ) 
  { 
    $PRINTEFILE=SYBASEFILE;
    PrintRecord;
  }
  if ( $dataBase=~/Oracle/ ) 
  { 
    $PRINTEFILE=ORACLEFILE;
    PrintRecord;
  }

  print SERVERFILE "$SERVERNAME,$serialNumber,$mid,$model,$os,$ver$rev,$supportPhone,$runDate,$upTime;\n";
}

#
# Print the totals record
#
InitRecord;
$SERVERNAME="Totals";
$processor=$gProcessor;
$memory=$gMemory;
$totalDisk=$gTotalDisk;
$spindlDisk=$gSpindlDisk;
$emcDisk=$gEmcDisk;
$raidDisk=$gRaidDisk;
$mirrored=$gMirrored;
$token=$gToken;
$ether=$gEther;
$fchan=$gFchan;
$fether=$gFether;
$dlt=$gDlt;
$redwood=$gRedwood;

$PRINTEFILE=OUTFILE;
PrintRecord;

InitRecord;
$SERVERNAME="Totals";
$totalDisk=$sTotalDisk;
$spindlDisk=$sSpindlDisk;
$emcDisk=$sEmcDisk;
$raidDisk=$sRaidDisk;
$mirrored=$sMirrored;
$PRINTEFILE=SYBASEFILE;
PrintRecord;

InitRecord;
$SERVERNAME="Totals";
$totalDisk=$oTotalDisk;
$spindlDisk=$oSpindlDisk;
$emcDisk=$oEmcDisk;
$raidDisk=$oRaidDisk;
$mirrored=$oMirrored;
$PRINTEFILE=ORACLEFILE;
PrintRecord;

CalcEmc;

close OUTFILE;
close ALLDIST;
close HPDIST;
close HP0904DIST;
close HP1001DIST;
close HP1010DIST;
close HP1020DIST;
close HP1100DIST;
close NCRDIST;
close OTHERFILE;
close BACKUPFILE;
close EMCFILE;
close EMCDEVFILE;
close DISKFILE;
close PROBFILE;
close PRODUCTFILE;        
close PATCHFILE;
close ORACLEFILE;
close SYBASEFILE;
close SYBASEFILE;
close CONTACTSFILE;
close SERVERFILE;
close NETWORKFILE;

if ($DEBUG==0) 
{
`ux2dos /usr/adm/goldbook/excel.txt | uuencode unix.xls | elm -s "Unix World" golddigger`;
`ux2dos /usr/adm/goldbook/emc.txt | uuencode emc.xls | elm -s "EMC World" golddigger`;
`ux2dos /usr/adm/goldbook/backup.txt | uuencode backup.xls | elm -s "Backup World" golddigger`;
  if ( -s "/usr/adm/goldbook/prob.txt" )
  {
`ux2dos /usr/adm/goldbook/prob.txt | uuencode prob.txt | elm -s "Unix Problems" unixprob`; 
  }
  if ( -s "/tmp/golddigger.log" )
  {
`ux2dos /tmp/golddigger.log | uuencode golddigger.txt | elm -s "Golddigger Problems" diggerprob`; 
  }
}
