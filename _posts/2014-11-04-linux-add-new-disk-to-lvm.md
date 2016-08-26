---
layout: post
title: "linux 增加磁盘到LVM"
categories: 技术
tags: Linux
---


---
有用LVM2，现在空间不足，需再加一块硬盘。先加上硬盘，用fdisk -l，可以看到新硬盘。给新加的硬盘分区: 

	fdisk /dev/sdb
	>n
	>t
	>8e(linux LVM)

分成一个分区，格式为linux LVM. 

下面开始把分区加到LVM内去： 

1.建立物理卷 

	pvcreate /dev/sdb1 

2.把新物理卷加入到卷组中去

	vgextend VolGroup00 /dev/sdb1 

3.把新的空间加到逻辑卷中去

	lvextend -L+10G /dev/VolGroup00/LogVol00 

4.加上去之后，目前用df -h还看不到新的空间，需要激活

	RHEL 4:
	ext2online /dev/VolGroup00/LogVol00
	RHEL 5:
	resize2fs -p /dev/VolGroup01/LogVol00 

全部搞掂，再用df -h，就可以看到新的空间了。

几个命令：
	
	扩展vg: vgextend vg0(卷组名) /dev/sdc1(pv名)
	
	扩展lv: lvextend -L +200m /dev/vg0/home(lv名)
	
	查看信息：vgdisplay /dev/vg0 ,lvdisplay /dev/vg0/logVol00
	
	数据迁移：pvmove /dev/sda1 /dev/sdc1
	
	删除逻辑卷步骤：
	A.umout所有lv
	B.lvremove /dev/vgo/logVol00(有快照要先删除快照)
	C.vgchange -an /dev/vg0 (休眠vg0,-ay是激活vg0)
	D.vgremove vg0 (移除)
	
	注意： 迁移时注意PE、LE是一一对应的，大小要一致，迁移时不能改变大小。

记录：

检查当前分区大小

	[root@jxxdb2 ~]# df -h

	Filesystem            Size Used Avail Use% Mounted on

	/dev/mapper/VolGroup00-LogVol00

						   15G 3.7G 9.9G 27% /u01/oracle/oradata


	[root@jxxdb2 ~]# cat /etc/fstab


检查vg还有多少空间没有分配以及当前lv的大小

	[root@jxxdb2 ~]# vgdisplay | egrep "Volume group|VG Name|Alloc PE|Free PE"

	--- Volume group ---

	VG Name               VolGroup00

	Alloc PE / Size       610 / 19.06 GB

	Free PE / Size       11107 / 347.09 GB


	[root@jxxdb2 ~]# lvdisplay | egrep " Logical volume|LV Name|VG Name|LV Size"

	--- Logical volume ---

	LV Name                /dev/VolGroup00/LogVol00

	VG Name                VolGroup00

	LV Size                14.50 GB

	--- Logical volume ---

	LV Name                /dev/VolGroup00/LogVol01

	VG Name                VolGroup00

	LV Size                4.56 GB