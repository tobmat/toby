
<#                                                                                               

 Program Name : InventoryCollector.ps1
                                                                                              
 Original Author: Hamid Maddi  							                                    

 Release date: 12/27/2013
											                                                    
 Description:  This script will to collect and send inventory data to the ServersInventory database.
		                     
                                                                                            
Modifications:                                                                             
                                                                                           
Version	Date Modified		Modified By		Changes Made                                
--------------------------------------------------------------------------------------------
01	    12/27/2013		    Hamid Maddi		??????
--------------------------------------------------------------------------------------------
02      03/15/2014          Hamid Maddi

ServiceUpdate-
backupagent--
monitoringagent--
nic binding order-
productid-- 
RDPconfig--
languagepack--
ipv4routetable-
mpiopaths-
#>

#-------------------------------------------------------------------------------------------

# set global variables
$global:InventoryFolder = "C:\Inventory\"
$global:Logfile = "C:\Inventory\Log.log"

Function Get-MSI
{
  Try
   { 
    $ModulePath = "C:\Windows\system32\WindowsPowerShell\v1.0\Modules\MSI"
    $MSImoduleDeployed = $false
    if ((Test-Path $ModulePath) -and (Get-ChildItem "C:\Windows\system32\WindowsPowerShell\v1.0\Modules\MSI"  | Measure-Object -Sum Length).Count -eq 11)
        {
           $MSImoduleDeployed=$true
           LogEvent 1 "The MSI module was already loaded"
           return
        }

        if(!$MSImoduleDeployed)
          {
            #if($TestBabychef)
             #   {
                    # delete the directory if it is missing files and create a new one
                    if (Test-Path $ModulePath) 
                        {
                            Remove-Item $ModulePath -force -recurse
                            New-Item $ModulePath -Type Directory
                        }
                    else {New-Item $ModulePath -Type Directory}

                    $sources = @("http://172.31.63.29/ServersInventoryAPI1/resources/MSI/about_MSI.help.txt",
                                 "http://172.31.63.29/ServersInventoryAPI1/resources/MSI/Microsoft.Deployment.Compression.Cab.dll.txt",
                                 "http://172.31.63.29/ServersInventoryAPI1/resources/MSI/Microsoft.Deployment.Compression.dll.txt",
                                 "http://172.31.63.29/ServersInventoryAPI1/resources/MSI/Microsoft.Deployment.WindowsInstaller.dll.txt",
                                 "http://172.31.63.29/ServersInventoryAPI1/resources/MSI/Microsoft.Deployment.WindowsInstaller.Package.dll.txt",
                                 "http://172.31.63.29/ServersInventoryAPI1/resources/MSI/Microsoft.Tools.WindowsInstaller.PowerShell.dll.txt",
                                 "http://172.31.63.29/ServersInventoryAPI1/resources/MSI/Microsoft.Tools.WindowsInstaller.PowerShell.dll-Help.xml.txt",
                                 "http://172.31.63.29/ServersInventoryAPI1/resources/MSI/MSI.formats.ps1xml.txt",
                                 "http://172.31.63.29/ServersInventoryAPI1/resources/MSI/MSI.psd1.txt",
                                 "http://172.31.63.29/ServersInventoryAPI1/resources/MSI/MSI.psm1.txt",
                                 "http://172.31.63.29/ServersInventoryAPI1/resources/MSI/MSI.types.ps1xml.txt")

                    $destinations = @("$ModulePath\about_MSI.help",
                                      "$ModulePath\Microsoft.Deployment.Compression.Cab.dll",
                                      "$ModulePath\Microsoft.Deployment.Compression.dll",
                                      "$ModulePath\Microsoft.Deployment.WindowsInstaller.dll",
                                      "$ModulePath\Microsoft.Deployment.WindowsInstaller.Package.dll",
                                      "$ModulePath\Microsoft.Tools.WindowsInstaller.PowerShell.dll",
                                      "$ModulePath\Microsoft.Tools.WindowsInstaller.PowerShell.dll-Help.xml",
                                      "$ModulePath\MSI.formats.ps1xml",
                                      "$ModulePath\MSI.psd1",
                                      "$ModulePath\MSI.psm1",
                                      "$ModulePath\MSI.types.ps1xml")

        
                        #Download the chef installation package
                        For ($i=0;$i -lt 11; $i++) 
                            {
    	                        $wc = New-Object System.Net.WebClient
    	                        $wc.DownloadFile($sources[$i], $destinations[$i])
                            }
                LogEvent 1 "The MSI module was loaded successfully"
            #    }
            #else
            #    {
            #        LogEvent 0 "The MSI module was not loaded because the connection to $TestBabychef failed"
            #    }
           }
    }
          
    Catch 
        { 
            LogEvent 0 "an error occured while trying to load the MSI module: $_"
        }
        
}


Function Get-NetworkStatistics 
{
  Try
   { 
    $properties = 'Protocol','LocalAddress','LocalPort','RemoteAddress','RemotePort','State','ProcessName','PID' 
    
    netstat -ano | Select-String -Pattern '\s+(TCP|UDP)' | ForEach-Object {

        $item = $_.line.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)

        if($item[1] -notmatch "^\[::") 
        {            
          
            if (($la = $item[1] -as [ipaddress]).AddressFamily -eq "InterNetworkV6")
            { 
               $localAddress = $la.IPAddressToString 
               $localPort = $item[1].split("\]:")[-1] 
            } 
            else 
            { 
                $localAddress = $item[1].split(":")[0] 
                $localPort = $item[1].split(":")[-1] 
            } 
           
            if (($ra = $item[2] -as [ipaddress]).AddressFamily -eq "InterNetworkV6") 
            { 
               $remoteAddress = $ra.IPAddressToString 
               $remotePort = $item[2].split("\]:")[-1] 
            } 
            else 
            { 
               $remoteAddress = $item[2].split(":")[0] 
               $remotePort = $item[2].split(":")[-1] 
            } 

            New-Object PSObject -Property @{ 
                PID = $item[-1] 
                ProcessName = (Get-Process -Id $item[-1] -ErrorAction SilentlyContinue).Name 
                Protocol = $item[0] 
                LocalAddress = $localAddress 
                LocalPort = $localPort 
                RemoteAddress =$remoteAddress 
                RemotePort = $remotePort 
                State = if($item[0] -eq "tcp") {$item[3]} else {$null} 
            } | Select-Object -Property $properties 
            
        } 
    
    } 
     LogEvent 1 "Networkstatistics successfully collected"
     #return $RouteTable

  }

    Catch { LogEvent 0 "an error occured while trying to collect Networkstatistics: $_"}

}

Function Get-MPIOpaths
{ 
    $MPIOpaths = @()
    $mpio = (gwmi -Namespace root\wmi -Class mpio_disk_info).driveinfo | Select name, numberpaths
        
    foreach ($obj in $mpio) 
        {
            $MPIOpaths += New-Object PSObject -Property @{
    		              				                    Name = $obj.name
                                                            Numberpaths = $obj.numberpaths
                                                         }
        }
    return $MPIOpaths
}


Function Get-IPv4RouteTable
{
Try
  {
    $RouteTable = @()
    $rts = Get-WmiObject Win32_IP4PersistedRouteTable | Select-Object Destination, Mask, Nexthop, Metric1
    Foreach($rt in $rts)
     {
         $mt = ''
         If($rt.Metric1 -eq -1) {$mt='Default'} else {$mt=$rt.Metric1}
         $RouteTable += New-Object PSObject -Property @{
                                                         NetworkAddress = $rt.Destination
                            					         Netmask = $rt.Mask
                            					 		 GatewayAddress = $rt.Nexthop
                            					 		 Metric = $mt
                            						   } 
     }
      LogEvent 1 "RouteTable information successfully collected"
      return $RouteTable
  }

    Catch {LogEvent 0 "an error occured while trying to collect RouteTable information: $_"}

}

Function Get-RemoteDesktopConfig
{if ((Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server').fDenyTSConnections -eq 1)

          {$rdp="Don't allow connections to this computer"}

 elseif ((Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp').UserAuthentication -eq 1)
         {$rdp="Allow connections only from computers running RD with network level authentication"} 

 else     {$rdp="Allow connections from computers running any version of RD"}

 return $rdp
} 
Function Get-NICBinding
{ 
    $Binding = (Get-Itemproperty "HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Linkage").bind
    $NICs = Get-WmiObject -Class win32_networkadapter | where {$_.Netconnectionid -ne $null} | select NetCOnnectionID,GUID,NetEnabled
    $i = 1
    $NICbindingInfo = @()
    foreach ($obj in $Binding) {
     $GUID = $obj.trimstart("\Device\")
     $Data = ($NICs | where {$_.GUID -eq $GUID})
     If ($Data.NetConnectionID -eq $null){
     Continue
     }
      $NICbindingInfo += New-Object PSObject -Property @{
    						                          BindingOrder = $i
                                                      Name = $Data.NetConnectionID
                                                      NICenabled = $Data.NetEnabled
                                                      GUID = $Data.GUID }
      $i++
    }
return $NICbindingInfo
}


Function Get-PageFile
{
 Try
   {
    $PageFile = @()
    $pf = get-wmiobject -class "Win32_PageFile" -namespace "root\CIMV2"
    Foreach($f in $pf)
       {
         if($f.InstallDate)  {$ID = ([wmi]'').ConvertToDateTime($f.InstallDate)  } else {$ID=''}
         if($f.LastAccessed) {$LA = ([wmi]'').ConvertToDateTime($f.LastAccessed) } else {$LA=''}
         if($f.LastModified) {$LM = ([wmi]'').ConvertToDateTime($f.LastModified) } else {$LM=''}
         if($f.FileSize -gt 0) {$FS = [math]::round($f.FileSize /1024/1024)} else {$FS = ''}
         $PageFile +=  New-Object PSObject -Property @{
                                                        Name = $f.Name
                                                        FileSize = $FS
                                                        FileType = $f.FileType
                                                        Compressed = $f.Compressed
                                                        CompressionMethod = $f.CompressionMethod
                                                        Encrypted = $f.Encrypted
                                                        EncryptionMethod = $f.EncryptionMethod
                                                        Hidden = $f.Hidden
                                                        InstallDate = $ID
                                                        LastAccessed = $LA
                                                        LastModified = $LM}
    }
    LogEvent 1 "PageFile information successfully collected"
    return $PageFile
  }

    Catch {LogEvent 0 "an error occured while trying to collect PagrFile information: $_"}

}

Function Get-WUSettings {
               
 try  
   {  
    # Initialize object            
    $WshShell = New-Object -ComObject Wscript.Shell            
    $polkey  = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
    $stdkey  = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update'            
    
        try { 
                $AUEnabled = $WshShell.RegRead("$polkey\NoAutoUpdate")
            } catch {            
               # if this value is absent, it means it's turned on            
               $AUEnabled = 0 }            
        Switch ($AUEnabled) 
            {            
                1 {$AUEnabled = $false}            
                0 {$AUEnabled = $true }            
            }
            
        try {
                $Detect_LastSuccessTime = $WshShell.RegRead("$stdkey\Results\Detect\LastSuccessTime") 
            } catch 
            {            
                # if this value is absent, it means it's turned off            
            $Detect_LastSuccessTime = '' 
            }
        
        try {            
                $Download_LastSuccessTime = $WshShell.RegRead("$stdkey\Results\Download\LastSuccessTime")            
            } catch {            
            # if this value is absent, it means it's turned off           
            $Download_LastSuccessTime = '' }

        try {            
                $Install_LastSuccessTime = $WshShell.RegRead("$stdkey\Results\Install\LastSuccessTime")            
            } catch {            
            # if this value is absent, it means it's turned off           
            $Install_LastSuccessTime = '' }

        try {            
                $DetectionFrequency = $WshShell.RegRead("$polkey\DetectionFrequency")            
            } catch {            
                    # if this value is absent, it means it's turned on            
                    $DetectionFrequency = 0
                    }
        try {            
                $AUOptions = $WshShell.RegRead("$polkey\AUOptions")
            } catch {            
        
        try {            
                $AUOptions = $WshShell.RegRead("$stdkey\AUOptions")
                $regResult = $true            
            } catch {            
                $AUOptions = 0            
            }            
        }            
        Switch ($AUOptions) {            
            0 {$AUNotificationLevel = '0 - Not Configured'}            
            1 {$AUNotificationLevel = '1 - Never check for updates'}            
            2 {$AUNotificationLevel = '2 - Notify for download and notify for installation'}            
            3 {$AUNotificationLevel = '3 - Auto download and notify for installation'}            
            4 {$AUNotificationLevel = '4 - Auto download and schedule install'}            
        }            
        
       try {            
            $UseWUServerVal = $WshShell.RegRead("$polkey\UseWUServer")            
        } catch {            
            # if the value doesn't exist, it means that we don't use a WSUS server            
            $UseWUServerVal = 0            
        }            
        Switch ($UseWUServerVal) {            
            1 {$UseWUServer = $true}            
            0 {$UseWUServer = $false }            
        }            
        # Create a default object with a subset of properties
        $obj = New-Object -TypeName psobject -Property @{            
            'AutomaticUpdateEnabled' = $AUEnabled            
            'UseWSUSserver' = $UseWUServer            
            'AutomaticUpdatesNotification' = $AUNotificationLevel;
            'DetectionFrequency' = $DetectionFrequency;
            'DetectLastSuccessTime' = $Detect_LastSuccessTime;
            'DownloadLastSuccessTime' = $Download_LastSuccessTime;
            'InstallLastSuccessTime' = $Install_LastSuccessTime;
        }            
            try {            
                $ScheduledInstallDay  = $WshShell.RegRead("$polkey\ScheduledInstallDay")            
                $ScheduledInstallTime = $WshShell.RegRead("$polkey\ScheduledInstallTime")            
            } catch {            
                try {            
                    $ScheduledInstallDay  = $WshShell.RegRead("$stdkey\ScheduledInstallDay")            
                    $ScheduledInstallTime = $WshShell.RegRead("$stdkey\ScheduledInstallTime")            
                } catch {            
                    # Absent = Every Day @3 AM but I prefer to leave it blank in the returned object            
                }            
            }            
            Switch ($ScheduledInstallDay) {            
                0 {$InstallDay = '0 - Every Day'}            
                1 {$InstallDay = '1 - Every Sunday'}            
                2 {$InstallDay = '2 - Every Monday'}            
                3 {$InstallDay = '3 - Every Tuesday'}            
                4 {$InstallDay = '4 - Every Wednesday'}            
                5 {$InstallDay = '5 - Every Thursday'}            
                6 {$InstallDay = '6 - Every Friday'}            
                7 {$InstallDay = '7 - Every Saturday'}            
            }            
            if ($ScheduledInstallTime) {            
                $InstallTime = New-TimeSpan -Hours $ScheduledInstallTime            
            }            
            $obj | Add-Member -MemberType NoteProperty -Name 'InstallFrequency' -Value $InstallDay            
            $obj | Add-Member -MemberType NoteProperty -Name 'InstallTime' -Value $InstallTime            

          try {            
            $WUServer = $WshShell.RegRead('HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\WUServer')            
        } catch {            
                    # if this value is absent, it means it's turned on            
                    $WUServer = ''
                }
          try {            
            $WUStatusServer =  $WshShell.RegRead('HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\WUStatusServer')
        } catch {            
                    # if this value is absent, it means it's turned on            
                    $WUStatusServer = ''
                }
          try {            
            $TargetGroup =  $WshShell.RegRead('HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\TargetGroup')            
        } catch {            
                    # if this value is absent, it means it's turned on            
                    $TargetGroup = ''
                }
         try {            
            $TargetGroupEnabled =  $WshShell.RegRead('HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\TargetGroupEnabled')
            Switch ($TargetGroupEnabled) {            
                1 {$TargetGroupEnabled = $true}            
                0 {$TargetGroupEnabled = $false}}
        } catch {            
                    # if this value is absent, it means it's turned on            
                    $TargetGroupEnabled = ''
                }
        $obj | Add-Member -MemberType NoteProperty -Name 'WSUSserver' -Value $WUServer            
        $obj | Add-Member -MemberType NoteProperty -Name 'WSUSstatusURL' -Value $WUStatusServer 
        $obj | Add-Member -MemberType NoteProperty -Name 'TargetGroupEnabled' -Value $TargetGroupEnabled
        $obj | Add-Member -MemberType NoteProperty -Name 'TargetGroup' -Value $TargetGroup
                   
        try {            
            $OptinGUID = $WshShell.RegRead('HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\DefaultService')            
        } catch {            
            # Fail silently            
        }            
        if ($OptinGUID -eq '7971f918-a847-4430-9279-4a52d1efe18d') {            
            $obj | Add-Member -MemberType NoteProperty -Name "OptedinMicrosoftUpdate" -Value $true            
        } else {            
            $obj | Add-Member -MemberType NoteProperty -Name "OptedinMicrosoftUpdate" -Value $false            
        }            
      LogEvent 1 "Windows Update settings collected successfully"  
      return $obj 
    }  
          
   catch 
   {  
    LogEvent 0 "An error occured while trying to collect Windows Update settings: $_"
   }   
       
} 

Function Upload-File($uri,$filepath)  
 {  
   $wc = New-Object System.Net.WebClient  
   try  
   {  
     $wc.uploadFile($uri,$filepath)
     LogEvent 1 "The Inventory XML file was uploaded successfully"
   }  
   catch [System.Net.WebException]  
   {  
    LogEvent 0 "An error occured while trying to upload the inventory file: System.Net.WebException"
   }   
   finally  
   {    
     $wc.Dispose()  
   }  
 }  

Function Get-Services
{
Try
  {
    $Services = @()
    $srvcs = Get-WmiObject win32_service | select Name, Status,PathName, ServiceType, StartMode, AcceptPause, AcceptStop, Description, DisplayName, ProcessId,Started,StartName,State, Path
    #$srvcs = Get-Service |select Name, RequiredServices, CanPauseAndContinue, CanShutdown, CanStop, DisplayName, DependentServices, ServiceHandle, Status, ServiceType | Sort-Object Name
    Foreach($srvc in $srvcs)
     {
         $Services += New-Object PSObject -Property @{
                                                        Name = $srvc.Name
                            							Status = $srvc.Status
                            							PathName = $srvc.PathName
                            							ServiceType = $srvc.ServiceType
                            							StartMode = $srvc.StartMode
                            							AcceptPause = $srvc.AcceptPause
                            							AcceptStop = $srvc.AcceptStop
                            							Description = $srvc.Description
                            							DisplayName = $srvc.DisplayName
                            							ProcessId = $srvc.ProcessId
                            							Started = $srvc.Started
                            							StartName = $srvc.StartName
                            							State = $srvc.State
                            							Path = $srvc.Path
						    } 
     }
      LogEvent 1 "Services information successfully collected"
      return $Services
  }

    Catch {LogEvent 0 "an error occured while trying to collect Services information: $_"}

}


Function Get-FeaturesRoles
{
  Try
    {
    $f = get-wmiobject win32_ServerFeature | Select Name | Sort-Object Name
    #Import-module servermanager ; 
    #$f = Get-WindowsFeature | where-object {$_.Installed -eq $True} | select DisplayName | Sort-Object DisplayName
    return $f
    }
  Catch{}
}

Function Get-SystemIPAddress()
    {
     Try
        {
          $str = ping $env:computername -4
          $IPregex=‘(?<Address>((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))’
          If ($str[1] -Match $IPregex) {$Matches.Address}

        }
     Catch {LogEvent 0 "an error occured while trying to collect pending reboot information: $_"}
    }

Function Get-SEPinformation
{
    $SEPinformation=@()
    $ErrorActionPreference = "SilentlyContinue"
    $isSEPinstalled=$false
    $sep = GP HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |Select DisplayName, DisplayVersion, InstallDate, UninstallString  | where {$_.DisplayName -like "Symantec Endpoint Protection"}

    If($sep)
    {
      if ($sep.DisplayVErsion.Substring(0,2) -eq "11")
        {
         $def = get-item "C:\ProgramData\Symantec\Definitions\VirusDefs\definfo.dat"
        }
      elseif ($sep.DisplayVErsion.Substring(0,2) -eq "12")
        {  
         $def = get-item "C:\ProgramData\Symantec\Symantec Endpoint Protection\12.1.2015.2015.105\Data\Definitions\VirusDefs\definfo.dat"
        }
        
      $ws=$sep.InstallDate
      $id= $ws.Substring(4,2) +'/'+$ws.Substring(6,2) +'/'+$ws.Substring(0,4)
       
      $SEPinformation += New-Object PSObject -Property @{
                                                           isInstalled = $true
                                                           Version = $sep.DisplayVersion
                                                           InstallDate = [datetime]$id
                                                           UninstallString = $sep.UninstallString
                                                           LatestDefinition = [datetime]$def.lastWriteTime }
    }
    else
    {
      $SEPinformation += New-Object PSObject -Property @{
                                                         isInstalled = $false
                                                         Version = $null
                                                         InstallDate = $null
                                                         UninstallString = $null
                                                         LatestDefinition = $null}
    
    }
    return $SEPinformation
 }

Function LogEvent ([int]$event_id,$message)
 {
 Try
   {
    switch ($event_id) 
    { 
        0 {$event="FAILURE"} 
        1 {$event="SUCCESS"} 
    }

    $date= Get-Date
    Add-Content  $Logfile "$date    $event    $message"
    }
 Catch
    {
     "an error occured while trying to write to the event log C:\windows\ServerInfo.log: $_"
    }
 }
 
 
Function Get-WSUSsync
{
 Try
   {
    $log="C:\Windows\WindowsUpdate.log"
    If(Test-Path $log)
      {
        $wsus_sync=Select-String $log -pattern "Synchronizing server updates" | Select-Object -Last 1
        $ws=$wsus_sync.Line.substring(0,10)
        $ws1= $ws.Substring(5,2) +'/'+$ws.Substring(8,2) +'/'+$ws.Substring(0,4)
        $wsus_sync = $ws1
      }
    else 
      {
        $wsus_sync = "Log file missing: $log"
      }
    LogEvent 1 "Windows update information successfully collected"
    return $wsus_sync
   }
 Catch
   {
    Catch {LogEvent 0 "an error occured while trying to collect windows update information: $_"}
   }

}


Function Get-InstalledUpdates
{
Try
  {
    $InstalledUpdates=@()
    $temp=@()
    # Windows update agent
    $Session = New-Object -ComObject "Microsoft.Update.Session"
    $Searcher = $Session.CreateUpdateSearcher()
    $historyCount = $Searcher.GetTotalHistoryCount()
    $Updates=$Searcher.QueryHistory(0, $historyCount) | Select-Object Title, Description, Date |Where-Object {$_.title -NotLike "*Definistion*"} | Sort-Object $_.Date
    Foreach($upd in $Updates)
     {
        $temp += ExtractKB($upd.title)
        $InstalledUpdates += New-Object PSObject -Property @{
                                            HotfixID = ExtractKB($upd.title)
                                            Title = $upd.Title
                                            InstallDate = $upd.date}
     }
     # WMI
     $UpdatesWMI =  get-wmiobject Win32_QuickFixEngineering |select hotfixid, Installedon, Description
     Foreach($WMIupd in $UpdatesWMI)
     {
           If ($temp -notcontains $WMIupd.HotFixID)
           {
           $InstalledUpdates += New-Object PSObject -Property @{
                                            HotfixID = $WMIupd.HotFixID
                                            Title = $WMIupd.Description
                                            InstallDate = $WMIupd.InstalledOn} 
           }
     }
     
    LogEvent 1 "Installed updates information successfully collected"
    return $InstalledUpdates
  }    
    Catch {
             $InstalledUpdates += New-Object PSObject -Property @{
                                            HotfixID = 'Error'
                                            Title = $_} 
             return $InstalledUpdates
             LogEvent 0 "an error occured while trying to collect installed updates information: $_"
          }

}


Function Get-InstalledApplications
{
Try
  {
    $applications = @()
    $apps=Get-WmiObject -Class Win32_Product |select name,version,vendor,installdate | Sort-Object name

    Foreach ($app in $apps)
    {
        $d=$app.InstallDate
        if(!$d) 
            {$d=""} 
        else 
            {$d=($app.installdate).Substring(4,2)+'/'+($app.Installdate).Substring(6,2)+'/'+$d.Substring(0,4)}
    
        if ($app.name)
           { 
            $applications += New-Object PSObject -Property @{
                                                              Name = $app.Name
                                                              Version = $app.Version
                                                              ServiceUpdate = (($app.Version).Split('.'))[1]
                                                              Vendor = $app.vendor
                                                              InstallDate= $d }
           }

    }
    LogEvent 1 "Installed applications information collected successfully"
    return $applications
  }
    Catch {LogEvent 0 "an error occured while collecting installed applications: $_"}
}


Function Get-PendingUpdates
{
Try
   {
    $Result = @() 
    $ErrorActionPreference = “SilentlyContinue”  
    $UpdateSession = New-Object -com Microsoft.Update.Session	
    $UpdateSearcher = $UpdateSession.CreateupdateSearcher()	
    $SearchResult =  $UpdateSearcher.Search("IsHidden=0 and IsInstalled=0")	
    $NeededUpdates = $searchResult.Updates

    Foreach ($update in $NeededUpdates)
       {
        $Result += New-Object PSObject -Property @{ 
                        Title=$update.Title
                        HotFixID="KB"+$update.KBArticleIDs
                        ReleaseDate= '{0:MM/dd/yyyy}' -f $update.LastDeploymentChangeTime
                        Severity=$update.MsrcSeverity } 
        } 
        LogEvent 1 "Pending update information successfully collected"
        return $Result
    }
 Catch {
         $Result += New-Object PSObject -Property @{ 
                        Title=$_
                        HotFixID="Error"
                        ReleaseDate= ''
                        Severity='' } 
         return $Result
         LogEvent 0 "an error occured while trying to collect pending updates information: $_"}
}


Function ExtractKB ([string]$str)
{
Try
  {
    #$a=$str -match "kb?\d+" 
    #$matches.Values[0]
    $k="N/A"
    If ($str.IndexOf("(KB") -gt 0) 
      {
       $pos1=$str.IndexOf("(KB")
       $pos2=$str.IndexOf(")")
       $k=$str.Substring($pos1+1,$pos2-$pos1-1)
      }
   return $k
   }

Catch {return "N/A"}

}

Function Get-PendingReboot 
{ 
 $Computer=$env:COMPUTERNAME
 
  Try 
    { 
      # Setting pending values to false to cut down on the number of else statements 
      $PendFileRename,$Pending,$SCCM = $false,$false,$false 
                         
      # Setting CBSRebootPend to null since not all versions of Windows has this value 
      $CBSRebootPend = $null 
             
      # Querying WMI for build version 
      $WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -Property BuildNumber, CSName -ComputerName $Computer 
 
      # Making registry connection to the local/remote computer 
      $RegCon = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"LocalMachine",$Computer) 
             
      # If Vista/2008 & Above query the CBS Reg Key 
      If ($WMI_OS.BuildNumber -ge 6001) 
        { 
          $RegSubKeysCBS = $RegCon.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\").GetSubKeyNames() 
          $CBSRebootPend = $RegSubKeysCBS -contains "RebootPending" 
        }#End If ($WMI_OS.BuildNumber -ge 6001) 
               
      # Query WUAU from the registry 
      $RegWUAU = $RegCon.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\") 
      $RegWUAURebootReq = $RegWUAU.GetSubKeyNames() 
      $WUAURebootReq = $RegWUAURebootReq -contains "RebootRequired" 
             
      # Query PendingFileRenameOperations from the registry 
      $RegSubKeySM = $RegCon.OpenSubKey("SYSTEM\CurrentControlSet\Control\Session Manager\") 
      $RegValuePFRO = $RegSubKeySM.GetValue("PendingFileRenameOperations",$null) 
             
      # Closing registry connection 
      $RegCon.Close() 
             
       # If PendingFileRenameOperations has a value set $RegValuePFRO variable to $true 
       If ($RegValuePFRO) 
         { 
            $PendFileRename = $true 
         }#End If ($RegValuePFRO) 
 
       # Determine SCCM 2012 Client Reboot Pending Status 
       # To avoid nested 'if' statements and unneeded WMI calls to determine if the CCM_ClientUtilities class exist, setting EA = 0 
       $CCMClientSDK = $null 
       $CCMSplat = @{ 
                     NameSpace='ROOT\ccm\ClientSDK' 
                     Class='CCM_ClientUtilities' 
                     Name='DetermineIfRebootPending' 
                     ComputerName=$Computer 
                     ErrorAction='SilentlyContinue' 
                     } 
       $CCMClientSDK = Invoke-WmiMethod @CCMSplat 
       If ($CCMClientSDK) 
         { 
            If ($CCMClientSDK.ReturnValue -ne 0) 
              { 
                Write-Warning "Error: DetermineIfRebootPending returned error code $($CCMClientSDK.ReturnValue)" 
              }#End If ($CCMClientSDK -and $CCMClientSDK.ReturnValue -ne 0) 
  
                  If ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending) 
                    { 
                      $SCCM = $true 
                    }#End If ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending) 
 
         }#End If ($CCMClientSDK) 
        Else 
          { 
           $SCCM = $null 
          }                         
                         
        # If any of the variables are true, set $Pending variable to $true 
        If ($CBSRebootPend -or $WUAURebootReq -or $SCCM -or $PendFileRename) 
          { 
            $Pending = $true 
          }#End If ($CBS -or $WUAU -or $PendFileRename) 
               
    LogEvent 1 "Pending reboot information successfully collected"
    return $pending
   }

   Catch {LogEvent 0 "an error occured while trying to collect pending reboot information: $_"}
   
}


Function Get-SystemUpTime()
{
Try
   {
    $OperatingSystem = Get-WmiObject Win32_OperatingSystem -ErrorAction SilentlyContinue 
    $Uptime = (Get-Date) - [System.Management.ManagementDateTimeconverter]::ToDateTime( $OperatingSystem.LastBootUpTime) 
    $d = $Uptime.Days 
    $h = $Uptime.Hours 
    $m = $uptime.Minutes 
     
    "{0}:{1}:{2}" -f $d,$h,$m
    LogEvent 1 "System uptime successfully collected"
    }
Catch {LogEvent 0 "an error occured while trying to getsystemuptime: $_"}

}


Function Get-Disks
{
    Try
      {    
          $WMI_DiskPartProps    = @('DiskIndex','Index','Name','DriveLetter','Caption','Capacity','FreeSpace','SerialNumber') 
          $WMI_DiskVolProps     = @('Name','DriveLetter','Caption','Capacity','FreeSpace','SerialNumber') 
          $WMI_DiskMountProps   = @('Name','Label','Caption','Capacity','FreeSpace','Compressed','PageFilePresent','SerialNumber') 
          $WMI_DiskDriveProps   = @('Name','Model','SerialNumber', 'DeviceID') 
                     
          # WMI data 
          $wmi_diskdrives = Get-WmiObject  -Class Win32_DiskDrive | select $WMI_DiskDriveProps
          $wmi_mountpoints = Get-WmiObject -Class Win32_Volume -Filter "DriveType=3 AND DriveLetter IS NULL" | select $WMI_DiskMountProps 
                    
          $AllDisks = @() 
          
          # Disks
          foreach ($diskdrive in $wmi_diskdrives)  
                    { 
                      $partitionquery = "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($diskdrive.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition" 
                      $partitions = @(Get-WmiObject -Query $partitionquery) 
                        foreach ($partition in $partitions) 
                         { 
                            $logicaldiskquery = "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($partition.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition" 
                            $logicaldisks = @(Get-WmiObject -Query $logicaldiskquery) 
                            
                            foreach ($logicaldisk in $logicaldisks) 
                             { 
                              $diskprops = @{ 
                                         Disk = $diskdrive.Name 
                                         Model = $diskdrive.Model 
                                         Partition = $partition.Name 
                                         Description = $partition.Description 
                                         PrimaryPartition = $partition.PrimaryPartition 
                                         VolumeName = $logicaldisk.VolumeName 
                                         Drive = $logicaldisk.Name 
                                         DiskSize = ([decimal]::round($logicaldisk.Size/1GB))
                                         FreeSpace = ([decimal]::round($logicaldisk.FreeSpace/1GB))
                                         PercentageFree = [math]::round((($logicaldisk.FreeSpace/$logicaldisk.Size)*100), 2) 
                                         DiskType = 'Partition' 
                                         SerialNumber = $diskdrive.SerialNumber}
                             $AllDisks += New-Object psobject -Property $diskprops                                          
                            } 
                          } 
                    } 
                    LogEvent 1 "Disk information successfully collected"         
                    return $AllDisks
       }

    Catch 
       {
           LogEvent 0 "an error occured while trying to collect Disk information: $_"
       }
}


Function Get-NetworkAdapterConfiguration
{
 
 Try
  {
    $NetworkConfig=@()
    $r= Get-WmiObject Win32_NetworkAdapterConfiguration | SELECT DefaultIPGateway, Description, DHCPEnabled, DHCPServer, DNSDomain, DNSDomainSuffixSearchOrder, DNSEnabledForWINSResolution, DNSServerSearchOrder, DomainDNSRegistrationEnabled, FullDNSRegistrationEnabled, Index, IPAddress, IPConnectionMetric, IPSubnet, IPEnabled, IPXAddress, IPXEnabled, MACAddress, ServiceName, SettingId, TCPIPNetBIOSOptions, WINSEnableLMHostsLookup, WINSPrimaryServer, WINSSecondaryServer
    
   Foreach ($a in $r)
    {
     $NetworkConfig += New-Object PSObject -Property @{
                                            DefaultIPGateway  = [String]$a.DefaultIPGateway
                                            Description  = $a.Description 
                                            DHCPEnabled  = $a.DHCPEnabled 
                                            DHCPServer  = $a.DHCPServer 
                                            DNSDomain  = $a.DNSDomain 
                                            DNSDomainSuffixSearchOrder  = [String]$a.DNSDomainSuffixSearchOrder 
                                            DNSEnabledForWINSResolution  = $a.DNSEnabledForWINSResolution 
                                            DNSServerSearchOrder  = [String]$a.DNSServerSearchOrder 
                                            DomainDNSRegistrationEnabled  = $a.DomainDNSRegistrationEnabled 
                                            FullDNSRegistrationEnabled  = $a.FullDNSRegistrationEnabled 
                                            Index  = $a.Index 
                                            IPAddress  = [String]$a.IPAddress
                                            IPConnectionMetric  = $a.IPConnectionMetric 
                                            IPSubnet  = [String]$a.IPSubnet 
                                            IPEnabled  = $a.IPEnabled 
                                            IPXAddress  = $a.IPXAddress 
                                            IPXEnabled  = $a.IPXEnabled 
                                            MACAddress  = $a.MACAddress 
                                            ServiceName  = $a.ServiceName 
                                            SettingId  = $a.SettingId.Substring(1,$a.SettingID.Length-2) 
                                            TCPIPNetBIOSOptions  = $a.TCPIPNetBIOSOptions 
                                            WINSEnableLMHostsLookup  = $a.WINSEnableLMHostsLookup 
                                            WINSPrimaryServer  = $a.WINSPrimaryServer 
                                            WINSSecondaryServer = $a.WINSSecondaryServer }
    }
    LogEvent 1 "The NetworkAdapterConfiguration information successfully collected"
    return $NetworkConfig
  }

    Catch {LogEvent 0 "an error occured while trying to collect NetworkAdapterConfiguration information: $_"}

}


Function Get-Processors
{
 Try
  {
   
    $cpuArchitectures = DATA {
    ConvertFrom-StringData -StringData @’
         0 = x86
         1 = MIPS
         2 = Alpha
         3 = PowerPC
         6 = ia64
         9 = x64
‘@ }
 $cpuFamilies = DATA {
    ConvertFrom-StringData -StringData @’
        1 = Other
        2 = Unknown
        3 = 8086
        4 = 80286
        5 = 80386
        6 = 80486
        7 = 8087
        8 = 80287
        9 = 80387
        10 = 80487
        11 = Pentium(R) brand
        12 = Pentium(R) Pro
        13 = Pentium(R) II
        14 = Pentium(R) processor with MMX(TM) technology
        15 = Celeron(TM)
        16 = Pentium(R) II Xeon(TM)
        17 = Pentium(R) III
        18 = M1 Family
        19 = M2 Family
        24 = K5 Family
        25 = K6 Family
        26 = K6=2
        27 = K6=3
        28 = AMD Athlon(TM) Processor Family
        29 = AMD(R) Duron(TM) Processor
        30 = AMD29000 Family
        31 = K6=2+
        32 = Power PC Family
        33 = Power PC 601
        34 = Power PC 603
        35 = Power PC 603+
        36 = Power PC 604
        37 = Power PC 620
        38 = Power PC X704
        39 = Power PC 750
        48 = Alpha Family
        49 = Alpha 21064
        50 = Alpha 21066
        51 = Alpha 21164
        52 = Alpha 21164PC
        53 = Alpha 21164a
        54 = Alpha 21264
        55 = Alpha 21364
        64 = MIPS Family
        65 = MIPS R4000
        66 = MIPS R4200
        67 = MIPS R4400
        68 = MIPS R4600
        69 = MIPS R10000
        80 = SPARC Family
        81 = SuperSPARC
        82 = microSPARC II
        83 = microSPARC IIep
        84 = UltraSPARC
        85 = UltraSPARC II
        86 = UltraSPARC IIi
        87 = UltraSPARC III
        88 = UltraSPARC IIIi
        96 = 68040
        97 = 68xxx Family
        98 = 68000
        99 = 68010
        100 = 68020
        101 = 68030
        112 = Hobbit Family
        120 = Crusoe(TM) TM5000 Family
        121 = Crusoe(TM) TM3000 Family
        122 = Efficeon(TM) TM8000 Family
        128 = Weitek
        130 = Itanium(TM) Processor
        131 = AMD Athlon(TM) 64 Processor Family
        132 = AMD Opteron(TM) Family
        144 = PA=RISC Family
        145 = PA=RISC 8500
        146 = PA=RISC 8000
        147 = PA=RISC 7300LC
        148 = PA=RISC 7200
        149 = PA=RISC 7100LC
        150 = PA=RISC 7100
        160 = V30 Family
        176 = Pentium(R) III Xeon(TM)
        177 = Pentium(R) III Processor with Intel(R) SpeedStep(TM) Technology
        178 = Pentium(R) 4
        179 = Intel(R) Xeon(TM)
        180 = AS400 Family
        181 = Intel(R) Xeon(TM) processor MP
        182 = AMD AthlonXP(TM) Family
        183 = AMD AthlonMP(TM) Family
        184 = Intel(R) Itanium(R) 2
        185 = Intel Pentium M Processor
        190 = K7
        200 = IBM390 Family
        201 = G4
        202 = G5
        203 = G6
        204 = z/Architecture base
        250 = i860
        251 = i960
        260 = SH=3
        261 = SH=4
        280 = ARM
        281 = StrongARM
        300 = 6x86
        301 = MediaGX
        302 = MII
        320 = WinChip
        350 = DSP
        500 = Video Processor
‘@ }
         
    $Processors = @()
    Get-WmiObject Win32_Processor | SELECT DeviceID, Status, AddressWidth, DataWidth, ExtClock, L2CacheSize, MaxClockSpeed, Revision, SocketDesignation, 
                                           @{Name = "Architecture"; Expression = {$cpuArchitectures["$($_.Architecture)"]}}, CurrentClockSpeed, Description, 
                                           @{Name = "Family"; Expression = {$cpuFamilies["$($_.Family)"]}}, Manufacturer, Name, NumberOfCores, ProcessorId | ForEach-Object {
                                    $Processors += New-Object PSObject -Property @{
                                                                                    DeviceID = $_.DeviceID
	                                                                                Name = $_.Name
	                                                                                Description = $_.Description 
	                                                                                Manufacturer = $_.Manufacturer 
	                                                                                Family = $_.Family
	                                                                                ProcessorId = $_.ProcessorId 
	                                                                                Status = $_.Status
	                                                                                AddressWidth = $_.AddressWidth 
	                                                                                DataWidth = $_.DataWidth 
	                                                                                ExtClock = $_.ExtClock 
	                                                                                L2CacheSize = $_.L2CacheSize 
	                                                                                MaxClockSpeed = $_.MaxClockSpeed 
	                                                                                Revision = $_.Revision 
	                                                                                SocketDesignation = $_.SocketDesignation 
	                                                                                Architecture = $_.Architecture 
	                                                                                CurrentClockSpeed = $_.CurrentClockSpeed 
	                                                                                NumberOfCores = $_.NumberOfCores }}
    LogEvent 1 "Processor information successfully collected"
    return $Processors
  }
 
    Catch {LogEvent 0 "an error occured while trying to collect processor information: $_"}
 }


function Get-ActivationStatus {
[CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$DNSHostName = $Env:COMPUTERNAME
    )
    process {
        try {
            $wpa = Get-WmiObject SoftwareLicensingProduct -ComputerName $DNSHostName `
            -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'" `
            -Property LicenseStatus -ErrorAction Stop
        } catch {
            $status = New-Object ComponentModel.Win32Exception ($_.Exception.ErrorCode)
            $wpa = $null    
        }
        $out = New-Object psobject -Property @{
            ComputerName = $DNSHostName;
            Status = [string]::Empty;
        }
        if ($wpa) {
            :outer foreach($item in $wpa) {
                switch ($item.LicenseStatus) {
                    0 {$out.Status = "Unlicensed"}
                    1 {$out.Status = "Licensed"; break outer}
                    2 {$out.Status = "Out-Of-Box Grace Period"; break outer}
                    3 {$out.Status = "Out-Of-Tolerance Grace Period"; break outer}
                    4 {$out.Status = "Non-Genuine Grace Period"; break outer}
                    5 {$out.Status = "Notification"; break outer}
                    6 {$out.Status = "Extended Grace"; break outer}
                    default {$out.Status = "Unknown value"}
                }
            }
        } else {$out.Status = $status.Message}
        $out
    }
}


Function Get-OperatingSystem
{
 Try
  {
 $ProductTypes = @('Other','Work Station', 'Domain Controller', 'Server')

    $DebugInfoType = @('0 - None', '1 - Complete memory dump', '2 - Kernel memory dump', '3 - Small memory dump')
   
    $SKUs = @("Undefined","Ultimate Edition","Home Basic Edition","Home Basic Premium Edition","Enterprise Edition"
             ,"Home Basic N Edition","Business Edition","Standard Server Edition","DatacenterServer Edition","Small Business Server Edition"
             ,"Enterprise Server Edition","Starter Edition","Datacenter Server Core Edition","Standard Server Core Edition"
             ,"Enterprise ServerCoreEdition","Enterprise Server Edition for Itanium-Based Systems","Business N Edition","Web Server Edition"
             ,"Cluster Server Edition","Home Server Edition","Storage Express Server Edition","Storage Standard Server Edition"
             ,"Storage Workgroup Server Edition","Storage Enterprise Server Edition","Server For Small Business Edition","Small Business Server Premium Edition") 
    
    $ostypes = @('0 (0x0) Unknown','1 (0x1) Other','2 (0x2) MACROS','3 (0x3) ATTUNIX','4 (0x4) DGUX','5 (0x5) DECNT','6 (0x6) Digital UNIX','7 (0x7) OpenVMS'
    ,'8 (0x8) HPUX','9 (0x9) AIX','10 (0xA) MVS','11 (0xB) OS400','12 (0xC) OS/2','13 (0xD) JavaVM','14 (0xE) MSDOS','15 (0xF) WIN3x','16 (0x10) WIN95'
    ,'17 (0x11) WIN98','18 (0x12) WINNT','19 (0x13) WINCE','20 (0x14) NCR3000','21 (0x15) NetWare','22 (0x16) OSF','23 (0x17) DC/OS','24 (0x18) Reliant UNIX'
    ,'25 (0x19) SCO UnixWare','26 (0x1A) SCO OpenServer','27 (0x1B) Sequent','28 (0x1C) IRIX','29 (0x1D) Solaris','30 (0x1E) SunOS','31 (0x1F) U6000'
    ,'32 (0x20) ASERIES','33 (0x21) TandemNSK','34 (0x22) TandemNT','35 (0x23) BS2000','36 (0x24) LINUX','37 (0x25) Lynx','38 (0x26) XENIX','39 (0x27) VM/ESA'
    ,'40 (0x28) Interactive UNIX','41 (0x29) BSDUNIX','42 (0x2A) FreeBSD','43 (0x2B) NetBSD','44 (0x2C) GNU Hurd','45 (0x2D) OS9','46 (0x2E)  MACH Kernel'
    ,'47 (0x2F) Inferno','48 (0x30) QNX','49 (0x31) EPOC','50 (0x32) IxWorks','51 (0x33) VxWorks','52 (0x34) MiNT','53 (0x35) BeOS','54 (0x36) HP MPE'
    ,'55 (0x37) NextStep','56 (0x38) PalmPilot''57 (0x39) Rhapsody')

    $OS=@()
    $a= Get-WmiObject Win32_OperatingSystem | SELECT Manufacturer, Name, Caption, Version, CSDVersion, InstallDate, LastBootUpTime, SerialNumber, ServicePackMajorVersion, 
                                                     OSProductSuite, OtherTypeDescription, Description,OperatingSystemSKU, OSArchitecture, BuildNumber, SystemDrive,
                                                     SystemDirectory,  WindowsDirectory, Organization, LocalDateTime, OSType, ProductType
                                                     
    $a1= Get-WmiObject Win32_OSRecoveryConfiguration | SELECT AutoReboot, DebugInfoType, OverwriteExistingDebugFile, ExpandedDebugFilePath, ExpandedMiniDumpDirectory

    $lic = Get-ActivationStatus
    
    If ($a.ProductType -eq 2)
    {
        $s = gwmi -namespace root\MicrosoftActiveDirectory -class Microsoft_LocalDomainInfo | select sid
        $os_SID = $s.SID
    }
    else
    {
        $LocAdm = Get-WmiObject -query "SELECT * FROM Win32_UserAccount WHERE domain='$env:computername' AND SID LIKE '%-500'"
        $os_SID = $LocAdm.SID.TrimEnd("-500")    
    }    

    $sku=''
    if (!$a.OperatingSystemSKU) {$sku = $SKUs[0]} else {$sku = $SKUs[$a.OperatingSystemSKU]}

    $OS += New-Object PSObject -Property @{
                                           SID = $os_SID
                                           Manufacturer = $a.Manufacturer
	                                       Name = $a.Name
	                                       Caption = $a.Caption 
	                                       Version = $a.Version 
	                                       CSDVersion = $a.CSDVersion
	                                       InstallDate = ([wmi]'').ConvertToDateTime($a.InstallDate)
	                                       LastBootUpTime = ([wmi]'').ConvertToDateTime($a.LastBootUpTime)
	                                       SerialNumber = $a.SerialNumber 
	                                       ServicePackMajorVersion = $a.ServicePackMajorVersion
	                                       ProductType = $ProductTypes[$a.ProductType]
                                           OSProductSuite = $a.OSProductSuite
	                                       OtherTypeDescription = $a.OtherTypeDescription
	                                       Description= $a.Description
	                                       OperatingSystemSKU = $sku
	                                       OSArchitecture = $a.OSArchitecture
	                                       BuildNumber = $a.BuildNUmber
	                                       SystemDrive = $a.SystemDrive
						                   SystemDirectory  = $a.SystemDirectory
						                   WindowsDirectory = $a.WindowsDirectory
						                   Organization = $a.Organization
						                   LocalDateTime = ([wmi]'').ConvertToDateTime($a.LocalDateTime)
						                   OSType = $ostypes[$a.OSType]
                                           ActivationStatus = $lic.Status
                                           osRecoveryAutoReboot = $a1.AutoReboot
	                                       osRecoveryDebugInfoType = $DebugInfoType[$a1.DebugInfoType]
	                                       osRecoveryOverwriteExistingDebugFile = $a1.OverwriteExistingDebugFile
	                                       osRecoveryExpandedDebugFilePath = $a1.ExpandedDebugFilePath
	                                       osRecoveryExpandedMiniDumpDirectory = $a1.ExpandedMiniDumpDirectory }

    LogEvent 1 "Operating system information successfully collected"
    return $OS
  }
 
    Catch {LogEvent 0 "an error occured while trying to collect Operating system information: $_"}
 }


Function Get-SCSIControllers
{
 Try
  {
    $SCSI=@()
       
    Get-WmiObject Win32_SCSIController | SELECT DeviceId, Name, Manufacturer, DriverName | ForEach {
    
    $SCSI += New-Object PSObject -Property @{
                                             Name = $_.Name
	                                         DeviceID = $_.DeviceID
	                                         Manufacturer = $_.Manufacturer
	                                         DriverName = $_.DriverName }}

    LogEvent 1 "SCSIController information successfully collected"
    return $SCSI
  }
 
    Catch {LogEvent 0 "an error occured while trying to collect SCSIController recovery information: $_"}
 }


Function Get-VideoController
{
 Try
  {
    $Video=@()
       
    $vid = Get-WmiObject Win32_VideoController | SELECT DeviceID, Name, AdapterCompatibility, InstalledDisplayDrivers, DriverVersion, DriverDate, InfFilename, PNPDeviceID 
    
    $Video += New-Object PSObject -Property @{
                                             Name = $vid.Name
	                                         DeviceID = $vid.DeviceID
	                                         AdapterCompatibility = $vid.AdapterCompatibility.Substring(1,$vid.AdapterCompatibility.Length-2)
	                                         InstalledDisplayDrivers = $vid.InstalledDisplayDrivers
                                             DriverVersion = $vid.DriverVersion
                                             DriverDate = ([wmi]'').ConvertToDateTime($vid.DriverDate)
                                             InfFilename = $vid.InfFilename
                                             PNPDeviceID = $vid.PNPDeviceID }

    LogEvent 1 "Video Controller information successfully collected"
    return $Video
  }
 
    Catch {LogEvent 0 "an error occured while trying to collect Video Controller information: $_"}
 }


Function Get-NetworkAdapters
{
 Try
  {
      $NetConStatusCodeMeaning = @('0 (0x0) Disconnected','1 (0x1) Connecting','2 (0x2) Connected','3 (0x3) Disconnecting','4 (0x4) Hardware not present',
                                       '5 (0x5) Hardware disabled','6 (0x6) Hardware malfunction','7 (0x7) Media disconnected','8 (0x8) Authenticating',
                                       '9 (0x9) Authentication succeeded','10 (0xA) Authentication failed','11 (0xB) Invalid address','12 (0xC) Credentials required')
      $NetworkAdapter = @()
      $r = Get-WmiObject Win32_NetworkAdapter |SELECT Name, DeviceId, PNPDeviceId, AdapterType, MACAddress, Manufacturer, Index, NetConnectionStatus, NetConnectionID | Where {$_.MACAddress -ne $null}
    
  
   Foreach ($a in $r)
    {
      $wmi_netconfig = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "Index = '$($a.Index)'" 
      $wmi_promisc = Get-WmiObject -Class MSNdis_CurrentPacketFilter -Namespace 'root\WMI' -Filter "InstanceName = '$($a.Name)'" 
    
        $promisc = $False 
        if ($wmi_promisc.NdisCurrentPacketFilter -band 0x00000020) 
        { 
            $promisc = $True 
        } 

        $NetConStat = '' 
        if ($a.NetConnectionStatus) 
        { 
            $NetConStat = $a.NetConnectionStatus
        } 
    
        $NetworkAdapter += New-Object PSObject -Property @{
                                            Name  = $a.Name
                                            DeviceID  = $a.DeviceID
                                            NetConnectionID = $a.NetConnectionID
                                            PNPDeviceId = $a.PNPDeviceId
                                            AdapterType  = $a.AdapterType 
                                            MACAddress  = $a.MACAddress 
                                            Manufacturer  = $a.Manufacturer 
                                            PromiscuousMode = $promisc
                                            ConnectionStatus = $NetConStatusCodeMeaning[$NetConStat]}
    }
    LogEvent 1 "NetworkAdapter information successfully collected"
    return $NetworkAdapter
  }

    Catch {LogEvent 0 "an error occured while trying to collect NetworkAdapter information: $_"}
}


Function Get-Shares
{
 Try
  {
    $shtyp = DATA {
    ConvertFrom-StringData -StringData @’
     0 = Disk Drive
     1 = Print Queue
     2 = Device
     3 = IPC
     2147483648 = Disk Drive Admin
     2147483649 = Print Queue Admin
     2147483650 = Device Admin
     2147483651= IPC Admin
‘@ }
    $Shares=@()
    $r = Get-WmiObject Win32_Share |SELECT Description, MaximumAllowed, Name, Path, AllowMaximum, @{Name = "ShareType"; Expression = {$shtyp["$($_.Type)"]}}
    
   Foreach ($a in $r)
    {
      $Shares += New-Object PSObject -Property @{
                                            Name  = $a.Name
                                            Description  = $a.Description
                                            MaximumAllowed = $a.MaximumAllowed
                                            Path  = $a.Path 
                                            AllowMaximum  = $a.AllowMaximum 
                                            ShareType = $a.ShareType}
    }
    LogEvent 1 "Shares information successfully collected"
    return $Shares
  }

    Catch {LogEvent 0 "an error occured while trying to collect shares information: $_"}

}


Function Get-SystemInformation
{
$chassisTp = DATA {
    ConvertFrom-StringData -StringData @’
        1 = Virtual Machine
        2 = Blade Server
        3 = Virtual Machine
        4 = Low Profile Desktop
        5 = Pizza Box
        6 = Mini Tower
        7 = Tower
        8 = Portable
        9 = Laptop
        10 = Notebook
        11 = Hand Held
        12 = Docking Station
        13 = All in One
        14 = Sub Notebook
        15 = Space-Saving Chassis
        16 = Ultra Small Form Factor
        17 = Server Tower Chassis
        18 = Mobile Device in Docking Station
        19 = Sub Chassis
        20 = Bus-Expansion Chassis
        21 = Peripheral Chassis
        22 = Storage Chassis
        23 = Rack Mount Unit
        24 = Sealed-Case PC 
‘@ }

$domainRoles = DATA {
    ConvertFrom-StringData -StringData @’
        0 = Standalone Workstation
        1 = Member Workstation
        2 = Standalone Server
        3 = Member Server
        4 = Backup Domain Controller
        5 = Primary Domain Controller
‘@ }
   
    $SystemInfo =@()

    $enclosure = Get-WmiObject Win32_SystemEnclosure | SELECT Manufacturer, SerialNumber,path, @{Name="ChassisType"; Expression = {$chassisTp["$($_.ChassisTypes)"]}}
    $bios = Get-wmiobject -class "Win32_BIOS" -namespace "root\CIMV2" | select Name,version, ReleaseDate, BIOSVersion, SMBIOSBIOSVersion, SMBIOSMajorVersion, SMBIOSMinorVersion, SerialNumber
    $timezone = Get-WMIObject Win32_TimeZone |select Description 
    $sys = Get-WmiObject Win32_ComputerSystem | select dnshostname,Name, Domain, Manufacturer, Model, @{Name="DomainRole"; Expression = {$domainRoles["$($_.DomainRole)"]}}, SystemType, NumberofLogicalProcessors,NumberofProcessors, OEMStringArray
    $sys1 = Get-WmiObject Win32_ComputerSystemProduct | SELECT UUID, Description
    $sys2 = Get-SystemType
    $phyRam = Get-WmiObject -Class Win32_OperatingSystem | select TotalVisibleMemorySize, FreePhysicalMemory, TotalVirtualMemorySize, FreeVirtualMemory

    if (-not ($sys2.IsVirtual))
        {
            $colSlots = Get-WmiObject -Class "win32_PhysicalMemoryArray" -namespace "root\CIMV2" 
            $colRAM = Get-WmiObject -Class "win32_PhysicalMemory" -namespace "root\CIMV2" 
            $totaldimms=0
            Foreach ($objSlot In $colSlots)
                {
                    $totaldimms += $objSlot.MemoryDevices
                }
            $totaldimmsfree = $totaldimms-$colRAM.count            
            
        }
    else 
        {
            $totaldimms = $null
            $totaldimmsfree = $null
        }
    
    $fqdn=$sys.dnshostname+'.'+$sys.domain
    $t= c:\windows\system32\nslookup.exe $fqdn
    $r = $t | Measure-Object
    $sysIP=($t[($r.Count)-2].Split(' '))[2]

    $PrdID=''
    Foreach($i in $sys.OEMStringArray)
    {
       if ($i.contains("Product ID:"))  
          {
             $PrdID=$i.Substring(($i.Length)-17,11)
          }
       else {$PrdID=''}
    }

    $RDP=Get-RemoteDesktopConfig
    $culture = [System.Globalization.Cultureinfo]::CurrentCulture | Select DisplayName
    
    $SystemInfo += New-Object PSObject -Property @{
						                            enclosureManufacturer = $enclosure.Manufacturer
                                                    enclosureSerialNumber = $bios.SerialNumber
                                                    enclosureChassisType = $enclosure.ChassisType
                                                    enclosurePath = $enclosure.Path
                                                          
                                                    biosName = $bios.Name
                                                    biosVersion = $bios.Version
                                                    biosReleaseDate = '{0:MM/dd/yyyy}' -f ([WMI]'').ConvertToDateTime($bios.ReleaseDate)
                                                    biosSMBIOSBIOSVersion = $bios.SMBIOSBIOSVersion
                                                    biosSMBIOSMajorVersion = $bios.SMBIOSMajorVersion
                                                    biosSMBIOSMinorVersion = $bios.SMBIOSMinorVersion

                                                    systemTimeZone = $timezone.Description
                                                    systemName = $sys.dnshostname
                                                    systemDomain = $sys.Domain
                                                    systemFQDN = $sys.dnshostname + "." + $sys.Domain
                                                    systemIPAddress = $sysIP
                                                    systemManufacturer = $sys.Manufacturer
                                                    systemModel = $sys.Model
							                        systemProductID = $PrdID
                                                    systemDomainRole = $sys.DomainRole
                                                    systemType = $sys.SystemType
                                                    systemUUID = $sys1.UUID
                                                    systemDescription = $sys1.Description
                                                    systemUpTime = Get-SystemUpTime
                                                    systemPendingReboot = Get-PendingReboot
                                                    systemRDPconfiguration = $RDP
                                                    systemCurrentCulture = $culture.DisplayName
                                                    systemFirewallEnabled = [bool](Get-ItemProperty -Path 'HKLM:\System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile').EnableFirewall
                                                                                                              
                                                    IsVirtual = $sys2.IsVirtual
                                                    vm_Type = $sys2.vm_Type
                                                    vm_PhysicalHostName = $sys2.vm_PhysicalHostName
                                                    Cluster = $sys2.CLuster 

                                                    PhysicalMemoryTotalDIMMs = $totaldimms
                                                    PhysicalMemoryTotalDIMMsFree = $totaldimmsfree
                                                    PhysicalMemoryTotal = [math]::round($phyRam.TotalVisibleMemorySize /1024/1024)
                                                    PhysicalMemoryFree = [math]::round($phyRam.FreePhysicalMemory /1024/1024)
                                                    PhysicalMemoryPercentUsed = [math]::round(((($phyRam.TotalVisibleMemorySize - $phyRam.FreePhysicalMemory)/$phyRam.TotalVisibleMemorySize) * 100),2) 
                                             
                                                    VirtualMemoryTotal = [math]::round($phyRam.TotalVirtualMemorySize/1024/1024)
                                                    VirtualMemoryFree = [math]::round($phyRam.FreeVirtualMemory/1024/1024)
                                                    
                                                    cpuCoreCount = $sys.NumberofLogicalProcessors
                                                    cpuCount = $sys.NumberofProcessors 
                                                    }

    LogEvent 1 "System information collected successfully"
    return $SystemInfo
   }


Function Get-SystemType
{ 
 Try
   {  
    $wmi_compsystem = Get-WmiObject Win32_ComputerSystem | Select Model, Manufacturer
    $wmi_bios = Get-WmiObject Win32_BIOS | Select Version, SerialNumber

    $IsVirtual = $false 
    $VirtualType = $null
    $vm_PhysicalHostName = $null
    $CLuster = $null

    $isMachineVirtual = @()

    if ($wmi_bios.Version -match "VIRTUAL")  
        { 
            $IsVirtual = $true 
            $VirtualType = "Virtual - Hyper-V" 
        } 
    elseif ($wmi_bios.Version -match "A M I")  
        { 
            $IsVirtual = $true 
            $VirtualType = "Virtual - Virtual PC" 
        } 
    elseif ($wmi_bios.Version -like "*Xen*")  
        { 
            $IsVirtual = $true 
            $VirtualType = "Virtual - Xen" 
        } 
    elseif ($wmi_bios.SerialNumber -like "*VMware*") 
        { 
            $IsVirtual = $true 
            $VirtualType = "Virtual - VMWare" 
        } 
    elseif ($wmi_compsystem.manufacturer -like "*Microsoft*") 
        { 
            $IsVirtual = $true 
            $VirtualType = "Virtual - Hyper-V" 
        } 
    elseif ($wmi_compsystem.manufacturer -like "*VMWare*") 
        { 
            $IsVirtual = $true 
            $VirtualType = "Virtual - VMWare" 
        } 
    elseif ($wmi_compsystem.model -like "*Virtual*") 
        { 
            $IsVirtual = $true 
            $VirtualType = "Unknown Virtual Machine" 
        }

    If ($IsVirtual)
        {
            $vm_PhysicalHostName = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters").PhysicalHostName
        }

    else 
        {
          $VirtualType  = $null
          $CLuster = (Get-ItemProperty -Path "HKLM:\CLUSTER").CLusterName
          If (!$CLuster) { $CLuster = "Not Clustered" }
      
        }

    $isMachineVirtual += New-Object PSObject -Property @{
                                                         IsVirtual = $IsVirtual
                                                         vm_Type = $VirtualType
                                                         vm_PhysicalHostName = $vm_PhysicalHostName
                                                         CLuster = $CLuster}
    
    LogEvent 1 "System type information collected successfully"
    return $isMachineVirtual
    }

  Catch 
    {
    LogEvent  "an error occured while collection system type information: $_"
    }
}


Function Get-LocaladmGroup
{
 Try
   {
    $localgroup ="Administrators"
    $server = "localhost"
    $groupobj =[ADSI]"WinNT://$server/$localgroup" 
    $localmembers = @($groupobj.psbase.Invoke("Members")) 
    $localmembers | foreach {$_.GetType().InvokeMember("AdsPath","GetProperty",$null,$_,$null) -replace('WinNT://',' ') -replace('/','\')}

    LogEvent 1 "Local admin group information successfully collected"
    }
    
 Catch {LogEvent 0 "an error occured while trying to collect local admin group information: $_"}
}


Function Get-LocalPowerUsersGroup
{
 Try
   {
    $localgroup ="Power Users"
    $server = "localhost"
    $groupobj =[ADSI]"WinNT://$server/$localgroup" 
    $localmembers = @($groupobj.psbase.Invoke("Members")) 
    $localmembers | foreach {$_.GetType().InvokeMember("AdsPath","GetProperty",$null,$_,$null) -replace('WinNT://',' ') -replace('/','\')}

    LogEvent 1 "Local power users group information successfully collected"
    }
    
 Catch {LogEvent 0 "an error occured while trying to collect local power users group information: $_"}
}


Function Get-LocalRemoteDesktopUsersGroup
{
 Try
   {
    $localgroup ="Remote Desktop Users"
    $server = "localhost"
    $groupobj =[ADSI]"WinNT://$server/$localgroup" 
    $localmembers = @($groupobj.psbase.Invoke("Members")) 
    $localmembers | foreach {$_.GetType().InvokeMember("AdsPath","GetProperty",$null,$_,$null) -replace('WinNT://',' ') -replace('/','\')}

    LogEvent 1 "Local remote desktop users group information successfully collected"
    }

 Catch {LogEvent 0 "an error occured while trying to collect local remote desktop users group information: $_"}
}

############################ Script Core ###########################

$ErrorActionPreference = "SilentlyContinue" 

if (!(Test-Path -path $InventoryFolder)) {New-Item $InventoryFolder -Type Directory}
Get-MSI
$InventoryDate = Get-Date
$vServerName = $env:computername #(Get-Item env:\Computername).Value
LogEvent 1 "-------------------------------------------"
$sysinfo = Get-SystemInformation
$v = $sysinfo.systemFQDN
$pfs = Get-PageFile

$a = ''
IPConfig /All | % {$a += $_+"`n"}
$ipc = $a.replace("`n","|")

$b = ''
Route Print | % {$b += $_+"`n"}
$rt = $b.replace("`n","|")

$wusettings = Get-WUsettings
$procs = Get-Processors
$disks = Get-Disks
$mpiopaths = Get-MPIOpaths
$os = Get-OperatingSystem
$shares = Get-Shares
$scsi = Get-SCSIControllers
$vidcont = Get-VideoController
$netadps = Get-NetworkAdapters
$nicbinding = Get-NICBinding
$ipv4routes = Get-IPv4RouteTable
$netadpconfig = Get-NetworkAdapterConfiguration
$netstats =  Get-NetworkStatistics
$lag = Get-LocaladmGroup
$lpu = Get-LocalPowerUsersGroup
$rdu = Get-LocalRemoteDesktopUsersGroup
$instupds = Get-InstalledUpdates
$pupds = Get-PendingUpdates
$instapps = Get-InstalledApplications 
$av = Get-SEPinformation 
$fr = Get-FeaturesRoles
$services = Get-Services

# Get backup agent
if ($instapps -like '*CommVault*') {$backupAgent="CommVault"}
 elseif ($instapps -like '*Acronis*') {$backupAgent="Acronis"} 
  else {$backupAgent=''}

#Get montoring agent
if($services -like '*NimbusWatcherService*') {$monitoringAgent='NimSoft'} else {$monitoringAgent=''}

###### Save information in local XML file ######
$name = Get-WmiObject Win32_ComputerSystem | select dnshostname,Domain
$sysfqdn = $name.dnshostname + "." + $name.Domain
$dt = '{0:yyyyMMdd-HHmm}' -f (Get-Date)
$v = "$sysfqdn-$dt.xml" 
$filepath = "$InventoryFolder$v"
$filenameEncoded = ($v).Replace(".","%2E")
$uri = "http://172.31.63.29/ServersInventoryAPI1/api/FileUpload?filename=$filenameEncoded&uploadtype=inventory"

Try
{
    # Create The Document
    $XmlWriter = New-Object System.XMl.XmlTextWriter($filepath,$Null)

    # Set The Formatting
    $xmlWriter.Formatting = "Indented"
    $xmlWriter.Indentation = "4"

    # Write the XML Decleration
    $xmlWriter.WriteStartDocument()

    # Write Root Element
    $xmlWriter.WriteStartElement("ComputerAssetInformation")

    # Write the Document
    $xmlWriter.WriteStartElement("SystemInformation")
     $xmlWriter.WriteElementString("InventoryDate",$InventoryDate)
     $xmlWriter.WriteElementString("enclosureSerialNumber",$sysinfo.enclosureSerialNumber)
     $xmlWriter.WriteElementString("enclosureChassisType",$sysinfo.enclosureChassisType   )
     $xmlWriter.WriteElementString("enclosurePath",$sysinfo.enclosurePath)
     $xmlWriter.WriteElementString("enclosureManufacturer ",$sysinfo.enclosureManufacturer )
 
     $xmlWriter.WriteElementString("biosName",$sysinfo.biosName)
     $xmlWriter.WriteElementString("biosVersion",$sysinfo.biosVersion)
     $xmlWriter.WriteElementString("biosReleaseDate",$sysinfo.biosReleaseDate)
     $xmlWriter.WriteElementString("biosSMBIOSBIOSVersion",$sysinfo.biosSMBIOSBIOSVersion)
     $xmlWriter.WriteElementString("biosSMBIOSMajorVersion",$sysinfo.biosSMBIOSMajorVersion)
     $xmlWriter.WriteElementString("biosSMBIOSMinorVersion",$sysinfo.biosSMBIOSMinorVersion)

     $xmlWriter.WriteElementString("PhysicalMemoryTotalDIMMs",$sysinfo.PhysicalMemoryTotalDIMMS)
     $xmlWriter.WriteElementString("PhysicalMemoryTotalDIMMsFree",$sysinfo.PhysicalMemoryTotalDIMMSFree)
     $xmlWriter.WriteElementString("PhysicalMemoryTotal",$sysinfo.PhysicalMemoryTotal)
     $xmlWriter.WriteElementString("PhysicalMemoryFree",$sysinfo.PhysicalMemoryFree)
     $xmlWriter.WriteElementString("PhysicalMemoryPercentUsed",$sysinfo.PhysicalMemoryPercentUsed)
 
     $xmlWriter.WriteElementString("VirtualMemoryTotal",$sysinfo.VirtualMemoryTotal)
     $xmlWriter.WriteElementString("VirtualMemoryFree",$sysinfo.VirtualMemoryFree)

     $xmlWriter.WriteElementString("cpuCoreCount",$sysinfo.cpuCorecount)
     $xmlWriter.WriteElementString("cpuCount",$sysinfo.cpuCount)

     $xmlWriter.WriteElementString("systemName",$sysInfo.systemName)
     $xmlWriter.WriteElementString("systemDomain",$sysinfo.systemDomain)
     $xmlWriter.WriteElementString("systemFQDN",$sysinfo.systemFQDN)
     $xmlWriter.WriteElementString("systemIPAddress",$sysinfo.systemIPAddress)
     $xmlWriter.WriteElementString("systemDomainRole",$sysinfo.systemDomainRole)
     $xmlWriter.WriteElementString("systemUUID",$sysinfo.systemUUID)
     $xmlWriter.WriteElementString("systemType",$sysinfo.systemType)
     $xmlWriter.WriteElementString("systemDescription",$sysinfo.systemDescription)
     $xmlWriter.WriteElementString("systemManufacturer",$sysinfo.systemManufacturer)
     $xmlWriter.WriteElementString("systemModel",$sysinfo.systemModel)
     $xmlWriter.WriteElementString("systemProductID",$sysinfo.systemProductID)
     $xmlWriter.WriteElementString("systemTimeZone",$sysinfo.systemTimeZone)
     $xmlWriter.WriteElementString("systemPendingReboot",$sysinfo.SystemPendingReboot)
     $xmlWriter.WriteElementString("systemUptime",$sysinfo.SystemUpTime)
     $xmlWriter.WriteElementString("systemRDPconfiguration",$sysinfo.systemRDPconfiguration)
     $xmlWriter.WriteElementString("systemCurrentCulture",$sysinfo.systemCurrentCulture)
     $xmlWriter.WriteElementString("systemFirewallEnabled", $sysinfo.systemFirewallEnabled)
     $xmlWriter.WriteElementString("systemMonitoringAgent",$monitoringAgent)
     $xmlWriter.WriteElementString("systemBackupAgent",$backupAgent)
     $xmlWriter.WriteElementString("IsVirtual",$sysinfo.IsVirtual)
     $xmlWriter.WriteElementString("vm_Type",$sysinfo.vm_Type)
     $xmlWriter.WriteElementString("vm_PhysicalHostName",$sysinfo.vm_PhysicalHostName)
     $xmlWriter.WriteElementString("Cluster",$sysinfo.Cluster)

     $xmlWriter.WriteElementString("IPconfig",$ipc)
     $xmlWriter.WriteElementString("Routes",$rt)

     $xmlWriter.WriteEndElement() # <-- Closing systemCONFIGURATION

     $xmlWriter.WriteStartElement("PageFiles")
     Foreach ($pf in $pfs)
     {
      $xmlWriter.WriteStartElement("PageFile")
        $xmlWriter.WriteElementString("Name", $pf.Name)
        $xmlWriter.WriteElementString("FileSize", $pf.FileSize)
        $xmlWriter.WriteElementString("FileType", $pf.FileType)
        $xmlWriter.WriteElementString("Compressed", $pf.Compressed)
        $xmlWriter.WriteElementString("CompressionMethod", $pf.CompressionMethod)
        $xmlWriter.WriteElementString("Encrypted", $pf.Encrypted)
        $xmlWriter.WriteElementString("EncryptionMethod", $pf.EncryptionMethod)
        $xmlWriter.WriteElementString("Hidden", $pf.Hidden)
        $xmlWriter.WriteElementString("InstallDate", $pf.InstallDate)
        $xmlWriter.WriteElementString("LastAccessed", $pf.LastAccessed)
        $xmlWriter.WriteElementString("LastModified", $pf.LastModified)
     $xmlWriter.WriteEndElement() # <-- Closing PageFile
    }
    $xmlWriter.WriteEndElement() # <-- Closing PageFiles
    
    $xmlWriter.WriteStartElement("WUsettings")
        $xmlWriter.WriteElementString("UseWSUSserver",$wusettings.UseWSUSserver)
        $xmlWriter.WriteElementString("DownloadLastSuccessTime",$wusettings.DownloadLastSuccessTime)
        $xmlWriter.WriteElementString("InstallLastSuccessTime",$wusettings.InstallLastSuccessTime)
        $xmlWriter.WriteElementString("DetectionFrequency",$wusettings.DetectionFrequency)
        $xmlWriter.WriteElementString("AutomaticUpdatesNotification",$wusettings.AutomaticUpdatesNotification)
        $xmlWriter.WriteElementString("DetectLastSuccessTime",$wusettings.DetectLastSuccessTime)
        $xmlWriter.WriteElementString("AutomaticUpdateEnabled",$wusettings.AutomaticUpdateEnabled)
        $xmlWriter.WriteElementString("InstallFrequency",$wusettings.InstallFrequency)
        $xmlWriter.WriteElementString("InstallTime",$wusettings.InstallTime)
        $xmlWriter.WriteElementString("WSUSserver",$wusettings.WSUSserver)
        $xmlWriter.WriteElementString("WSUSstatusURL",$wusettings.WSUSstatusURL)
        $xmlWriter.WriteElementString("TargetGroupEnabled",$wusettings.TargetGroupEnabled)
        $xmlWriter.WriteElementString("TargetGroup",$wusettings.TargetGroup)
        $xmlWriter.WriteElementString("OptedinMicrosoftUpdate",$wusettings.OptedinMicrosoftUpdate)
     $xmlWriter.WriteEndElement() # <-- Closing WUsettings

     $xmlWriter.WriteStartElement("OperatingSystem")
        $xmlWriter.WriteElementString("Name",$os.Name)
        $xmlWriter.WriteElementString("SID",$os.SID)
        $xmlWriter.WriteElementString("Manufacturer",$os.Manufacturer)
        $xmlWriter.WriteElementString("Caption",$os.Caption)
        $xmlWriter.WriteElementString("Version",$os.Version)
        $xmlWriter.WriteElementString("CSDVersion",$os.CSDVersion)
        $xmlWriter.WriteElementString("InstallDate",$os.InstallDate)
        $xmlWriter.WriteElementString("LastBootUpTime",$os.LastBootUpTime)
        $xmlWriter.WriteElementString("SerialNumber",$os.SerialNumber)
        $xmlWriter.WriteElementString("ServicePackMajorVersion",$os.ServicePackMajorVersion)
        $xmlWriter.WriteElementString("ProductType",$os.ProductType)
        $xmlWriter.WriteElementString("OSProductSuite",$os.OSProductSuite)
        $xmlWriter.WriteElementString("OtherTypeDescription",$os.OtherTypeDescription)
        $xmlWriter.WriteElementString("Description",$os.Description)
        $xmlWriter.WriteElementString("OperatingSystemSKU",$os.OperatingSystemSKU)
        $xmlWriter.WriteElementString("OSArchitecture",$os.OSArchitecture)
        $xmlWriter.WriteElementString("BuildNumber",$os.BuildNumber)
        $xmlWriter.WriteElementString("SystemDrive",$os.SystemDrive)
        $xmlWriter.WriteElementString("SystemDirectory",$os.SystemDirectory)
        $xmlWriter.WriteElementString("WindowsDirectory",$os.WindowsDirectory)
        $xmlWriter.WriteElementString("Organization",$os.Organization)
        $xmlWriter.WriteElementString("LocalDateTime",$os.LocalDateTime)
        $xmlWriter.WriteElementString("OSType",$os.OSType)
        $xmlWriter.WriteElementString("ActivationStatus",$os.ActivationStatus)
        $xmlWriter.WriteElementString("osRecoveryAutoReboot",$os.osRecoveryAutoReboot)
        $xmlWriter.WriteElementString("osRecoveryDebugInfoType",$os.osRecoveryDebugInfoType)
        $xmlWriter.WriteElementString("osRecoveryOverwriteExistingDebugFile",$os.osRecoveryOverwriteExistingDebugFile)
        $xmlWriter.WriteElementString("osRecoveryExpandedDebugFilePath",$os.osRecoveryExpandedDebugFilePath)
        $xmlWriter.WriteElementString("osRecoveryExpandedMiniDumpDirectory",$os.osRecoveryExpandedMiniDumpDirectory)
     $xmlWriter.WriteEndElement() # <-- Closing Operating System
 
    $xmlWriter.WriteStartElement("Processors")
     Foreach ($proc in $procs)
     {
     $xmlWriter.WriteStartElement("Processor")
        $xmlWriter.WriteElementString("DeviceID",$proc.DeviceID)
        $xmlWriter.WriteElementString("Name",$proc.Name)
        $xmlWriter.WriteElementString("Description",$proc.Description)
        $xmlWriter.WriteElementString("Manufacturer",$proc.Manufacturer)
        $xmlWriter.WriteElementString("Family",$proc.Family)
        $xmlWriter.WriteElementString("ProcessorId",$proc.ProcessorId)
        $xmlWriter.WriteElementString("Status",$proc.Status)
        $xmlWriter.WriteElementString("AddressWidth",$proc.AddressWidth)
        $xmlWriter.WriteElementString("DataWidth",$proc.DataWidth)
        $xmlWriter.WriteElementString("ExternalClock",$proc.ExtClock)
        $xmlWriter.WriteElementString("L2CacheSize",$proc.L2CacheSize)
        $xmlWriter.WriteElementString("MaxClockSpeed",$proc.MaxClockSpeed)
        $xmlWriter.WriteElementString("Revision",$proc.Revision)
        $xmlWriter.WriteElementString("SocketDesignation",$proc.SocketDesignation)
        $xmlWriter.WriteElementString("Architecture",$proc.Architecture)
        $xmlWriter.WriteElementString("CurrentClockSpeed",$proc.CurrentClockSpeed)
        $xmlWriter.WriteElementString("NumberOfCores",$proc.NumberOfCores)
    $xmlWriter.WriteEndElement() # <-- Closing Processor
    }
    $xmlWriter.WriteEndElement() # <-- Closing Processors

    $xmlWriter.WriteStartElement("Disks")
    Foreach ($disk in $disks)
     {
     $xmlWriter.WriteStartElement("Disk")
        $xmlWriter.WriteElementString("Drive",$disk.Drive)
        $xmlWriter.WriteElementString("Disk",$disk.Disk)
        $xmlWriter.WriteElementString("Model",$disk.Model)
        $xmlWriter.WriteElementString("Partition",$disk.Partition)
        $xmlWriter.WriteElementString("Description",$disk.Description)
        $xmlWriter.WriteElementString("PrimaryPartition",$disk.PrimaryPartition)
        $xmlWriter.WriteElementString("VolumeName",$disk.VolumeName)
        $xmlWriter.WriteElementString("DiskSize",$disk.DiskSize)
        $xmlWriter.WriteElementString("FreeSpace",$disk.FreeSpace)
        $xmlWriter.WriteElementString("PercentageFree",$disk.PercentageFree)
        $xmlWriter.WriteElementString("DiskType",$disk.DiskType)
        $xmlWriter.WriteElementString("SerialNumber",$disk.SerialNumber)
      $xmlWriter.WriteEndElement() # <-- Closing Disk
     }
    $xmlWriter.WriteEndElement() # <-- Closing Disks

    $xmlWriter.WriteStartElement("MPIO")
    Foreach ($path in $mpiopaths)
     {
      $xmlWriter.WriteStartElement("Path")
        $xmlWriter.WriteElementString("Name",$path.name)
        $xmlWriter.WriteElementString("Numberpaths",$path.numberpaths)
      $xmlWriter.WriteEndElement() # <-- Closing path
     }
    $xmlWriter.WriteEndElement() # <-- Closing MPIO



    $xmlWriter.WriteStartElement("Shares")
     Foreach ($share in $shares)
     {
     $xmlWriter.WriteStartElement("Share")
        $xmlWriter.WriteElementString("Name",$share.Name)
        $xmlWriter.WriteElementString("Description",$share.Description)
        $xmlWriter.WriteElementString("MaximumAllowed",$share.MaximumAllowed)
        $xmlWriter.WriteElementString("Path",$share.Path)
        $xmlWriter.WriteElementString("AllowMaximum",$share.AllowMaximum)
        $xmlWriter.WriteElementString("ShareType",$share.ShareType)
     $xmlWriter.WriteEndElement() # <-- Closing Share
     }
     $xmlWriter.WriteEndElement() # <-- Closing Shares


     $xmlWriter.WriteStartElement("SCSIControllers")
     Foreach ($cont in $scsi)
     {
     $xmlWriter.WriteStartElement("SCSIController")
        $xmlWriter.WriteElementString("Name",$cont.Name)
        $xmlWriter.WriteElementString("DeviceID",$cont.DeviceID)
        $xmlWriter.WriteElementString("Manufacturer",$cont.Manufacturer)
        $xmlWriter.WriteElementString("DriverName",$cont.DriverName)
     $xmlWriter.WriteEndElement() # <-- Closing SCSIController
     }
     $xmlWriter.WriteEndElement() # <-- Closing SCSIControllers

     $xmlWriter.WriteStartElement("VideoController")
        $xmlWriter.WriteElementString("Name",$vidcont.Name)
        $xmlWriter.WriteElementString("DeviceID",$vidcont.DeviceID)
        $xmlWriter.WriteElementString("AdapterCompatibility",$vidcont.AdapterCompatibility)
        $xmlWriter.WriteElementString("InstalledDisplayDrivers",$vidcont.InstalledDisplayDrivers)
        $xmlWriter.WriteElementString("DriverVersion",$vidcont.DriverVersion)
        $xmlWriter.WriteElementString("DriverDate",$vidcont.DriverDate)
        $xmlWriter.WriteElementString("InfFilename",$vidcont.InfFilename)
        $xmlWriter.WriteElementString("PNPDeviceID",$vidcont.PNPDeviceID)
     $xmlWriter.WriteEndElement() # <-- Closing VideoController

    $xmlWriter.WriteStartElement("NetworkAdapters")
     Foreach ($netadp in $netadps)
     {
     $xmlWriter.WriteStartElement("NetworkAdapter")
        $xmlWriter.WriteElementString("Name",$netadp.Name)
        $xmlWriter.WriteElementString("DeviceID",$netadp.DeviceID)
        $xmlWriter.WriteElementString("NetConnectionID",$netadp.NetConnectionID)
        $xmlWriter.WriteElementString("PNPDeviceId",$netadp.PNPDeviceId)
        $xmlWriter.WriteElementString("AdapterType",$netadp.AdapterType)
        $xmlWriter.WriteElementString("MACAddress",$netadp.MACAddress)
        $xmlWriter.WriteElementString("Manufacturer",$netadp.Manufacturer)
        $xmlWriter.WriteElementString("PromiscuousMode",$netadp.PromiscuousMode)
        $xmlWriter.WriteElementString("ConnectionStatus",$netadp.ConnectionStatus)
     $xmlWriter.WriteEndElement() # <-- Closing NetworkAdapter
     }
     $xmlWriter.WriteEndElement() # <-- Closing NetworkAdapters
     
     $xmlWriter.WriteStartElement("NICBindingOrder")
     Foreach ($nicb in $nicbinding)
     { $xmlWriter.WriteStartElement("Binding")
        $xmlWriter.WriteElementString("BindingOrder",$nicb.BindingOrder)
        $xmlWriter.WriteElementString("Name",$nicb.Name)
        $xmlWriter.WriteElementString("NICenabled",$nicb.NICenabled)
        $xmlWriter.WriteElementString("GUID",$nicb.GUID)
       $xmlWriter.WriteEndElement() # <-- Closing Binding
     }
     $xmlWriter.WriteEndElement() # <-- Closing NIC Binding

     $xmlWriter.WriteStartElement("IPv4RouteTable")
     Foreach ($route in $ipv4routes) 
     { $xmlWriter.WriteStartElement("Route")
        $xmlWriter.WriteElementString("NetworkAddress",$route.NetworkAddress)
        $xmlWriter.WriteElementString("Netmask",$route.Netmask)
        $xmlWriter.WriteElementString("GatewayAddress",$route.GatewayAddress)
        $xmlWriter.WriteElementString("Metric",$route.Metric)
       $xmlWriter.WriteEndElement() # <-- Closing Route
     }
     $xmlWriter.WriteEndElement() # <-- Closing IPv4RouteTable hamid

    
     $xmlWriter.WriteStartElement("NetworkAdapterConfiguration")
     Foreach ($netadpconf in $netadpconfig)
     {
     $xmlWriter.WriteStartElement("NetAdpConfiguration")
        $xmlWriter.WriteElementString("DefaultIPGateway",$netadpconf.DefaultIPGateway)
        $xmlWriter.WriteElementString("Description",$netadpconf.Description)
        $xmlWriter.WriteElementString("DHCPEnabled",$netadpconf.DHCPEnabled)
        $xmlWriter.WriteElementString("DHCPServer",$netadpconf.DHCPServer)
        $xmlWriter.WriteElementString("DNSDomain",$netadpconf.DNSDomain)
        $xmlWriter.WriteElementString("DNSDomainSuffixSearchOrder",$netadpconf.DNSDomainSuffixSearchOrder)
        $xmlWriter.WriteElementString("DNSEnabledForWINSResolution",$netadpconf.DNSEnabledForWINSResolution)
        $xmlWriter.WriteElementString("DNSServerSearchOrder",$netadpconf.DNSServerSearchOrder)
        $xmlWriter.WriteElementString("DomainDNSRegistrationEnabled",$netadpconf.DomainDNSRegistrationEnabled)
        $xmlWriter.WriteElementString("FullDNSRegistrationEnabled",$netadpconf.FullDNSRegistrationEnabled)
        $xmlWriter.WriteElementString("Index",$netadpconf.Index)
        $xmlWriter.WriteElementString("IPAddress",$netadpconf.IPAddress)
        $xmlWriter.WriteElementString("IPConnectionMetric",$netadpconf.IPConnectionMetric)
        $xmlWriter.WriteElementString("IPSubnet",$netadpconf.IPSubnet)
        $xmlWriter.WriteElementString("IPEnabled",$netadpconf.IPEnabled)
        $xmlWriter.WriteElementString("IPXAddress",$netadpconf.IPXAddress)
        $xmlWriter.WriteElementString("IPXEnabled",$netadpconf.IPXEnabled)
        $xmlWriter.WriteElementString("MACAddress",$netadpconf.MACAddress)
        $xmlWriter.WriteElementString("ServiceName",$netadpconf.ServiceName)
        $xmlWriter.WriteElementString("SettingId",$netadpconf.SettingId)
        $xmlWriter.WriteElementString("TCPIPNetBIOSOptions",$netadpconf.TCPIPNetBIOSOptions)
        $xmlWriter.WriteElementString("WINSEnableLMHostsLookup",$netadpconf.WINSEnableLMHostsLookup)
        $xmlWriter.WriteElementString("WINSPrimaryServer",$netadpconf.WINSPrimaryServer)
        $xmlWriter.WriteElementString("WINSSecondaryServer",$netadpconf.WINSSecondaryServer)
    $xmlWriter.WriteEndElement() # <-- Closing NetAdpConfiguration
    }
    $xmlWriter.WriteEndElement() # <-- Closing NetworkAdapterConfiguration

    $xmlWriter.WriteStartElement("NetworkStatistics")
     Foreach ($netstat in $netstats) 
     { $xmlWriter.WriteStartElement("Netstat")
        $xmlWriter.WriteElementString("PID",$netstat.PID)
        $xmlWriter.WriteElementString("ProcessName",$netstat.ProcessName)
        $xmlWriter.WriteElementString("Protocol",$netstat.Protocol)
        $xmlWriter.WriteElementString("LocalAddress",$netstat.LocalAddress)
        $xmlWriter.WriteElementString("LocalPort",$netstat.LocalPort)
        $xmlWriter.WriteElementString("RemoteAddress",$netstat.RemoteAddress)
        $xmlWriter.WriteElementString("RemotePort",$netstat.RemotePort)
        $xmlWriter.WriteElementString("State",$netstat.State)
       $xmlWriter.WriteEndElement() # <-- Closing Netstat
     }
     $xmlWriter.WriteEndElement() # <-- Closing NetworkStatistics

    $xmlWriter.WriteStartElement("Features")
        Foreach ($f in $fr)
          {
            $xmlWriter.WriteElementString("Feature",$f.Name)
          }
    $xmlWriter.WriteEndElement() # <-- Closing InstalledFeatures
    
          
    $xmlWriter.WriteStartElement("LocalAdministratorGroup")
        Foreach ($lagmem in $lag)
          {
            $xmlWriter.WriteElementString("Member",$lagmem)
          }
    $xmlWriter.WriteEndElement() # <-- Closing LocalAdministratorGroup

    $xmlWriter.WriteStartElement("LocalPowerUsersGroup")
        Foreach ($lpumem in $lpu)
          {
            $xmlWriter.WriteElementString("Member",$lpumem)
          }
    $xmlWriter.WriteEndElement() # <-- Closing LocalPowerUsersGroup

    $xmlWriter.WriteStartElement("LocalRemoteDesktopUsersGroup")
        Foreach ($rdumem in $rdu)
         {
            $xmlWriter.WriteElementString("Member",$rdumem)
         }
    $xmlWriter.WriteEndElement() # <-- Closing LocalRemoteDesktopUsersGroup
    
    $xmlWriter.WriteStartElement("InstalledUpdates")
       Foreach ($upd in $instupds)
        {
          $xmlWriter.WriteStartElement("Update")
            $xmlWriter.WriteElementString("HotFixID",$upd.HotfixID)
            $xmlWriter.WriteElementString("Title",$upd.Title)
            $xmlWriter.WriteElementString("InstallDate",$upd.InstallDate)
          $xmlWriter.WriteEndElement() # <-- Closing Update
        }
    $xmlWriter.WriteEndElement() # <-- Closing InstalledUpdates

    $xmlWriter.WriteStartElement("PendingUpdates")
      Foreach ($pupd in $pupds)
        {
          $xmlWriter.WriteStartElement("Update")
            $xmlWriter.WriteElementString("HotFixID",$pupd.HotfixID)
            $xmlWriter.WriteElementString("Title",$pupd.Title)
            $xmlWriter.WriteElementString("Severity",$pupd.Severity)
            $xmlWriter.WriteElementString("ReleaseDate",$pupd.ReleaseDate)
          $xmlWriter.WriteEndElement() # <-- Closing Update
        }
    $xmlWriter.WriteEndElement() # <-- Closing PendingUpdate

    $xmlWriter.WriteStartElement("Services")
      Foreach ($service in $Services)
        {
      $xmlWriter.WriteStartElement("Service")
	     $xmlWriter.WriteElementString("Name",$service.Name)
      	 $xmlWriter.WriteElementString("Status", $service.Status)
	     $xmlWriter.WriteElementString("PathName", $service.PathName)
	     $xmlWriter.WriteElementString("ServiceType", $service.ServiceType)
	     $xmlWriter.WriteElementString("StartMode", $service.StartMode)
	     $xmlWriter.WriteElementString("AcceptPause", $service.AcceptPause)
	     $xmlWriter.WriteElementString("AcceptStop", $service.AcceptStop)
	     $xmlWriter.WriteElementString("Description", $service.Description)
	     $xmlWriter.WriteElementString("DisplayName", $service.DisplayName)
	     $xmlWriter.WriteElementString("ProcessId", $service.ProcessId)
	     $xmlWriter.WriteElementString("Started", $service.Started)
	     $xmlWriter.WriteElementString("StartName", $service.StartName)
	     $xmlWriter.WriteElementString("State", $service.State)
	     $xmlWriter.WriteElementString("Path", $service.Path)
      $xmlWriter.WriteEndElement() # <-- Closing Service)
        }
    $xmlWriter.WriteEndElement() # <-- Closing Services

    $xmlWriter.WriteStartElement("SymantecEndpointProtection")
      $xmlWriter.WriteElementString("isInstalled",$av.isINstalled)
      $xmlWriter.WriteElementString("Version",$av.Version)
      $xmlWriter.WriteElementString("InstallDate",$av.InstallDate)
      $xmlWriter.WriteElementString("LatestDefinition",$av.LatestDefinition)
    $xmlWriter.WriteEndElement() # <-- Closing Symantec_Endpoint_Protection

    $xmlWriter.WriteStartElement("InstalledApplications")
      Foreach ($app in $instapps)
        {
           $xmlWriter.WriteStartElement("Application")
            $xmlWriter.WriteElementString("Name",$app.Name)
            $xmlWriter.WriteElementString("Version",$app.Version)
            $xmlWriter.WriteElementString("ServiceUpdate",$app.ServiceUpdate)
            $xmlWriter.WriteElementString("Vendor",$app.Vendor)
            $xmlWriter.WriteElementString("InstallDate",$app.InstallDate)
           $xmlWriter.WriteEndElement() # <-- Closing Application
        }
    $xmlWriter.WriteEndElement() # <-- Closing Installed Applications

    # End the XML Document
    $xmlWriter.WriteEndDocument()

    # Finish The Document
    $xmlWriter.Finalize
    $xmlWriter.Flush
    $xmlWriter.Close()

    LogEvent 1 "Inventory XML file successfully generated"

    # Upload inventory file using WEB API call   
    Upload-File $uri $filepath

    # Cleanup
    $limit = (Get-Date).AddDays(-35)
    $path = "C:\Inventory\*.XML"
    Get-ChildItem $path | ? {-not $_.PSIsContainer -and $_.CreationTime -lt $limit} | Remove-Item -Force

# Install chef
$chefversion = ''
$chefservice = ''

# Check if chef is installed
Foreach($app in $instapps)
  {
      if ($app.name -like "*chef client*") {$chefversion = $app.name}
  }

if (!$chefversion) # if chef is not installed install it
   {	
	    Write-Host "Downloading the chef-client installation package..."
        $ChefFolder = 'c:\chef\'
        $sources = @("http://172.31.63.29/ServersInventoryAPI1/resources/Chef-Install/chef-windows-11.12.8-2.windows.txt",
                     "http://172.31.63.29/ServersInventoryAPI1/resources/Chef-Install/chef-validation.txt",
                     "http://172.31.63.29/ServersInventoryAPI1/resources/Chef-Install/client.txt",
                     "http://172.31.63.29/ServersInventoryAPI1/resources/Chef-Install/chef.txt")

        $destinations = @("c:\chef\chef-windows-11.12.8-2.windows.msi", 
		                  "c:\chef\chef-validation.pem",
		                  "c:\chef\client.rb", 
		                  "c:\chef\chef.crt")

        # Create the chef directory in the root of C if it does not exist
        if (!(Test-Path -path $ChefFolder)) {New-Item $ChefFolder -Type Directory}

        #Download the chef installation package
        For ($i=0;$i -lt 4; $i++) 
            {
    	        $wc = New-Object System.Net.WebClient
    	        $wc.DownloadFile($sources[$i], $destinations[$i])
            }
    	Write-Host "Installing chef-client for windows..."
        #install chef and start the service
        $chefmsi= 'C:\chef\chef-windows-11.12.8-2.windows.msi' 
        $arguments= ' ADDLOCAL="ChefClientFeature,ChefServiceFeature" /qn /norestart' 
        Start-Process -file  $chefmsi -arg $arguments -passthru | wait-process
        $env:Path = $env:Path + ";C:\opscode\chef\embedded\bin;C:\opscode\chef\embedded"
        Write-Host "Adding the node to the correcponding role..."
	    $role = "Base-Role"
        switch (($env:computername).Substring(0,3)) 
            { 
                "DEN" {$role = "DEN-Denver"}                "EWR" {$role = "EWR-NewJersey"}                "FRA" {$role = "FRA-Frankfurt"}                "GRU" {$role = "GRU-SaoPaulo"}                "HND" {$role = "HND-Tokyo"}                "IND" {$role = "IND-Indianapolis"}                "KKJ" {$role = "KKJ-Kitakyushu"}                "LHR" {$role = "LHR-London"}                "MEL" {$role = "MEL-Melbourne"}                "SYD" {$role = "SYD-Sydney"}                "YUL" {$role = "YUL-Montreal"}                "YYZ" {$role = "YYZ-Toronto"}     
                        default {$role = "Base-Role"}
            }

        c:\opscode\chef\bin\chef-client.bat -r "role[$role]"
        Write-Host "Starting the chef-client service..."
	    Start-Service chef-client 
	    Write-Host "The chef-client was installed successfully"
   } 
else 
    {
        foreach($service in $services) # chech is service is runnin, if not start it
            {
                if ($service.name -eq 'chef-client') 
                    {
                        If (!$service.State -eq 'Running') {}#Start-Service chef-client}
                    }
             }

    }
#   
 }

 Catch {LogEvent 0 "an error occured while trying to generate inventory XML file: $_"}