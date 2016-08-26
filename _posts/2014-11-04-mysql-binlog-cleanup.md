---
layout: post
title: "mysql binlog 清理"
categories: 技术
tags: MySQL
---


---

一个繁忙的master db server上，MySQL binlog日志文件增长速度很快，如果不定时清除，硬盘空间很快就会被充满。

设置自动清理MySQL binlog日志，配置my.cnf：

	expire_logs_days = 10

在运行时修改：


	show binary logs;  
	show variables like '%log%';  
	set global expire_logs_days = 10;


清除之前可以采用相应的备份策略。

手动删除10天前的MySQL binlog日志：

	PURGE MASTER LOGS BEFORE DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY); 
	show master logs;

