drop database IF EXISTS lxinv;
create database lxinv;
drop user 'lxinv'@'localhost';
GRANT ALL ON lxinv.* TO 'lxinv'@'localhost' IDENTIFIED BY 'stuff4lxinv';
drop user 'rolxinv'@'%';
GRANT SELECT ON lxinv.* TO 'rolxinv'@'%' IDENTIFIED BY 'ctc123';
FLUSH PRIVILEGES;

use lxinv;

create table if not exists server (
	hostname char(255) NOT NULL UNIQUE PRIMARY KEY,
	serial char(255) NOT NULL KEY,
	owner char(255) KEY,
	start_date TIMESTAMP
);
create table if not exists server_history (
	id INTEGER UNSIGNED NOT NULL UNIQUE AUTO_INCREMENT KEY,
	hostname char(255) NOT NULL KEY,
	serial char(255) NOT NULL KEY,
	owner char(255) KEY,
	start_date TIMESTAMP,
	end_date TIMESTAMP
);
create table if not exists server_groups (
	hostname char(255) NOT NULL PRIMARY KEY,
	groupname char(255) NOT NULL KEY,
	primary_group char(1) DEFAULT "N",
	start_date TIMESTAMP
);
create table if not exists groups_history (
	id INTEGER UNSIGNED NOT NULL UNIQUE AUTO_INCREMENT KEY,
	hostname char(255) NOT NULL KEY,
	groupname char(255) NOT NULL KEY,
	start_date TIMESTAMP,
	primary_group char(1) DEFAULT "N",
	end_date TIMESTAMP
);
