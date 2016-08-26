---
layout: post
title: "virtualbox压缩vdi硬盘"
description: ""
category: 技术
tags: [虚拟化]
---


查看虚拟硬盘（固定大小）信息：

	"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" showhdinfo win10.vdi
	UUID:           36524650-f833-4cbd-ac82-899603ae2f4c
	Parent UUID:    base
	State:          created
	Type:           normal (base)
	Location:       C:\Users\YOURNAME\VirtualBox VMs\Win10\Win10.vdi
	Storage format: VDI
	Format variant: fixed default
	Capacity:       51200 MBytes
	Size on disk:   51048 MBytes
	Encryption:     disabled
	In use by VMs:  Win10 (UUID: f3dc93e9-d91e-4078-8a9f-0cdd811b0552)

修改固定大小的虚拟硬盘为动态分配存储的硬盘，可以看到操作后Format variant变成dynamic default：

    "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyhd Win10.vdi -type normal

下面开始磁盘空间压缩，方法是这样：

	1,在guest os 中清理系统， windows的话可以再硬盘碎片整理一下

	2,在 guest os 中 使用 sdelete -z； linux 使用 zerofree

	3,"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyhd <uuid>|<filename>  --compact

第一次尝试之后发现这个操作对减小vdi文件体积的作用不明显，于是我关闭了虚拟机系统盘的bitlocker然后再按照步骤123来了一遍，并且第二步加了个参数

	sdelete -c -z

然后，50G的VDI大小变成了20G左右，目前还不确定是bitlocker未关闭还是-c这个参数造成的第一次尝试失败，神奇Oracle！
	
over