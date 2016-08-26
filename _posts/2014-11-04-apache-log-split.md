---
layout: post
title: "apache 日志分割"
categories: 技术
tags: Apache
---


---
分割apache日志文件，按天进行分割


	#!/bin/bash

	# This script run at 00:00

	# The Apache logs path

	logs_path="/www/wwwlogs"

	host=`ls -l $logs_path/*-access_log | awk -F " " '{print $9}' | awk -F ".access"
	 '{print $1}' | awk -F "$logs_path/" '{print $2}'`

	for i in $host

	do

	mkdir -p ${logs_path}/$i/

	mv ${logs_path}/$i-access_log ${logs_path}/$i/[$(date -d "yesterday" +"%Y")]-
	--[$(date -d "yesterday" +"%m")]---$i.access_$(date -d "yesterday" +"%Y%m%d").log

	mv ${logs_path}/$i-error_log ${logs_path}/$i/[$(date -d "yesterday" +"%Y")]-
	--[$(date -d "yesterday" +"%m")]---$i.error_$(date -d "yesterday" +"%Y%m%d").log

	done

	kill -USR1 `cat /usr/local/apache/logs/httpd.pid`


保存为：cut_apache_log文件，设置cut_apache_log启动时间，执行命令crontab -e进入编辑状态，添加如下代码,每天0点00分启动。

	0 0 * * * /usr/local/apache/bin/cut_apache_log