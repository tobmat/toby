Invoke-Command -ComputerName (Get-Content C:\scripts\data\sccmshort.txt) -ScriptBlock { 

 # Remove-Item M:\windows\ccmcache -Recurse -Force
    $UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
    $Cache = $UIResourceMgr.GetCacheInfo()
    $env:COMPUTERNAME + ",    " + $Cache.Location.ToString()
    } -SessionOption (New-PSSessionOption -NoMachineProfile)