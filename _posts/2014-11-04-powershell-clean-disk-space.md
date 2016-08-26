---
layout: post
title: "powershell 清理磁盘空间"
categories: 技术
tags: Windows
---


---

	#$fileDirs = @("D:\Jenkins_Slave\bpjenkins81\workspace","D:\Jenkins_Slave\dpjenkins81\workspace")
	$fileDirs = $env:WORKSPACE
	$fileTypes=@(".obj",".pch")

	function fileManage
	{	
		foreach($fileDir in $fileDirs)
		{	
			if(!(Test-Path $fileDir)) 
			{continue;}
			else
			{
				foreach($fileType in $fileTypes)
				{
					$logFiles = Get-ChildItem -path $fileDir -Recurse|where-object { -not $_.PSIsContainer -and $_.extension -eq "$fileType"}
					
					foreach($logFile in $logFiles)
					{
						if($logFile -eq $Null){continue;}					
						else
						{
							Write-Host "Deleting $($logFile.fullname)"
							Remove-Item $logFile.fullname -Force
						}
					}#foreach
				}#foreach		
			}#else
		}
	}

	#__main__:
	fileManage
