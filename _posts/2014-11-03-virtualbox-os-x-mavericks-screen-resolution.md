---
layout: post
title: "VirtualBox OS X Mavericks 虚拟机分辨率调整"
categories: 技术
tags: Mac
---


---
VirtualBox OS X Mavericks 分辨率修改
 
需要开启EFI模式 然后在命令行下 VirtualBox目录 输入一下命令：

VBoxManage setextradata "虚拟机名称" VBoxInternal2/EfiGopMode N
其中 N 可以是 0,1,2,3,4,5 其中一个，分别代表 640×480, 800×600, 1024×768, 1280×1024, 1440×900, 1920×1200 几种分辨率

Sample：

	"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" setextradata Mavericks VBoxInternal2/EfiGopMode 3

	"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" setextradata Mavericks CustomVideoMode1 1280x960x32