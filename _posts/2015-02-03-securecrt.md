---
layout: post
title: "SecureCRT 设置"
description: ""
category: 技术
tags: [Linux]
---


###常用快捷键备忘

1、 ctrl + a :  移动光标到行首

2、 ctrl + e ：移动光标到行尾

3、 ctrl + d ：删除光标之后的一个字符

4、 ctrl + w ： 删除行首到当前光标所在位置的所有字符

5、 crtl + k ： 删除当前光标到行尾的所有字符

6、 alt + b ： 打开快速启动栏

7、 alt + 1/2/3... ： 在多个不同的session标签之间切换

8、 ctrl+shift+c ：复制

9、 ctrl+shift+v ：粘贴 

鼠标复制：
options -> global options ->  Terminal  钩上Copy on select，并钩上paste on middle button
这样在secrecrt中用鼠标选中一段字符，就可以直接复制到剪切板，按鼠标中间的齿轮完成复制粘贴。
 
双击复制并打开新session:
options -> global options -> Terminal -> Tabs 选择Double-click action的下拉框为Clone tab，这样就可以在已经打开的session标签中鼠标双击，打开一个完全一样的新session标签。
 
用sftp与windows之间上传现在文件：
在一个已经打开的session中按alt + p组合键，打开一个该session的sftp，通过cd,ls查看远程服务器的文件，通过lcd,lls可以查看windows上面的的文件，通过put,get命令可以进行文件的上传下载，用习惯之后比rz,sz效率高。

###键盘映射

options ->  global options -> General -> Default Session,点击Edit default settings按钮，再Terminal -> Mapped Keys，在这里面用map a key按钮来设定键盘映射，对于经常需要输入的字符串，可以在这里设置，如密码。

另外命令行HOME和END键没有用，总感觉不方便，添加键盘映射如下：

SecureCRT菜单，工具→键映射编辑器，选中键盘中点击“HOME”，点击"映射选定键"会弹出一个窗口，在“发送字符串”中输入：

	\033[1~

同样对"END"操作改成

	\033[4~

保存该设置，并设为当前使用。ok，现在ssh远程登录后命令行能正常使用HOME和END了。
注意的是，每个会话需要独立设置。还有在vim里还是会有问题，尚待解决

###保持会话

options -> global options -> General -> Default Session,点击Edit default settings按钮，在Terminal中钩上Send protocol NO-OP, every 30 seconds，这样可以保证securecrt不会因为一段时间没有操作，而丢掉连接。

###改变颜色配置

最佳解决方案：Global Options => Terminal => Appearance => ANSI Color：将Normal color的颜色改成自己喜欢的颜色即可。（勾选“ANSI Color”, 才能显示鲜艳的颜色）

改变显示的最大列(默认80列，不满屏)：
1） Global Options => Terminal => Appearance， 调整最大列为300；
2） Options => Session Options => Terminal => Emulation，调整逻辑列为132（或其他）

让标签显示文件路径：
Options => Session Options => Terminal => Emulation
选择Terminal为Xterm/VShell，勾选“ANSI Color”，这样就会自动修改标签标题，还会包含当前目录。

关闭“确认断开对话框”：
options ->  global options -> General ，取消“显示确认断开对话框”。

###优化设置

[配置终端显示颜色]
    Options->SessionOptions ->Emulation
        把Terminal类型改成xterm，并点中ANSI Color复选框。

[配置字体和编码]
    Options->SessionOptions->Appearance->font 
        新宋体
        文字大小: 11
        character: utf-8

[去掉显示的下划线]
    Options->SessionOptions->Appearance->Current color
        选择编辑，在新打开的窗口去掉show underline

[修改目录颜色]
    why: secureCRT有一个很大的问题，如果设置Emulation Terminal 为xterm模式，目录的蓝色，配置文件的注释跟背景的黑色搅拌在一起很难看清楚。
    option->Global options –> Terminal->Apperance->ANSI Color 把蓝色定义成别的颜色。
