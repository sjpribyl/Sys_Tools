#!/usr/bin/env perl
use        strict;
use        DBI;

my $dir  = '/root/db_backups';
my $soft = '/usr/bin';
my @skip = ('information_schema');
my $error=0;
my $dsn = 'DBI:mysql:database=mysql;mysql_read_default_file=/etc/my.cnf';

my $dbh = DBI->connect($dsn, undef, 'mydbms');
        if ( !defined $dbh ) {
                print "Failed to open MySQL database: $DBI::errstr\n";
                exit 1;
        }
my @databases = $dbh->func('_ListDBs');
$dbh->disconnect;

my ($db, $file);
foreach $db (@databases) {
    $file = "$dir/$db.`date +%-y%m%d`.sql";

    unless (grep(/^$db$/, @skip)) {
        print "Backing up database \"$db\"...\n";
                system("/bin/bash -c '$soft/mysqldump $db --password=mydbms | /bin/gzip >$file.gz ; [ \${PIPESTATUS[0]} -eq 0 -a \${PIPESTATUS[1]} -eq 0 ]'");
        if ($? == -1) {
            print "failed to execute: $!\n";
                        $error=1;
        } elsif ($? & 127) {
            printf "child died with signal %d, %s coredump\n",
                ($? & 127), ($? & 128) ? 'with' : 'without';
                        $error=1;
        } elsif ($? !=0 ) {
            printf "child exited with value %d\n", $? >> 8;
                        $error=1;
        } else {   
                        print "Database \"$db\" backed up\n";
                }
        }
}
foreach (glob("$dir/*.gz")) {
        my $age = -M ;
        if ($age > 7) {
                print "Cleaning up $_\n";
                my $result=unlink;
                if ($result < 0) { 
                        $error=1;
                        print "Unable to delete $_\n";
                }; 
        } 
}
exit $error;
