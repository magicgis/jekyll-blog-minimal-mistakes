---
layout: post
title: "linux kernel parameters for oracle install"
categories: 技术
tags: Linux
---


---

安装Oracle之前，除了检查操作系统的硬件和软件是否满足安装需要之外，一个重点就是修改内核参数，其中最主要的是和内存相关的参数设置。

SHMMAX参数：

Linux进程可以分配的单独共享内存段的最大值。一般设置为内存总大小的一半。这个值的设置应该大于SGA_MAX_TARGET或MEMORY_MAX_TARGET的值，因此对于安装Oracle数据库的系统，shmmax的值应该比内存的二分之一大一些。

grep MemTotal /proc/meminfo
cat /proc/sys/kernel/shmmax

上面的命令是检查系统内存的大小，以及当前shmmax的设置。

echo 21474836480  /proc/sys/kernel/shmmax

sysctl -w kernel.shmmax=21474836480

echo "kernel.shmmax=21474836480"  /etc/sysctl.conf
 
这是设置shmmax参数的几种方法，这三种方式都可以将shmmax设置为20G。这个参数的修改可以不重启数据库。个人推荐使用第二种sysctl命令的方式。采用第三种方式需要执行sysctl操作或重启，但是为了确保下次重启后设置值仍然生效，第三种方式是必不可少的。前两种方式类似alter system set scope = memory，而第三种方式则类似

alter system set scope = spfile。

SHMMNI参数：设置系统级最大共享内存段数量。Oracle10g推荐最小值为4096，可以适当比4096增加一些。

cat /proc/sys/kernel/shmmni

echo 4096  /proc/sys/kernel/shmmni

sysctl -w kernel.shmmni=4096

echo "kernel.shmmni=4096"  /etc/sysctl.conf

检查和设置方法如上，这和shmmax的修改方式没有区别，不在赘述。

SHMALL参数：设置共享内存总页数。这个值太小有可能导致数据库启动报错。很多人调整系统内核参数的时候只关注SHMMAX参数，而忽略了SHMALL参数的设置。这个值推荐设置为物理内存大小除以分页大小。

getconf PAGE_SIZE

通过getconf获取分页的大小，用来计算SHMALL的合理设置值：

SQL select 32*1024*1024*1024/4096 from dual;

对于32G的内存,4K分页大小的系统而言，SHMALL的值应该设置为8388608。

cat /proc/sys/kernel/shmall

echo 8388608  /proc/sys/kernel/shmall

sysctl -w kernel.shmall=8388608

echo " kernel.shmall=8388608"  /etc/sysctl.conf

查询和设置方法如上。

信号灯semaphores是进程或线程间访问共享内存时提供同步的计数器。

SEMMSL参数：设置每个信号灯组中信号灯最大数量，推荐的最小值是250。对于系统中存在大量并发连接的系统，推荐将这个值设置为PROCESSES初始化参数加10。

SEMMNI参数：设置系统中信号灯组的最大数量。Oracle10g和11g的推荐值为142。

SEMMNS参数：设置系统中信号灯的最大数量。操作系统在分配信号灯时不会超过LEAST(SEMMNS,SEMMSL*SEMMNI)。事实上，如果SEMMNS的值超过了SEMMSL*SEMMNI是非法的，因此推荐SEMMNS的值就设置为SEMMSL*SEMMNI。Oracle推荐SEMMNS的设置不小于32000，假如数据库的PROCESSES参数设置为600，则SEMMNS的设置应为：
 
 SQL select (600+10)*142 from dual;

SEMOPM参数：设置每次系统调用可以同时执行的最大信号灯操作的数量。由于一个信号灯组最多拥有SEMMSL个信号灯，因此有推荐将SEMOPM设置为SEMMSL的值。Oracle验证的10.2和11.1的SEMOPM的配置为100。

通过下面的命令可以检查信号灯相关配置：

 cat /proc/sys/kernel/sem
 250 32000 100 128

对应的4个值从左到右分别为SEMMSL、SEMMNS、SEMOPM和SEMMNI。修改方法为：

 echo 610 86620 100 142  /proc/sys/kernel/sem
 sysctl -w kernel.sem="610 86620 100 142"
 echo "kernel.sem=610 86620 100 142"  /etc/sysctl.conf

