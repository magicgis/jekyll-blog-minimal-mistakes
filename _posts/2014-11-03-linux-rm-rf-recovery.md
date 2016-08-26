---
layout: post
title: "rm rf 误删恢复"
categories: 技术
tags: Linux
---


---
在linux下rm -rf 是一个很可怕的命令，因为下达这个命令意味着一旦删除的文件是无法挽回的，事实是如此吗？真的没有补救措施了吗？答案是委婉了，在一定的条件下可以补救 ，大家可能熟悉windows下删除的补救措施是通过相关的软件实现的，在linux下同样可以做到补救，但是有个大前提：就是不能有覆盖的动作（意思就是在尝试恢复删除的数据前，删除文件的目录内不能存放新东西），不然覆盖多少就损失多少！

这里用到的套件是ext3grep、系统必须默认的安装上

e2fsprogs-libs-1.39-23.el5

e2fsprogs-devel-1.39-23.el5

e2fsprogs-1.39-23.el5
	
	[root@localhost ~]# rpm -qa|grep e2fsprogs

	e2fsprogs-libs-1.39-23.el5

	e2fsprogs-devel-1.39-23.el5

	e2fsprogs-1.39-23.el5

	[root@localhost ~]# ll ext3grep-0.10.2.tar.gz

	-rw-r--r-- 1 root root 236364 Oct 17  2011 ext3grep-0.10.2.tar.gz

	[root@localhost ~]# tar zxvf ext3grep-0.10.2.tar.gz

	[root@localhost ~]# cd ext3grep-0.10.2

	[root@localhost ext3grep-0.10.2]# ./configure

	[root@localhost ext3grep-0.10.2]# make && make install

	[root@localhost ~]# ll /usr/local/bin

	total 2656

	-rwxr-xr-x 1 root root 2709704 Oct 15 04:46 ext3grep   //www.linuxidc.com这句是那个可执行文件

接下来演示一个补救的过程实例

	[root@localhost ~]# mkdir /data/ /ixdba/

	[root@localhost data]# dd if=/dev/zero of=data-disk bs=1M count=105

	[root@localhost data]# mkfs.ext3 data-disk   //格式为ext3的文件系统，在出现的提示符处输入y

	[root@localhost data]# mount -o loop /data/data-disk /ixdba/  //挂载

	[root@localhost data]# cp /etc/host* /ixdba/  //往里边放文件

	[root@localhost data]# cp /etc/passwd /ixdba/

	[root@localhost data]# cd /ixdba/

	[root@localhost data]# rm -rf *   //制造删除的动作

	[root@localhost data]# cd /data/

	[root@localhost data]# ext3grep /data/data-disk --ls --inode 2   //查看丢失的文件

	[root@localhost data]# ext3grep /data/data-disk --restore-file passwd  //仅仅恢复passwd这个文件

	[root@localhost data]# ext3grep /data/data-disk --restore-all    //恢复的动作，全部恢复

	[root@localhost data]# ls
	data-disk  data-disk.ext3grep.stage1  data-disk.ext3grep.stage2  RESTORED_FILES



	[root@localhost data]# ll RESTORED_FILES/       //所有恢复的文件全在这个文件夹里存放，都找回来了

	total 48

	-rw-r--r-- 1 root root   17 Oct 15 06:03 host.conf

	-rw-r--r-- 1 root root  187 Oct 15 06:03 hosts

	-rw-r--r-- 1 root root  161 Oct 15 06:03 hosts.allow

	-rw-r--r-- 1 root root  347 Oct 15 06:03 hosts.deny

	drwx------ 2 root root 4096 Oct 15 06:04 lost+found

	-rw-r--r-- 1 root root 1635 Oct 15 06:03 passwd

总结：这里只能实现的是首次恢复的动作，并且不能有覆盖的动作，这个是很久以前都知道的知识，在这里做个笔记，以加深记忆！