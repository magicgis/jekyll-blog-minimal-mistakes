---
layout: post
title: "linux中的set命令: set -e 与 set -o pipefail "
description: ""
category: 技术
tags: [Linux]
---


工作中经常在shell脚本中看到set的这两个用法，但就像生活中的很多事情，习惯导致忽视，直到出现问题才引起关注。

####1. set -e
set命令的-e参数，linux自带的说明如下：

	"Exit immediately if a simple command exits with a non-zero status."

也就是说，在"set -e"之后出现的代码，一旦出现了返回值非零，整个脚本就会立即退出。有的人喜欢使用这个参数，是出于保证代码安全性的考虑。但有的时候，这种美好的初衷，也会导致严重的问题。

真实案例：
脚本a.sh开头使用了"set -e"，且能正常运行。在几个月或更久以后，因需求升级，在脚本中增加了3行hadoop操作：
	
	#!/bin/bash
	set -e
	...
	/home/work/.../hadoop dfs -rmr /app/.../dir
	/home/work/.../hadoop dfs -mkdir /app/.../dir
	/home/work/.../hadoop dfs -put file_1 /app/.../dir/
	...

这几行hadoop命令逻辑很简单：在hdfs上清除并新建一个目录，并将一份本地文件推送至这个目录，供后续使用。将这几行单拎出来，在命令行下执行，除了提示待删除的目录不存在，并没有什么问题，文件还是会被推送到指定的地方。

但第一次执行这个脚本的时候，却失败退出了，且导致调用该脚本的程序整体退出，造成了严重的后果。原因是hdfs上还没有这个目录，rmr这一行会返回255，这个值被脚本前方的"set -e"捕捉到，直接导致了脚本退出。

新增的代码本身并没有问题，先删除再新建目录，反而是保证数据安全的比较规范的操作，删除命令本身的容错性，可以保证后续命令正常执行。事实是这个脚本有好几百行，且逻辑比较复杂，在增加这几行代码的时候，开发人员已经不记得这个脚本里还有个"set -e"埋伏着了。

可见设置"set -e"，在脚本开发过程中可能很有帮助，而在开发完成后，特别是对于后期可能有升级的脚本，则可能是埋下了安全隐患。

####2. set -o pipefail
对于set命令-o参数的pipefail选项，linux是这样解释的：

	"If set, the return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status,or zero if all commands in the pipeline exit successfully. This option is disabled by default."

设置了这个选项以后，包含管道命令的语句的返回值，会变成最后一个返回非零的管道命令的返回值。听起来比较绕，其实也很简单：

	# test.sh
	set -o pipefail
	ls ./a.txt |echo "hi" >/dev/null
	echo $?

运行test.sh，因为当前目录并不存在a.txt文件，输出：
ls: ./a.txt: No such file or directory
1 #设置了set -o pipefail，返回从右往左第一个非零返回值，即ls的返回值1

注释掉set -o pipefail这一行，再次运行，输出：
ls: ./a.txt: No such file or directory
0 # 没有set -o pipefail，默认返回最后一个管道命令的返回值