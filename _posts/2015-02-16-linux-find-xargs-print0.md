---
layout: post
title: "linux find xargs print0"
description: ""
category: 技术
tags: [Linux]
---


今天看到一个shell脚本，里面有一句

	find . -type f -name 'list*' -print0 | xargs -0 rm

很不理解为什么 -print0 | xargs -0 rm
为什么都要有个0？

原来xargs 默认是以空白字符来做分割的，当执行rm时候，如果查找出来的文件名中有空格，那就容易把类似于 test 1.php  当做test  和 1.php来删除。

为了解决这个问题，在打印出每一条记录后，在后面输入一个结束符，代替原来的换行符，然后再以换行符来分割每一条记录，就会保证每一条的唯一性。

为什么不用-exec，而用xargs ?因为find会把找到的记录都给后面的命令传过去执行，-exec有长度限制，可能会出现参数溢出。