---
layout: post
title: "逐行读取文本文件的 shell 脚本"
description: ""
category: 技术
tags: [Linux]
---


[原文链接](http://www.vpsee.com/2009/09/shell-script-read-a-file-line-by-line/)

网上有很多 shell script 读文本文件的例子，但是都没有讲出故事的全部，只说了一半。举个例子，比如从一个 testfile 文件中读取如下格式的文本行：

	$ vi testfile
	ls      -a -l /bin |  sort
	ls      -a -l /bin |  sort | wc
	ls      -a -l |  grep sh | wc
	ls      -a -l
	ls      -a -l |       sort      |    wc

最常见的一个 line by line 读取文件内容的例子就是：

	$ vi readfile
	#!/bin/sh

	testfile=$1
	while read -r line
	do
	echo $line
	done < $testfile

	$ chmod +x readfile
	$ ./readfile testfile
	ls -a -l /bin | sort
	ls -a -l /bin | sort | wc
	ls -a -l | grep sh | wc
	ls -a -l
	ls -a -l | sort | wc

这个例子的问题是读取文本行后，文本格式发生了变化，和原来 testfile 文件的内容不完全一致，空格字符自动被删除了一些。为什么会这样呢？因为 IFS，如果在 shell script 里没有明确指定 IFS 的话，IFS 会默认用来分割空格、制表、换行等，所以上面文本行里多余的空格和换行都被自动缩进了。

如果想要输出 testfile 文件原有的格式，把每行（作为整体）原封不动的打印出来怎么办？这时需要指定 IFS 变量，告诉 shell 以 "行" 为单位读取。  

	$ vi readfile
	#!/bin/sh

	IFS="
	"

	testfile=$1
	while read -r line
	do
	  echo $line
	done < $testfile

	$ ./readfile testfile
	ls      -a -l /bin |  sort
	ls      -a -l /bin |  sort | wc
	ls      -a -l |  grep sh | wc
	ls      -a -l
	ls      -a -l |       sort      |    wc

上面两种方法的输出不是差不多吗，有什么关系呢，第一种还美观一些？关系重大，VPSee 昨天写了一个模拟 shell 的 C 程序，然后又写了一个 shell script 来测试这个 C 程序，这个 script 需要从上面的 testfile 里读取完整一行传给 C 程序，如果按照上面的两种方法会得到两种不同的输入格式，意义完全不同：

	$./mypipe ls -a -l | sort | wc
	$./mypipe "ls -a -l | sort | wc "

显然我要的是第2种输入，把 "ls -a -l | sort | wc " 作为整体传给我的 mypipe，来测试我的 mypipe 能不能正确识别出字符串里面的各种命令。

如果不用 IFS 的话，还有一种方法可以得到上面第二种方法的效果：

	#!/bin/sh

	testfile=$1
	x=`wc -l $testfile |awk '{print $1}'`

	i=1
	while [ $i -le $x ]
	do
	  echo "`head -$i  $testfile | tail -1`"
	  i=`expr $i + 1`
	done
