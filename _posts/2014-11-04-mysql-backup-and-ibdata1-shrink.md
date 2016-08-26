---
layout: post
title: "mysql backup and ibdata1 shrink"
categories: 技术
tags: MySQL
---


---
mysql 数据库备份及ibdata1的瘦身

### 备份数据库：
	/usr/local/mysql/bin/mysqldump -uDBuser -pPassword --quick --force --routines --add-drop-database --all-databases --add-drop-table > /data/bkup/mysqldump.sql

### 停止数据库
	
	service mysqld stop

### 删除这些大文件
	
	rm /usr/local/mysql/var/ibdata1
	rm /usr/local/mysql/var/ib_logfile*
	rm /usr/local/mysql/var/mysql-bin.index
 
### 手动删除除Mysql之外所有数据库文件夹，然后启动数据库
	
	service mysqld start

### 还原数据

	/usr/local/mysql/bin/mysql -uroot -phigkoo < /data/bkup/mysqldump.sql

主要是使用Mysqldump时的一些参数，建议在使用前看一个说明再操作。另外备份前可以先用MySQLAdministrator看一下当前数据库里哪些表占用空间大，把一些不必要的给truncate table掉。这样省些空间和时间。
 
