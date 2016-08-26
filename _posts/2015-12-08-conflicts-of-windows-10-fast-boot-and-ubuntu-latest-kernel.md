---
layout: post
title: "Ubuntu最新版内核与Windows10快速启动设置的冲突"
description: ""
category: 技术
tags: [Linux]
---


最近把双系统中的Ubuntu15升级了一下内核（Webmin里面提示升级就点了，纯属手贱），然后重启进不了桌面，报错
	
	fsck from util-linux ...
	Welcome to emergency mode!
	...

欢迎来到紧急模式，欢迎你妹夫啊！

初步查看是/home分区只读了，有IO错误。尝试进livecd执行fsck无果。。。多次查询搜索仍然没有解决，官网有bug提示，但是没说怎么解决的。

最后在某论坛发现一个老外说最新版的内核4.2.0.19和双系统里面Windows8的快速启动有冲突，因为dmesg发现有不少磁盘的错误。。。

听起来是多么风马牛不相及的问题！Ubuntu的启动去检测Windows分区作甚！检测也就罢了，为啥Windows分区不能挂载还不让进GUI，神逻辑。。。

我的是Windows 10 和 Ubuntu 15双系统，于是抱着试试看的心情，重启进Windows里面电源设置里面取消了Windows的快速启动，重启就OK。

特此记录！

