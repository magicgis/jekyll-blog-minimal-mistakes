---
layout: post
title: "linux ssh 登陆慢"
categories: 技术
tags: Linux
---


---

ssh登陆内网centos，在输入密码以后，密码验证的时间比较久（大约5秒左右），一般情况下应该是瞬间完成，最后确定是需要把ssh服务中的dns反解关闭。
当ssh到服务器ip时，系统会试图通过DNS反查相对应的域名，如果DNS中没有这个IP的域名解析，则会等到DNS查询超时才会进行下一步，所以浪费了时间，解决如下：

	vi /etc/ssh/sshd_config

注释掉：UseDNS no //默认为yes改为no

重启ssh服务。

还有个方法就是在服务器中不指定dns服务器。

	vi /etc/resolv.conf //注释掉所有配置行

另一种情况如下，我没遇到过，这个原因好像在ubuntu上容易出现（可能是个bug）：

	vi /etc/ssh/sshd_config

修改GSSAPIAuthentication参数为 no，默认是yes

GSSAPIAuthentication
Specifies whether user authentication based on GSSAPI is allowed.
The default is"no". Note that this option applies to protocol
version 2 only.

重启ssh服务。

	ssh -vvv root@172.17.1.8 //-vvv的参数可以查看ssh登录的过程。

在远程访问某些服务很慢的情况下，不妨去掉服务器dns试试。