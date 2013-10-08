#!/usr/local/bin/perl 
#
#
#  rungold : run the goldbook script and create weekly generations.
#
#

umask 033;
undef $DATAFILE;
for($index=7;$index>=2;$index--)
{
  $index2=$index-1;
  system("mv /usr/adm/goldbook/goldbook.".$index2.".Z /usr/adm/goldbook/goldbook.$index.Z");
}
system("mv /usr/adm/goldbook/goldbook /usr/adm/goldbook/goldbook.1");
system("compress /usr/adm/goldbook/goldbook.1");
`/usr/local/bin/goldbook > /usr/adm/goldbook/goldbook 2>&1`;
