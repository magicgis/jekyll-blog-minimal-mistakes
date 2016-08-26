---
layout: post
title: "windows 安装证书命令"
categories: 技术
tags: Windows
---


---

import cet file to computer account

	certmgr.exe /add "d:\MoneyTreeRootCA.cer" /s /r localMachine root

import cet file to local user account

	certmgr.exe /add "d:\MoneyTreeRootCA.cer" /s /r currentUser root
