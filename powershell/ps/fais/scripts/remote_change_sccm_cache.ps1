Invoke-Command -ComputerName (Get-Content C:\scripts\data\sccmshort.txt) -ScriptBlock {
    $UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
    $Cache = $UIResourceMgr.GetCacheInfo()
    $CacheElements = $Cache.GetCacheElements()

    foreach ($Element in $CacheElements)
        {
            "Deleting CacheElement with PackageID $($Element.ContentID)"
            "in folder location $($Element.Location)"
            $Cache.DeleteCacheElement($Element.CacheElementID)
        }
    # Remove-Item C:\windows\ccmcache -Recurse -Force
    $CacheLocation = "D:\ccmcache"
    $Cache = gwmi -class CacheConfig -Namespace root\ccm\SoftMgmtAgent
    $Cache.Location = $CacheLocation
    $Cache.Put() | Out-Null
    Restart-Service -DisplayName 'SMS Agent Host' -Verbose

} -SessionOption (New-PSSessionOption -NoMachineProfile)