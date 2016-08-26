---
layout: post
title: "Github Gitcafe 在同一台机器设置SSH密钥"
categories: 技术
tags: Gitcafe
---


---

想想自己以前把博客同步到github和gitcafe不停地敲重复命令的方法就是醉了

我的机器是Windows7，对应的~/.ssh目录就是C:\Users\yourname\\.ssh

	cd C:\Users\yourname
	md .ssh
	cd .ssh

添加一个config文件并加入以下内容

	Host github.com
		User git
		Hostname github.com
		IdentityFile ~/.ssh/github
		TCPKeepAlive yes
		IdentitiesOnly yes
	Host gitcafe.com
		User git
		Hostname gitcafe.com
		IdentityFile ~/.ssh/gitcafe
		TCPKeepAlive yes
		IdentitiesOnly yes

生成新的SSH 秘钥

	ssh-keygen -t rsa -C "ajasonwang@gmail.com" -f gitcafe
	ssh-keygen -t rsa -C "ajasonwang@gmail.com" -f github
	
对于现在的 [coding.net](https://coding.net/)，直接不指定生成的文件名，用默认的名字id_rsa.pub就好了

1、用文本工具打开公钥文件gitcafe.pub ，复制里面的所有内容到剪贴板。

2、进入 GitCafe -->账户设置-->SSH 公钥管理设置项，点击添加新公钥 按钮，在 Title 文本框中输入任意字符。

3、在 Key 文本框粘贴刚才复制的公钥字符串，按保存按钮完成操作。

4、测试

	cd C:\Users\yourname\.ssh
	ssh -T git@gitcafe.com -i gitcafe


输出类似这样的提示：

	Hi yourname! You've successfully authenticated, but GitCafe does not provide shell access.

成功。

5、github同理

6、同时部署到github，gitcafe的命令和设置

	git push github master:master 
	git push gitcafe master:gitcafe-pages
	git push coding_net master:coding-pages
 
下面是我的git配置文件：

	[core]
		repositoryformatversion = 0
		filemode = false
		bare = false
		logallrefupdates = true
		symlinks = false
		ignorecase = true
		hideDotFiles = dotGitOnly

	[remote "gitcafe"]
		url = git@gitcafe.com:ajasonwang/ajasonwang.git
		fetch = +refs/heads/*:refs/remotes/gitcafe/*

	[remote "github"]
		url = git@github.com:ajasonwang/ajasonwang.github.io.git
		fetch = +refs/heads/*:refs/remotes/github/*

	[remote "coding_net"]
		url = git@git.coding.net:ajasonwang/ajasonwang.git
		fetch = +refs/heads/*:refs/remotes/coding_net/*
		
	[branch "master"]
		remote = github
		merge = refs/heads/master

