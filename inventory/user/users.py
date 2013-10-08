#!/usr/bin/python
# -*- coding: utf-8 -*-
import sqlite3 as lite
import sys 
import os

base_dir="/var/www/Inventory/.reports/users/"
db_file=base_dir+"data/db.data"
user_file=base_dir+"data/all.users"
group_file=base_dir+"data/all.groups"

if os.path.isfile(db_file): 
	os.remove(db_file)

con = lite.connect(db_file)

print
print "(files) -> from the local server files"
print "(chi) -> from Chicago AD domain"
print

with con:
	
	cur = con.cursor()
	cur.execute("CREATE TABLE Users (Id INTEGER, Name TEXT, Source TEXT);")
	cur.execute("CREATE TABLE Groups(Id INTEGER, Name TEXT, Source TEXT);")
	
	for subdir, dirs, files in os.walk(base_dir+"data"):
		for file in files:
			if "users" in file:
				f = open(base_dir+"data/"+file, 'r')
				for line in f:
					data = line.split()
					if (len(data) < 2):
						continue
					uid=data[len(data)-1]
					if (len(data) > 2):
						uname=" ".join(data[0:(len(data)-1)])
					else:
						uname=data[0]
					cur.execute("INSERT OR IGNORE INTO Users(Id,Name,Source) VALUES("+uid+",'"+uname+"','"+(file.split('.'))[1]+"')")
				f.close
			
			if "groups" in file:
				f = open(base_dir+"data/"+file, 'r')
				for line in f:
					data = line.split()
					if (len(data) < 2):
						continue
					gid=data[len(data)-1]
					if (len(data) > 2):
						gname=" ".join(data[0:(len(data)-1)])
					else:
						gname=data[0]	
					cur.execute("INSERT OR IGNORE INTO Groups(Id,Name,Source) VALUES("+gid+",'"+gname+"','"+(file.split('.'))[1]+"')")
				f.close
	
	print 
	print "Uid Collisions"
	print 
	cur.execute("select distinct id from users")
	rows = cur.fetchall()
	for row in rows:
		cur.execute("select * from users where Id='"+str(row[0])+"'")
		dups = cur.fetchall()
		if (len(dups) > 1): 
			outstr="\'"+str(row[0])+"\': "
			dup_set=set()
			for dup in dups:
				outstr+=dup[1]+"("+dup[2]+") "
				dup_set.add(dup[1])
			if (len(dup_set) > 1):
				print  outstr
	print 
	print 
	print "Uname Multipl ids"
	print 
	cur.execute("select distinct Name from users")
	rows = cur.fetchall()
	for row in rows:
		cur.execute("select * from users where name='"+row[0]+"'")
		dups = cur.fetchall()
		if (len(dups) > 1): 
			outstr="\'"+row[0]+"\': "
			dup_set=set()
			for dup in dups:
				outstr+= str(dup[0])+"("+dup[2]+") "
				dup_set.add(dup[0])
			if (len(dup_set) > 1):
				print  outstr
				
	print 
	print
	print "Gid Collisions"
	print
	cur.execute("select distinct id from groups")
	rows = cur.fetchall()
	for row in rows:
		cur.execute("select * from groups where Id='"+str(row[0])+"'")
		dups = cur.fetchall()
		if (len(dups) > 1):
			outstr="\'"+str(row[0])+"\': "
			dup_set=set()
			for dup in dups:
				outstr+=dup[1]+"("+dup[2]+") "
				dup_set.add(dup[1])
			if (len(dup_set) > 1):
				print  outstr
	print
	print
	print "Gname Multipl ids"
	print
	cur.execute("select distinct Name from groups")
	rows = cur.fetchall()
	for row in rows:
		cur.execute("select * from groups where name='"+row[0]+"'")
		dups = cur.fetchall()
		if (len(dups) > 1):
			outstr="\'"+row[0]+"\': "
			dup_set=set()
			for dup in dups:
				outstr+= str(dup[0])+"("+dup[2]+") "
				dup_set.add(dup[0])
			if (len(dup_set) > 1):
				print  outstr
	print

#vim: ai ts=4 sw=4: 


