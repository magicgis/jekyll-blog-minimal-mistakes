---
layout: post
title: "linux tar 打包排除某些目录"
categories: 技术
tags: Linux
---


---

	tar -zcv --exclude='apache-tomcat-7.0.23/logs' -f apache-tomcat.tar.gz apache-tomcat-7.0.23/