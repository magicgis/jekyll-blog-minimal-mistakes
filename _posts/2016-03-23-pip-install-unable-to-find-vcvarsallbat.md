---
layout: post
title: "pip install 的报错 Unable to find vcvarsall.bat"
description: ""
category: 技术
tags: [Python]
---


Python 2.7 会搜索 Visual Studio 2008.
如果你电脑上没有这个版本的话,比如只有:

1. Visual Studio 2010,在cmd里面执行: 

	SET VS90COMNTOOLS=%VS100COMNTOOLS%

2. Visual Studio 2012 的话: 

	SET VS90COMNTOOLS=%VS110COMNTOOLS%

其他版本的VS依此类推

解决了上面的问题，执行pip install 的时候有时候还会报错：

	general error c1010070: Failed to load and parse the manifest. The system cannot find the file specified.
	error: command 'mt.exe' failed with exit status 31

解决办法：由于vs201x的link.exe的参数稍微有些改变，所以在link的时候没有生成manifest文件，自然mt.exe找不到这个文件。只需要在msvc9compiler.py里面搜索一下MANIFESTFILE，然后在他上面加一行

	ld_args.append('/MANIFEST')

保存就OK了。

补充:
如果是用的64位的python，那么链接的时候会用到64位的lib库，所以还得把开发包中Lib目录中的x64目录里面的两个lib文件放到vc的lib目录中的amd64目录中。比如对于visual studio 2012就放在C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\lib\amd64\