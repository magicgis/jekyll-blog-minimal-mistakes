---
layout: post
title: "双系统进Ubuntu开机卡死"
date: 2016-01-13 12:02:02
description: ""
category: 技术
tags: [Ubuntu]
---


公司淘汰的DELL OPTIPLEX780自从带回家装机之后一直焕发着第二春。不过自打安装了双系统之后就小毛病不断，这次又进不去ubuntu的X了，虽说被无数次折磨过，不过实在不想再像以前那样直接重装ubuntu了，于是开始Google咯，直到问题解决，现在记录一下问题作为备忘。

先说系统环境

软件：

Window 10 + Ubuntu 15.10

➜  ~  lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 15.10
Release:	15.10
Codename:	wily

硬件：

硬盘：Samsung SSD 850 EVO 120GB（操作系统盘） + 希捷（Seagate）ST1000DM003-1ER162 (CC45)
CPU：Intel® Core™2 Duo CPU E7500 @ 2.93GHz × 2
显卡：Intel® Q45/Q43

默认启动项Systemd，进不了X，查看启动项内容如下：(libata.force=noncq是Google之后自己加的，关键词: EVO 850 linux kernel ncq bug，参考链接：[hdd problems, failed command: READ FPDMA QUEUED](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/550559))


	menuentry 'Ubuntu' --class ubuntu --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-simple-211dc254-7fee-4d5b-a9c7-01980b270596' {
	recordfail
	load_video
	gfxmode $linux_gfx_mode
	insmod gzio
	if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi
	insmod part_msdos
	insmod xfs
	set root='hd0,msdos7'
	if [ x$feature_platform_search_hint = xy ]; then
	search --no-floppy --fs-uuid --set=root --hint-bios=hd0,msdos7 --hint-efi=hd0,msdos7 --hint-baremetal=ahci0,msdos7  211dc254-7fee-4d5b-a9c7-01980b270596
	else
	search --no-floppy --fs-uuid --set=root 211dc254-7fee-4d5b-a9c7-01980b270596
	fi
	linux	/boot/vmlinuz-4.2.0-23-generic root=UUID=211dc254-7fee-4d5b-a9c7-01980b270596 ro libata.force=noncq quiet splash $vt_handoff
	initrd	/boot/initrd.img-4.2.0-23-generic
	}


第二启动项upstart进入X桌面环境没有问题

linux	/boot/vmlinuz-4.2.0-23-generic root=UUID=211dc254-7fee-4d5b-a9c7-01980b270596 ro libata.force=noncq quiet splash $vt_handoff init=/sbin/upstart

翻来覆去找谷歌，终于看到某位大神在一个帖子里不经意的一句，算是功夫不负有心人

[Thread: Ubuntu Installation Freezes Randomly on MSI GE72 2QF Apache Pro 2](http://ubuntuforums.org/showthread.php?t=2284315)

这句话要记下来（第二句咯）：

1. You HAVE to install ubuntu 15.04 64bit. Any other version simply does not work. Some people also reported that 14.04.3 64bit works too.
2. In the BIOS you have to disable the following: FastBoot, Intel Speedstep, SecureBoot
3. In the BIOS make sure that UEFI is enabled with CSM
4. When starting the Ubuntu installation you have to add the kernel option "libata.force=noncq". This is a MUST!
5. After the installation do a full update on Ubuntu. Then you can remove the kernel option "libata.force=noncq". Your SSD should perform faster now. But SpeedStep is still a problem. I have to keep it off.
6. I even re-enabled Fastboot and Secure in the BIOS and it still runs fine.

于是，重启进BIOS，把FastBoot禁用了，然后按顺序操作，一切完好如初。。。
