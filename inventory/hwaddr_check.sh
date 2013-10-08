TODO USE TEMP FILES

for I in `ls /var/www/Inventory/uschi*/ifcfg* | grep -v bond` ; do grep -l HWADDR $I; done  > list.txt

ls /var/www/Inventory/uschi*/ifcfg* | grep -v bond | grep -v lo> lst_all.txt

diff list.txt lst_all.txt | cut -f 5 -d / | sort -u | grep -v ^[0-9]
# vim: ts=4  sw=4 autoindent
