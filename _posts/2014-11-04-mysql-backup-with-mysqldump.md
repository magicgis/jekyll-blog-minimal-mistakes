---
layout: post
title: "mysql backup with mysqldump"
categories: 技术
tags: MySQL
---


---
##MySQLdump基本用法

备份指定数据库

	mysqldump -uroot -p[passwd] db1 > dumpfilename.sql

备份多个数据库

	mysqldump -uroot -p[passwd] --databases db1 db2 > dumpfilename.sql

备份所有数据库

	mysqldump -uroot -p[passwd] --all-databases > dumpfile.sql

备份指定表

	mysqldump -uroot -p[passwd] db1 table1 > db1_table1.sql

只备份表结构

	mysqldump -uroot -p[passwd] -d db1 > dumpfile.sql

如果不想要drop table, 附上参数--compact

	mysqldump -uroot -p[passwd] --compact db1 > dumpfile.sql

还原

	mysql -uroot -ppassword db1 < dumpfile.sql

如果存储引擎是MYISAM,还可以使用mysqlhotcopy

	mysqlhotcopy -u root -p passwd db1 备份目录

#####注意,-u后面有个空格, mysqlhotcopy相当于把数据库文件拷贝到新的目录. 恢复的方法就是把该备份目录拷贝到mysql数据目录下面.      

#	
##MySQLdump增量备份、完全备份与恢复
 

在数据库表丢失或损坏的情况下，备份你的数据库是很重要的。如果发生系统崩溃，你肯定想能够将你的表尽可能丢失最少的数据恢复到崩溃发生时的状态。场景：每周日执行一次完全备份，每天下午1点执行MySQLdump增量备份
 
MySQLdump增量备份配置
 
执行增量备份的前提条件是MySQL打开log-bin日志开关，例如在my.ini或my.cnf中加入
 
log-bin=/opt/Data/MySQL-bin
 
“log-bin=”后的字符串为日志记载目录，一般建议放在不同于MySQL数据目录的磁盘上。
 
MySQLdump增量备份
 
假定星期日下午1点执行完全备份，适用于MyISAM存储引擎。
 
	MySQLdump –lock-all-tables –flush-logs –master-data=2 -u root -p test > backup_sunday_1_PM.sql
 
对于InnoDB 将–lock-all-tables替换为–single-transaction
flush-logs 为结束当前日志，生成新日志文件
master-data=2 选项将会在输出SQL中记录下完全备份后新日志文件的名称，
 
用于日后恢复时参考，例如输出的备份SQL文件中含有：
 
	CHANGE MASTER TO MASTER_LOG_FILE=’MySQL-bin.000002′, MASTER_LOG_POS=106;
 
MySQLdump增量备份其他说明：
 
如果MySQLdump加上–delete-master-logs 则清除以前的日志，以释放空间。但是如果服务器配置为镜像的复制主服务器，用MySQLdump –delete-master-logs删掉MySQL二进制日志很危险，因为从服务器可能还没有完全处理该二进制日志的内容。在这种情况下，使用 PURGE MASTER LOGS更为安全。
 
每日定时使用 MySQLadmin flush-logs来创建新日志，并结束前一日志写入过程。并把前一日志备份，例如上例中开始保存数据目录下的日志文件 MySQL-bin.000002 , …
 
◆恢复完全备份
	
	MySQL -u root -p < backup_sunday_1_PM.sql
 
◆恢复增量备份

	MySQLbinlog MySQL-bin.000002 … | MySQL -u root -p password

注意此次恢复过程亦会写入日志文件，如果数据量很大，建议先关闭日志功能
 
◆--compatible=name
它告诉 MySQLdump，导出的数据将和哪种数据库或哪个旧版本的 MySQL 服务器相兼容。值可以为 ansi、MySQL323、MySQL40、postgresql、oracle、mssql、db2、maxdb、no_key_options、no_tables_options、no_field_options 等，要使用几个值，用逗号将它们隔开。当然了，它并不保证能完全兼容，而是尽量兼容。
 
◆--complete-insert，-c
导出的数据采用包含字段名的完整 INSERT 方式，也就是把所有的值都写在一行。这么做能提高插入效率，但是可能会受到 max_allowed_packet 参数的影响而导致插入失败。因此，需要谨慎使用该参数，至少我不推荐。
 
◆--default-character-set=charset
指定导出数据时采用何种字符集，如果数据表不是采用默认的 latin1 字符集的话，那么导出时必须指定该选项，否则再次导入数据后将产生乱码问题。
 
◆--disable-keys
告诉 MySQLdump 在 INSERT 语句的开头和结尾增加 /*!40000 ALTER TABLE table DISABLE KEYS */; 和 /*!40000 ALTER TABLE table ENABLE KEYS */; 语句，这能大大提高插入语句的速度，因为它是在插入完所有数据后才重建索引的。该选项只适合 MyISAM 表。
 
◆--extended-insert = true|false
默认情况下，MySQLdump 开启 --complete-insert 模式，因此不想用它的的话，就使用本选项，设定它的值为 false 即可。
 
◆--hex-blob
使用十六进制格式导出二进制字符串字段。如果有二进制数据就必须使用本选项。影响到的字段类型有 BINARY、VARBINARY、BLOB。
 
◆--lock-all-tables，-x
在开始导出之前，提交请求锁定所有数据库中的所有表，以保证数据的一致性。这是一个全局读锁，并且自动关闭 --single-transaction 和 --lock-tables 选项。
 
◆--lock-tables
它和 --lock-all-tables 类似，不过是锁定当前导出的数据表，而不是一下子锁定全部库下的表。本选项只适用于 MyISAM 表，如果是 Innodb 表可以用 --single-transaction 选项。
 
◆--no-create-info，-t
只导出数据，而不添加 CREATE TABLE 语句。
 
◆--no-data，-d
不导出任何数据，只导出数据库表结构。
 
◆--opt
这只是一个快捷选项，等同于同时添加 --add-drop-tables --add-locking --create-option --disable-keys --extended-insert --lock-tables --quick --set-charset 选项。本选项能让 MySQLdump 很快的导出数据，并且导出的数据能很快导回。该选项默认开启，但可以用 --skip-opt 禁用。注意，如果运行 MySQLdump 没有指定 --quick 或 --opt 选项，则会将整个结果集放在内存中。如果导出大数据库的话可能会出现问题。
 
◆--quick，-q
该选项在导出大表时很有用，它强制 MySQLdump 从服务器查询取得记录直接输出而不是取得所有记录后将它们缓存到内存中。
 
◆--routines，-R
导出存储过程以及自定义函数。
 
◆--single-transaction
该选项在导出数据之前提交一个 BEGIN SQL语句，BEGIN 不会阻塞任何应用程序且能保证导出时数据库的一致性状态。它只适用于事务表，例如 InnoDB 和 BDB。本选项和 --lock-tables 选项是互斥的，因为 LOCK TABLES 会使任何挂起的事务隐含提交。要想导出大表的话，应结合使用 --quick 选项。
 
◆--triggers
同时导出触发器。该选项默认启用，用 --skip-triggers 禁用它。