#!/usr/bin/perl
use FileHandle;
$|=1;
use Fcntl ':flock'; # import LOCK_* constants
$LOCK_FILE="/export/home/spr4h/tmp/.dsgid.lock";
open $LOCK,">",$LOCK_FILE or die "ERROR: Could open lock $LOCK_FILE: $!\n";
$LOCK->autoflush(1);
flock($LOCK,LOCK_EX);
print $LOCK "PID $$\n";
print "File Locked\n";
while(1) {
print ".";
sleep 1
}

