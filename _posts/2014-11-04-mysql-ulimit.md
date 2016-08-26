---
layout: post
title: "mysql ulimit 案例"
categories: 技术
tags: MySQL
---


---

开始：晚上十点被报警惊醒（幸好还没睡觉），报警内容:xxxxxxxxxxxxx“MySQL IS Down”；MySQL 没有任何预兆的就死啦。

勘察现场：->查看下MySQL进程---存在

->系统load，cpu，io 均很正常

->（个人觉得zabbix 不会误报）

->登录MySQL提示：ERROR 1135 (HY000): Can’t create a new thread (errno 11)

->perror 11 显示：

OS error code 11: Resource temporarily unavailable

->第一反应是 文件句柄不够用，查看文件句柄使用情况：

	lsof -n | awk '{print $2}' | sort | uniq -c | grep 'pid of mysql'

一切正常；

	ulimit -a 

显示所有的结果：

max process 为 1024；--基本可以肯定问题就出在这里，某个程序发起了过多的连接，现在可以考虑坐下限制（简单粗暴的方法是 设置ulimit -u 102400,然后再重启MySQL--）：

----> 查看3306 连接数：

	netstat -ano | grep ip:3306 | awk '{print $5}' | awk -F ':' '{print $1}' | sort | uniq -c

可以考虑使用iptables 限制最大连接数来处理：


	iptables -A INPUT -p tcp -m tcp --dport 3306 --tcp-flags FIN,SYN,RST,ACK SYN -m connlimit --connlimit-above 200 --connlimit-mask 32 -j REJECT --reject-with tcp-reset


故障反思：

其中漏掉的一点是：查看系统限制:/etc/security/limits.conf 中 

	max process = 65535

但ulimit -a 的时候显示的是 1024

	su mysql bash -c  "ulimit -a"


不科学的：

后经过google发现在centos 6.x中，添加了一个新的文件：/etc/security/limits.d/90-nproc.conf ，只有 noproc是已这个文件为准；

总结为：在centos5里面，只要在/etc/security/limits.conf 设置好久可以啦，在Centos6里面除了上面提到的limits.conf 配置文件，还要设置好/etc/security/limits.d/90-nproc.conf

方法二：找到一个可以不重启MySQL就可以在线修改noproc的方式！

从Linux 2.6.32开始可以使用

	echo -n "Max processes=204800:204800" > /proc/`pidof mysqld`/limits 
	
来动态修改进程的系统资源limits信息，不用再因为修改这个而去重启实例，亲测可用!
