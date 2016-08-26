---
layout: post
title: "iis webdeploy"
categories: 技术
tags: Windows
---


---
for IIS 6


	for %%i in (a,b,c) do echo updating %%i now ... ^
	&& "C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe" ^
	  -verb:sync ^
	  -source:runCommand="c:\windows\system32\iisapp.vbs /a BPReports /r",waitInterval=20000 ^
	  -dest:auto,computerName=%%i

	for %%i in (a,b,c) do echo updating %%i now ... ^
	&& "C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe" ^
	  -verb:sync ^
	  -source:package="\\aaa\DeployPackages\1.9_20120905_patch\BPReport\BpsReport-1.9.4631.4135.zip" ^
	  -dest:auto,computerName=%%i ^
	  -replace:objectName=filePath,match=-prod\.config$,replace=.config ^
	  -skip:objectName=filePath,absolutePath=.*-dev\.config$ ^
	  -skip:objectName=filePath,absolutePath=.*-qa\.config$ ^
	  -skip:objectName=filePath,absolutePath=.*-stg\.config$ ^
	  -skip:objectName=filePath,absolutePath=.*-uat\.config$ ^
	  -skip:objectName=filePath,absolutePath=.*-dallas\.config$ ^
	  -verbose


for IIS 7


	"C:\Program Files\IIS\Microsoft Web Deploy\msdeploy.exe" ^
	  -verb:sync ^
	  -source:runCommand="C:\Windows\SysWow64\inetsrv\appcmd.exe recycle APPPOOL BPReports",waitInterval=20000 ^
	  -dest:auto,computerName=aaa
	  
	for %%i in (a,b,c) do echo updating %%i now ... ^
	&& "C:\Program Files\IIS\Microsoft Web Deploy\msdeploy.exe" ^
	  -verb:sync ^
	  -source:package="\\aaa\DeployPackages\1.9_20120905_patch\BPReport\BpsReport-1.9.4631.4135.zip" ^
	  -dest:auto,computerName=%%i ^
	  -replace:objectName=filePath,match=-prod\.config$,replace=.config ^
	  -skip:objectName=filePath,absolutePath=.*-dev\.config$ ^
	  -skip:objectName=filePath,absolutePath=.*-qa\.config$ ^
	  -skip:objectName=filePath,absolutePath=.*-stg\.config$ ^
	  -skip:objectName=filePath,absolutePath=.*-uat\.config$ ^
	  -skip:objectName=filePath,absolutePath=.*-dallas\.config$ ^
	  -verbose  

