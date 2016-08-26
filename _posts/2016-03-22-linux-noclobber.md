---
layout: post
title: "linux noclobber"
description: ""
category: 技术
tags: [Linux]
---


来源：CU之Shell十三问

	CODE:
	$ set -o noclobber
	$ echo "4" > file.out
	-bash: file: cannot overwrite existing file

那，要如何取消这个"限制"呢？
哦，将 set -o 换成set +o 就行：

	CODE:
	$ set +o noclobber
	$ echo "5" > file.out
	$ cat file.out

再问：那... 有办法不取消而又"临时"盖写目标档案吗？
哦，佛曰：不可告也﹗
啊~~~ 开玩笑的、开玩笑的啦~~~ ^_^ 唉，早就料到人心是不足的了﹗

	CODE:
	$ set -o noclobber
	$ echo "6" >| file.out
	$ cat file.out

	留意到没有：在 > 后面再加个" | "就好(注意： > 与 | 之间不能有空白哦)....
	
突然感觉不知道的东西还是太多