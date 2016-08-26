---
layout: post
title: "Azure上部署Jekyll blog的步骤"
categories: 技术
tags: azure
---


---

公司developer有MSDN Subscription的权限，于是每个月都有微软云服务Azure的赠送的50美金费用，具体优惠可以看这个 [链接](http://azure.microsoft.com/en-us/pricing/member-offers/msdn-benefits-details/)，之前一直想用这个福利做点什么,却一直不是很顺利，linux下搭建好的openvpn总是不能用（猜测应该是被GFW和谐了），Windows Server 2012下部署SSTP和L2TP VPN倒是成功翻墙，不过流量费耗的太快，50美金经不起折腾。

于是就想把博客再挪一个窝，现在做完了，记录以下步骤以备忘。博客地址：[该地址目前已关闭](http://ajasonwang.cloudapp.net)

1，安装Ubuntu 14.10虚拟机并配置Endpoint，我开了一系列端口方便管理

	adminui	TCP	2943	2943	-
	HTTP	TCP	80	80	-
	http8080	TCP	8080	8080	-
	HTTPS	TCP	443	443	-
	jekyll	TCP	4000	4000	-
	openvpn	TCP	2443	2443	-
	openvpnserver	TCP	3194	3194	-
	SSH	TCP	22	22	-
	webmin	TCP	10000	10000	-

2，安装环境依赖

	sudo apt-get update
	sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties

3，安装rvm，然后安装ruby

	sudo apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
	curl -L https://get.rvm.io | bash -s stable
	source ~/.rvm/scripts/rvm
	echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
	rvm install 2.1.2
	rvm use 2.1.2 --default
	ruby -v

	echo "gem: --no-ri --no-rdoc" > ~/.gemrc

4，安装Javascript runtime

	sudo add-apt-repository ppa:chris-lea/node.js
	sudo apt-get update
	sudo apt-get install nodejs

5，安装rails

	gem install rails
	rbenv rehash

	rails -v

6，配置github账户（这个之前早就搞定了）

	git config --global color.ui true
	git config --global user.name "YOUR NAME"
	git config --global user.email "YOUR@EMAIL.com"
	ssh-keygen -t rsa -C "YOUR@EMAIL.com"

	cat ~/.ssh/id_rsa.pub

	ssh -T git@github.com

7，安装apache

	sudo apt-get install apache

8，在apache的/var/www/html下直接clone静态网站

	cd /var/www/html; git clone https://github.com/xxx/xxx.github.io.git

9，启动apache就发现博客可以访问了，现在设置定时任务自动克隆代码更新博客

	#add crontab
	0 5,9 * * * rm -rf /tmp/xxx.github.io; cd /tmp; git clone https://github.com/xxx/xxx.github.io.git; mv /tmp/xxx.github.io/* /var/www/html/ -rf;

	#check cron service status
	initctl start cron
	initctl list | grep cron

Done.
