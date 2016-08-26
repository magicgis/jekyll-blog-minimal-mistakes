---
layout: post
title: "正确配置Linux系统ulimit/nproc值的方法"
description: ""
category: 技术
tags: [Linux]
---

在Linux下面部署应用的时候，有时候会遇上Socket/File: Can’t open so many files的问题；这个值也会影响服务器的最大并发数，其实Linux是有文件句柄限制的，而且Linux默认不是很高，一般都是1024，生产服务器用其实很容易就达到这个数量。下面说的是，如何通过正解配置来改正这个系统默认值。

查看方法

我们可以用ulimit -a来查看所有限制值

	[root@centos5 ~]# ulimit -a
	core file size          (blocks, -c) 0
	data seg size           (kbytes, -d) unlimited
	scheduling priority             (-e) 0
	file size               (blocks, -f) unlimited
	pending signals                 (-i) 31365
	max locked memory       (kbytes, -l) 64
	max memory size         (kbytes, -m) unlimited
	open files                      (-n) 1024
	pipe size            (512 bytes, -p) 8
	POSIX message queues     (bytes, -q) 819200
	real-time priority              (-r) 0
	stack size              (kbytes, -s) 10240
	cpu time               (seconds, -t) unlimited
	max user processes              (-u) 31365
	virtual memory          (kbytes, -v) unlimited
	file locks                      (-x) unlimited

其中 "open files (-n) 1024 "是Linux操作系统对一个进程打开的文件句柄数量的限制

(也包含打开的SOCKET数量，可影响MySQL的并发连接数目)。


正确的做法，应该是修改/etc/security/limits.conf
里面有很详细的注释，比如

	hadoop soft nofile 32768
	hadoop hard nofile 65536

	hadoop soft nproc 32768
	hadoop hard nproc 65536

就可以将文件句柄限制统一改成软32768，硬65536。配置文件最前面的是指domain，设置为星号代表全局，另外你也可以针对不同的用户做出不同的限制。

注意：这个当中的硬限制是实际的限制，而软限制，是warnning限制，只会做出warning；其实ulimit命令本身就有分软硬设置，加-H就是硬，加-S就是软
默认显示的是软限制，如果运行ulimit命令修改的时候没有加上的话，就是两个参数一起改变。

RHE6及以后 nproc的修改在/etc/security/limits.d/90-nproc.conf中

生效

因为我平时工作最多的是部署web环境(Nginx+FastCGI外网生产环境和内网开发环境)，重新登陆即可(reboot其实也行)我分别用root和www用户登陆，用ulimit -a分别查看确认，做这之前最好是重启下ssh服务，service sshd restart。

