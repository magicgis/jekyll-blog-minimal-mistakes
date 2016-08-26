---
layout: post
title: 增加ssh无密码信任连接的安全性
date: 2016-07-01 10:13:07
categories: 技术
tags: Linux
---

### 一般情况这样玩

为了方便系统管理或者服务器运维自动化，我们通常要在服务器间做ssh无密码信任连接。

在服务器端创建密钥

```
ssh-keygen -t dsa  
```

一路回车，在~/.ssh下生成的id_rsa是私钥，id_rsa.pub是公钥。复制公钥到目标服务器，然后就可以无密码登录了：

自动化拷贝公钥到多台目标机器

```
#!/bin/sh
. /etc/init.d/functions
for ip in 77 185 197 208
do
 expect fenfa_sshkey.exp ~/.ssh/id_dsa.pub 10.86.17.$ip
 if [ $? -eq 0 ];then
    echo "$ip" /bin/true
 else
    echo "$ip" /bin/false
 fi
done
```

expect脚本

```
#!/usr/bin/expect
set timeout 10

if { $argc != 2 } {
 send_user "usage: expect fenfa_sshkey.exp file host\n"
 exit
}
#
set file [lindex $argv 0]
set host [lindex $argv 1]
set user sa
set psw yourpassword

spawn ssh-copy-id -i $file -p 22 $user@$host

expect {
    "(yes/no)?" {
        send "yes\n"
        expect "*password:*" {
            send $psw
            send "\r"
        }
    }
    "*password:*" {
        send $psw
        send "\r"
    }
}
expect eof

exit -onexit {
  send_user "$user say good bye to you!\n"
}
```

这种方式很方便，但是如果操作主机上没有口令短语的id_rsa文件被别人获得，你的服务器基本就是人家的了。所以使用口令短语对加强安全性来说是有必要的。我们把目标主机的 ~/.ssh/authorized_keys 移走，在操作主机上重新生成一对儿密钥，再ssh-copy-id到目标主机，ssh -p 22 sa@ip 连接的时候必须输入正确的口令短语才能登录目标主机。

在生产环境里，已经部署了不带口令短语的密钥，必须删除目标主机原有的公钥（保存在目标主机的~/.ssh/authorized_keys），删除操作主机旧的密钥并重新生成一套带口令的，再ssh-copy-id到目标主机。

### 重点内容

现在又一个问题来了，加了口令短语，私钥安全了，但是登录麻烦了，自动化运维也不可能了。怎么办？
我们可以用ssh-agent（ssh代理守护进程）。

启动代理守护进程：

	eval `ssh-agent`

将私钥添加到代理守护进程：

	ssh-add

列出代理守护进程保存的私钥：

	ssh-add -l
	
删除代理守护进程保存的私钥：

	ssh-add -D

### 一个例子说说eval

这个bash内部指令非常有意思，它是将后面的 `` 符号（键盘左上角跟～符一起的那个，不是单引号哈！）内的指令执行之后，把输出结果再执行一遍，比如上文的 

	eval `ssh-agent`

先看看 ssh-agent 单独执行结果：

```
[root@centos7-cn ~]# ssh-agent
SSH_AUTH_SOCK=/tmp/ssh-CDZB3GtAT0MT/agent.11758; export SSH_AUTH_SOCK;
SSH_AGENT_PID=11759; export SSH_AGENT_PID;
echo Agent pid 11759;
[root@centos7-cn ~]#
```

	eval `ssh-agent` 
	
就是将ssh-agent的输出结果再执行一次，相当于：
	
```
[root@centos7-cn ~]# SSH_AUTH_SOCK=/tmp/ssh-CDZB3GtAT0MT/agent.11758; export SSH_AUTH_SOCK;
[root@centos7-cn ~]# SSH_AGENT_PID=11759; export SSH_AGENT_PID;
[root@centos7-cn ~]# echo Agent pid 11759;
```

所以 

	eval `ssh-agent`

的执行结果就是：

后台运行ssh-agent，并且在当前会话输出两个环境变量SSH_AUTH_SOCK、SSH_AGENT_PID，然后再显示 Agent pid 11759 。

我们试一下：

```
[root@centos7-cn ~]# eval `ssh-agent`
Agent pid 11877
[root@centos7-cn ~]# echo $SSH_AUTH_SOCK
/tmp/ssh-2Aq37RrIkeOH/agent.11876
[root@centos7-cn ~]# echo $SSH_AGENT_PID
11877
[root@centos7-cn ~]# 
```

注意，这里得到的Pid跟单独执行的ssh-agent不同了，pgrep ssh-agent 会看到两个进程号：

```
[root@centos7-cn ~]# pgrep ssh-agent
11759
11877
[root@centos7-cn ~]#
```

还要注意，退出当前会话并不会杀死ssh-agent进程。手工杀死进程除了上述的 pgrep 指令，还有ssh-agent -k 可以。试试：

```
[root@centos7-cn ~]# ssh-agent
SSH_AUTH_SOCK=/tmp/ssh-gm8UdqqlTXeb/agent.14140; export SSH_AUTH_SOCK;
SSH_AGENT_PID=14141; export SSH_AGENT_PID;
echo Agent pid 14141;
[root@centos7-cn ~]#
[root@centos7-cn ~]# ssh-agent -k
SSH_AGENT_PID not set, cannot kill agent
```

找不到SSH_AGENT_PID环境变量，这个指令选项无效。那么手工输出一下吧：

```
[root@centos7-cn ~]#
[root@centos7-cn ~]# SSH_AGENT_PID=14141; export SSH_AGENT_PID;
[root@centos7-cn ~]#
[root@centos7-cn ~]# ssh-agent -k
unset SSH_AUTH_SOCK;
unset SSH_AGENT_PID;
echo Agent pid 14141 killed;
[root@centos7-cn ~]#
```

这回可以了。所以 ssh-agent 命令最好还是用 

	eval `ssh-agent` 
	
执行更方便，但是要记住不能重复执行，ssh-agent -k 只负责最后一个进程，道理呢？参考ssh-agent -k指令输出，自己琢磨一下吧。

[参考链接](http://www.cnblogs.com/panblack/p/Secure_ssh_trust_connection.html?utm_source=tuicool&utm_medium=referral)