<#
.Synopsis
   Displays the text needed in a SQL request for new accounts
.DESCRIPTION
   Displays the text needed in a SQL request for new accounts
.EXAMPLE
   PS > Show-SQLRequest -ServerName OAINTDBT6

   Please create the following new accounts:
   OAINTDBT6-SQLS
   OAINTDBT6-SQLA - place this account in security group SSFHS\SQL Server Agent
   Note - This will run the services on OAINTDBT6 server.  Please send me the passwords.

#>
function Show-SQLRequest
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # ServerName help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ServerName
    )

    " "
    "Please create the following new accounts:"
    "$ServerName-SQLS"
    "$ServerName-SQLA - place this account in security group SSFHS\SQL Server Agent"
    "Note - This will run the services on $ServerName server.  Please send me the passwords."
    
}

<#
.Synopsis
   Backs up file in current directory
.DESCRIPTION
   Backs up file in current directory to a history folder.  If folder doesn't exist it creates one.
   File has date stamp appended to it.
.EXAMPLE
   Backup-File -FileName qc.ps1

#>
function Backup-File
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # FileName help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $FileName
    )


 $ts = (get-date -uformat %Y%m%d%H%M)
 if (!(Test-Path history)) {
  "history directory does not exist, creating one now"
  New-Item history -Type directory
 }

 copy $FileName history\$FileName-$ts -PassThru
}
<#
.Synopsis
   script to sign scripts
.DESCRIPTION
   script to sign scripts
   Uses the *pfx file to grab certificate
.EXAMPLE
   Set-Signature -ScriptName script.ps1

.INPUTS
   ScriptName - name of the script to sign
#>
function Set-Signature
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param
    (
        # ScriptName help description
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]

        [Alias("sn")] 
        $ScriptName
    )
   if (! $global:cert ) {     
     $global:cert = Get-PfxCertificate \\oaintpwshell\scripts\certificate\CorePSsign.pfx
   }
   if ($ScriptName -like "*.ps1" -or $Scriptname -like "*.psm1") {     
    Set-AuthenticodeSignature $ScriptName -cert $global:cert
   }
   else {
    echo "This doesn't look like a script file. Expect .ps1* extension"
   }

}
function Set-Wallpaper
{
	param(
		[Parameter(Mandatory=$true)]
		$Path,
		
		[ValidateSet('Center', 'Stretch')]
		$Style = 'Stretch'
	)
	
	Add-Type @"
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32;
namespace Wallpaper
{
public enum Style : int
{
Center, Stretch
}
public class Setter {
public const int SetDesktopWallpaper = 20;
public const int UpdateIniFile = 0x01;
public const int SendWinIniChange = 0x02;
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
public static void SetWallpaper ( string path, Wallpaper.Style style ) {
SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
switch( style )
{
case Style.Stretch :
key.SetValue(@"WallpaperStyle", "2") ; 
key.SetValue(@"TileWallpaper", "0") ;
break;
case Style.Center :
key.SetValue(@"WallpaperStyle", "1") ; 
key.SetValue(@"TileWallpaper", "0") ; 
break;
}
key.Close();
}
}
}
"@
	
	[Wallpaper.Setter]::SetWallpaper( $Path, $Style )
}
<#
.Synopsis
   Perform Quality Control Checks against a server
.DESCRIPTION
   Perform Quality Control Checks against a server including Netbackup Install, Forefront Install, Reboot Task created and set,
   CMDB entry created, CMDB Software associated, CMDB Reboot Schedule documented
.EXAMPLE
   Verify-ServerBuild -ComputerName oaintfile2
.EXAMPLE
   qc -ComputerName oaintfile2
#>
function Test-ServerBuild
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ComputerName

    )
  $outds=$null
 "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 # Test that Forefront has been installed
  
 if (Get-process -ComputerName $ComputerName -Name MsMpEng -ErrorAction silentlycontinue ) 
    {write-host -ForegroundColor green "Forefront Installed:  PASSED"}
 else
    { write-host -ForegroundColor red -BackgroundColor DarkYellow "Forefront Installed:  FAILED" }

 # Test that Netbackup has been installed 

 #if (Get-service -ComputerName $ComputerName -Name "Netbackup Client*" -ErrorAction silentlycontinue ) 
 If ((Get-service -ComputerName $ComputerName  -Name "Netbackup C*" -ErrorAction silentlycontinue ) -or (Get-service -ComputerName $ComputerName  -Name "Netbackup I*" -ErrorAction silentlycontinue ))
    {write-host -ForegroundColor green "Netbackup Installed:  PASSED"}
 else
    { write-host -ForegroundColor red -BackgroundColor DarkYellow "Netbackup Installed:  FAILED" }
 
  $reboot=Get-SchedTasks -ComputerName $ComputerName | %{if ($_.name -like "*reboot*" ) { $_ } }
    if ($reboot) 
    { 
      if (Get-Service -ComputerName $ComputerName imaservice -ErrorAction silentlycontinue) {
       write-host -ForegroundColor red -BackgroundColor DarkYellow "Reboot Task on Server:  TRUE (NOT Valid for Citrix server)"
      } else {
       write-host -ForegroundColor green "Reboot Task on Server:  PASSED" 
      }
      write-host -ForegroundColor yellow "Reboot Task INFO:"
      $reboot | Select-Object name, nextruntime 
      " "}
  else
    { 
      if (Get-Service -ComputerName $ComputerName imaservice -ErrorAction silentlycontinue) {
        write-host -ForegroundColor green "Reboot Task on Server:  False (This is Valid on a Citrix server)"
      } else {
            write-host -ForegroundColor red -BackgroundColor DarkYellow "Reboot Task on Server:  FAILED" 
      }
    }

  #Reboot info

  $sqlQuery = @"
                select server.servername, ServerRebootSchedule.Frequency, ServerRebootSchedule.Timeframe, DayofWeek, HourOfDay, MinuteOfDay, ampm, rebootismanual
                from [CMDB].[dbo].[Server] 
                left outer join [CMDB].[dbo].[ServerRebootSchedule] 
                on [CMDB].[dbo].[Server].[ServerID] = [CMDB].[dbo].[ServerRebootSchedule].[ServerID]
                where [CMDB].[dbo].[Server].[ServerName] = '$ComputerName'
"@
  
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server = OAINTDBVS2\SQL2; Database=CMDB; Trusted_Connection=True;”
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet) | Out-Null
$SqlConnection.Close()
$outds = $DataSet.Tables[0]

if ( $outds.Rows.Count -eq 0 ) 
  { write-host -ForegroundColor red -BackgroundColor DarkYellow "Server in CMDB:  FAILED" }
  else { 
      write-host -ForegroundColor yellow "CMDB reboot setting below: (All zeros indicate it hasn't been filled out!)"
      $outds | Out-Host

 #software info
 $sqlQuery = @"
                select server.servername, serversoftware.softwareID 
                from [CMDB].[dbo].[Server] 
                left outer join [CMDB].[dbo].[ServerSoftware] 
                on [CMDB].[dbo].[Server].[ServerID] = [CMDB].[dbo].[ServerSoftware].[ServerID] 
                where [CMDB].[dbo].[Server].[ServerName] = '$ComputerName' 
"@

 $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
 $SqlConnection.ConnectionString = "Server = OAINTDBVS2\SQL2; Database=CMDB; Trusted_Connection=True;”
 $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
 $SqlCmd.CommandText = $SqlQuery
 $SqlCmd.Connection = $SqlConnection
 $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
 $SqlAdapter.SelectCommand = $SqlCmd
 $DataSet = New-Object System.Data.DataSet
 $SqlAdapter.Fill($DataSet) | Out-Null

 $SqlConnection.Close()

 $outds = $DataSet.Tables[0]

 if ($outds.rows.softwareid.tostring().length -gt 0) { write-host -ForegroundColor green "Software associated in CMDB:  PASSED"}
 else { write-host -ForegroundColor red -BackgroundColor Yellow "Software associated in CMDB:  FAILED"} 
 " "
 write-host -ForegroundColor Yellow "REMEMBER to look for password in Network Password Manager!"
  "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 }

}

<#
.Synopsis
   Extend Disk on a server remotely
.DESCRIPTION
   Extend Disk on a server remotely using diskpart
.EXAMPLE
   Exapnd-Disk -ComputerName oaintpwshell

   Output:
   Microsoft DiskPart version 6.1.7601
   Copyright (C) 1999-2008 Microsoft Corporation.
   On computer: OAINTPWSHELL

   DISKPART> 
   Please wait while DiskPart scans your configuration...

   DiskPart has finished scanning your configuration.

   DISKPART> 
     Volume ###  Ltr  Label        Fs     Type        Size     Status     Info
     ----------  ---  -----------  -----  ----------  -------  ---------  --------
     Volume 0     D                       DVD-ROM         0 B  No Media           
     Volume 1         System Rese  NTFS   Partition    100 MB  Healthy    System  
     Volume 2     C                NTFS   Partition     49 GB  Healthy    Boot    

   DISKPART> 
   Select Volume to Extend: 

#>
function Expand-Disk
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # ComputerName This is the server that you need to expand disk on
        [Parameter(Mandatory=$true,
                   Position=0)]
        $ComputerName
    )

    Process
    {
     invoke-command -ComputerName $ComputerName -ScriptBlock {"rescan", "list volume" | diskpart}

     $volume = read-host "Select Volume to Extend"
     $select = "select volume $volume"
     #"This function is still in testing.  You cannot extend disk with it yet..."
     # This value in $select variable is copied to $value param and passed to scriptblock
     invoke-command -ComputerName $ComputerName -ScriptBlock {
     param($value) 
     $value, "extend", "exit" | diskpart} -argumentlist $select
    }

}
<#
.Synopsis
   Find Citrix Machines based on system events
.DESCRIPTION
   Find Citrix Machines based on system events 9017 and 9026
.EXAMPLE
   Get-CitrixEventLogs  -Day 13 -Hour 9 -Minute 00
   
   EventID       : 9026
   MachineName   : OAIMFLIS05
   TimeGenerated : 02/13/2014 9:54:45 AM
.EXAMPLE
   Get-CitrixEventLogs   (This will default to any events after midnight of the current day)
#>
function Get-CitrixEventLogs
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Day Which day you want to start looking at events
        [Parameter(
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Day=(get-date).Day,

        # Hour Which hour you want to start looking at events
        $Hour=0,
        # Minute Which minute you want to start looking at events
        $Minute=0
    )
    Begin 
    {
     $resultsarray = $null
     $resultsarray =@() 
     $erroractionpreference = "SilentlyContinue"
    }
    Process
    {
     " "
     "Get List of Citrix servers from Active Directory..."
     $ADresult = Get-ADComputer -Filter { (Name -like "oaimf*")}

     $aftertxt = Get-Date -Day $Day -Hour $Hour -Minute $Minute
     " "
     "Search Citrix servers for 9017 or 9026 Event IDs After $aftertxt"

     foreach ($record in $ADresult) { $resultsarray+=$record.name }

     #Invoke-Command -ComputerName $resultsarray -FilePath C:\scripts\temp.ps1 -ArgumentList $day,$hour,$minute -SessionOption (New-PSSessionOption -NoMachineProfile)

     Invoke-Command -ComputerName $resultsarray -ScriptBlock {
       
       param($day,$hour,$minute)
       
       $after = Get-Date -Day $Day -Hour $Hour -Minute $Minute

       Get-EventLog -LogName System -After $after  | % { 
       if ($_.EventID -eq 9017 -or $_.EventID -eq 9026) { $_ | fl EventID, MachineName, TimeGenerated; continue } 
       }
      } -ArgumentList $day,$hour,$minute


     } 
      <#   Test code
      Get-Date
       Get-EventLog -ComputerName OAIMFAFF00 -LogName System -After $after  | % { 
       if ($_.EventID -eq 9017 ) { $_ | fl EventID, MachineName, TimeGenerated; continue } 
       }
       Get-Date
      #> 
    }

<#
.Synopsis
   Get Heat Oncall Information
.DESCRIPTION
   Get Heat Oncall Information
.EXAMPLE
   Get-Oncall
   return the complete Heat oncall list
.EXAMPLE
   Get-Oncall -search Windows
   Search for a specifc item or person in windows oncall list
#>
function Get-Oncall
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Search - provide string to seach oncall list
        [Parameter(
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $search
    )

    Process
    {

        $sqlQuery = "SELECT [GroupName],[GroupDesc],[Supervisor] FROM [HEATProd].[dbo].[AsgnGrp]"
        $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $SqlConnection.ConnectionString = "Server = oaintheatdb; Database=HEATProd; Trusted_Connection=True;”
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd.CommandText = $SqlQuery
        $SqlCmd.Connection = $SqlConnection
        $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCmd
        $DataSet = New-Object System.Data.DataSet
        $SqlAdapter.Fill($DataSet)
        $SqlConnection.Close()
        $heatinfo = $DataSet.Tables[0]

      if (! $search) { $heatinfo }
      else
      { 
       for ($i=0; $i -le $heatinfo.rows.Count; $i++) 
       { 
         if ($heatinfo.Rows[$i].GroupDesc -like "*$search*" -or $heatinfo.rows[$i].GroupName -like "*$search*") { $heatinfo.rows[$i]} 
       }
      }
    }
}
Function Get-SchedTasks 
{
<#   
.SYNOPSIS   
	This function will display Scheduled Tasks from a server
    
.DESCRIPTION 
	This function uses the Schedule.Service COM-object to query the local or a remote computer in order to gather a
	formatted list including the Author, UserId and description of the task. This information is parsed from the
	XML attributed to provide a more human readable format
 
.PARAMETER Computername
    The computer that will be queried by this script, local administrative permissions are required to query this
    information

.NOTES   
    Name: Get-ScheduledTask.ps1
    Author: Jaap Brasser
    DateCreated: 2012-05-23
    DateUpdated: 2012-07-22
    Site: http://www.jaapbrasser.com
    Version: 1.2 - converted to script by Toby Matherly 2/12/2014

.LINK
	http://www.jaapbrasser.com
	
.EXAMPLE   
	Get-SchedTasks -Computername mycomputer1

Description 
-----------     
This command query mycomputer1 and display a formatted list of all scheduled tasks on that computer

.EXAMPLE   
	Get-SchedTasks

Description 
-----------     
This command query localhost and display a formatted list of all scheduled tasks on the local computer	
#>
[CmdletBinding()] 
param( 
 [parameter(Position=0,ValueFromPipeline=$true)] 
 [alias("CN","Computer")] 
 $ComputerName="$env:COMPUTERNAME",
 [switch]$RootFolder
 )

#region Functions
function Get-AllTaskSubFolders {
    [cmdletbinding()]
    param (
        # Set to use $Schedule as default parameter so it automatically list all files
        # For current schedule object if it exists.
        $FolderRef = $Schedule.getfolder("\")
    )
    $erroractionpreference = "SilentlyContinue"
    if ($RootFolder) {
        $FolderRef
    } else {
        $FolderRef
        $ArrFolders = @()
        if(($folders = $folderRef.getfolders(1))) {
            foreach ($folder in $folders) {
                $ArrFolders += $folder
                if($folder.getfolders(1)) {
                    Get-AllTaskSubFolders -FolderRef $folder
                }
            }
        }
       # $ArrFolders
    }
}
#endregion Functions


try {
	$schedule = new-object -com("Schedule.Service") 
} catch {
	Write-Warning "Schedule.Service COM Object not found, this script requires this object"
	return
}

$Schedule.connect($ComputerName) 
$AllFolders = Get-AllTaskSubFolders

foreach ($Folder in $AllFolders) {
   
    if (($Tasks = $Folder.GetTasks(0))) {
        $TASKS | % {[array]$results += $_}
        $Tasks | Foreach-Object {
              
	       New-Object -TypeName PSCustomObject -Property @{
	           'Name' = $_.name
                'Path' = $_.path
                'State' = $_.state
                'Enabled' = $_.enabled
                'LastRunTime' = $_.lastruntime
                'LastTaskResult' = $_.lasttaskresult
                'NumberOfMissedRuns' = $_.numberofmissedruns
                'NextRunTime' = $_.nextruntime
                'Author' =  ([xml]$_.xml).Task.RegistrationInfo.Author
                'UserId' = ([xml]$_.xml).Task.Principals.Principal.UserID
                'Description' = ([xml]$_.xml).Task.RegistrationInfo.Description
            }
        }
    }
}
}
<#
.Synopsis
   Change the Linus password on a remote server
.DESCRIPTION
   Change the Linus password on a remote server
.EXAMPLE
   Set-Linus -computername a78ntdb2
.EXAMPLE
   Set-Linus
#>
function Set-Linus
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter( 
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ComputerName
    )

    Process
    {
     $error.clear()
     $EnableUser = 512
     $DisableUser = 2
     $PWneverexp = 65536
     $Usrcantchpw = 64
     if (! $ComputerName) {  $ComputerName = read-host "Enter server " }
     if (! $strPassword) {
         $pass = read-host -assecurestring "Enter Linus Password "
         $strPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))
     }
     # Baseline Linus User account #
     $objUser = [ADSI]("WinNT://$ComputerName/Linus, user")
     ## Set password for Linus account
     $objUser.psbase.invoke("SetPassword",$strPassword)

     if(-not $?) {
       "  "
       "+++ The invoke for setting Linus password didn't work!  Have you moved to the correct OU?"
       "  "
     } 
     else {
      $objUser.psbase.CommitChanges()
      if ($error.Count -gt 0) {
        "An error has occured.  The password has not been changed"
      } else { "The Linus password has been changed..."  }
     }
    }
}
<#
.Synopsis
   Add <Servername> Admins group to Active Directory.
.DESCRIPTION
   Add <Servername> Admins group to Active Directory.
.EXAMPLE
   New-ServerADGroup -ComputerName A78NTDB2
.PARAMETER ServerName 
   Name of ServerName you want to create group for.
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function New-ServerADGroup
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param
    (
        # Param1 help description
        [Parameter( 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]

        [Alias("cn")] 
        $ComputerName
     )

    Begin
    {
     if (! $ComputerName) {
       $ComputerName = read-host "Enter Server Name: "
    }
     $front = $ComputerName.Substring(0,1)
    }
    Process
    {

      # test first character of servername to determine location 
        switch -regex ($front)
        { 
        "[a]" {$OU="A-StFrancis"} 
        "[b]" {$OU="B-StMargaretMercy"} 
        "[c]" {$OU="C-GLHS"} 
        "[d]" {$OU="D-StAnthony"} 
        "[e]" {$OU="E-FPH"} 
        "[f]" {$OU="F-StJames"} 
        "[n]" {$OU="N-ACL"} 
        "[o]" {$OU="O-Alverno"} 
        "[p]" {$OU="P-StAnthony"}
        "[s]" {$OU="S-StClare"}
        "[t]" {$OU="T-TonnBlank"}
        default {
           "$ComputerName is a non-supported servername.  You will need to add it manually"
           exit
         } 
        }

        New-ADGroup -Name "$ComputerName Admins" -SamAccountName "$ComputerName Admins" -GroupCategory Security -GroupScope Global -DisplayName "$ComputerName Admins" -Path "OU=Security Groups,$OU,OU=ADS,DC=ssfhs,DC=org" -Description "$ComputerName Admins"

    }

    End
    {
    }
}

<#
.Synopsis
   Add, Remove or List users in a server's local group.  User is assumed to be a domain user.
.DESCRIPTION
   Add, Remove or List users in a server's local group.  User is assumed to be a domain user.
.PARAMETER ServerName 
   Name of remote server you want to access
.PARAMETER LocalGroupName 
   Group you want to take action on (usually administrators)
.PARAMETER DomainUser 
   Name of AD account you want to add or remove
.PARAMETER Action 
   Action you want to take.  Valid options are Add, Remove, or List.  List shows current members of local group.
.EXAMPLE
   List users that are in local administrators group on a server:
   Edit-Localgroup -ServerName a78ntdb2 -LocalGroupName administrators -Action list
 
    a78ntdb2 Local administrators Group:
 
    Linus
    Domain Admins
    Member Server Admins
    AIS Database
    A78NTDB2-SQLA
    A78NTDB2-SQLS

.EXAMPLE
   Add Domain Account to local administrators group on a server:
   Edit-Localgroup -ServerName a78ntdb2 -LocalGroupName administrators -Action add -DomainUser x15

.EXAMPLE
   Remove Domain Account from local administrators group on a server:
   Edit-Localgroup -ServerName a78ntdb2 -LocalGroupName administrators -Action Remove -DomainUser x15
#>
function Edit-Localgroup
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
   (
        # ServerName
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        $ServerName,

        # Local Group Name
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        $LocalGroupName,
        
        # DomainUser
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        $DomainUser,

        # Action
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        $Action
    )


    Begin
    {
      if (! $ServerName) {
        $ServerName =     read-host "Enter server        "
      }

      if (! $LocalGroupName) {
        $LocalGroupName = read-host "Enter group         "
      }

      if (! $Action) {
        $Action =         read-host "Add, Remove or List "
      }
    }
    Process
    {
        $objGroup = [ADSI]("WinNT://$ServerName/$LocalGroupName")

        if ($Action.ToLower() -eq "list") {
        $members = @($objGroup.psbase.Invoke("Members"))
        " "
        "$ServerName Local $LocalGroupName Group:"
        " "
        $members | foreach {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)} 
        " "
        }
        else {
        if (! $DomainUser) {
            $DomainUser = read-host "Enter domain user id "
        }

        $objADUser = [ADSI]("WinNT://$DomainUser")
        $objGroup.PSBase.Invoke($Action,$objADUser.PSBase.Path)

        }

    }
    End
    {
    }
}
<# 
.SYNOPSIS 
    Gets the pending reboot status on a local or remote computer. 
 
.DESCRIPTION 
    This function will query the registry on a local or remote computer and determine if the 
    system is pending a reboot, from either Microsoft Patching or a Software Installation. 
    For Windows 2008+ the function will query the CBS registry key as another factor in determining 
    pending reboot state.  "PendingFileRenameOperations" and "Auto Update\RebootRequired" are observed 
    as being consistant across Windows Server 2003 & 2008. 
   
    CBServicing = Component Based Servicing (Windows 2008) 
    WindowsUpdate = Windows Update / Auto Update (Windows 2003 / 2008) 
    CCMClientSDK = SCCM 2012 Clients only (DetermineIfRebootPending method) otherwise $null value 
    PendFileRename = PendingFileRenameOperations (Windows 2003 / 2008) 
 
.PARAMETER ComputerName 
    A single Computer or an array of computer names.  The default is localhost ($env:COMPUTERNAME). 
 
.PARAMETER ErrorLog 
    A single path to send error data to a log file. 
 
.EXAMPLE 
    PS C:\> Get-PendingReboot -ComputerName (Get-Content C:\ServerList.txt) | Format-Table -AutoSize 
   
    Computer CBServicing WindowsUpdate CCMClientSDK PendFileRename PendFileRenVal RebootPending 
    -------- ----------- ------------- ------------ -------------- -------------- ------------- 
    DC01           False         False                       False                        False 
    DC02           False         False                       False                        False 
    FS01           False         False                       False                        False 
 
    This example will capture the contents of C:\ServerList.txt and query the pending reboot 
    information from the systems contained in the file and display the output in a table. The 
    null values are by design, since these systems do not have the SCCM 2012 client installed, 
    nor was the PendingFileRenameOperations value populated. 
 
.EXAMPLE 
    PS C:\> Get-PendingReboot 
   
    Computer       : WKS01 
    CBServicing    : False 
    WindowsUpdate  : True 
    CCMClient      : False 
    PendFileRename : False 
    PendFileRenVal :  
    RebootPending  : True 
   
    This example will query the local machine for pending reboot information. 
   
.EXAMPLE 
    PS C:\> $Servers = Get-Content C:\Servers.txt 
    PS C:\> Get-PendingReboot -Computer $Servers | Export-Csv C:\PendingRebootReport.csv -NoTypeInformation 
   
    This example will create a report that contains pending reboot information. 
 
.LINK 
    Component-Based Servicing: 
    http://technet.microsoft.com/en-us/library/cc756291(v=WS.10).aspx 
   
    PendingFileRename/Auto Update: 
    http://support.microsoft.com/kb/2723674 
    http://technet.microsoft.com/en-us/library/cc960241.aspx 
    http://blogs.msdn.com/b/hansr/archive/2006/02/17/patchreboot.aspx 
 
    SCCM 2012/CCM_ClientSDK: 
    http://msdn.microsoft.com/en-us/library/jj902723.aspx 
 
.NOTES 
    Author:  Brian Wilhite 
    Email:   bwilhite1@carolina.rr.com 
    Date:    08/29/2012 
    PSVer:   2.0/3.0 
    Updated: 05/30/2013 
    UpdNote: Added CCMClient property - Used with SCCM 2012 Clients only 
             Added ValueFromPipelineByPropertyName=$true to the ComputerName Parameter 
             Removed $Data variable from the PSObject - it is not needed 
             Bug with the way CCMClientSDK returned null value if it was false 
             Removed unneeded variables 
             Added PendFileRenVal - Contents of the PendingFileRenameOperations Reg Entry 
#> 
Function Get-PendingReboot 
{ 

 
[CmdletBinding()] 
param( 
  [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)] 
  [Alias("CN","Computer")] 
  [String[]]$ComputerName="$env:COMPUTERNAME", 
  [String]$ErrorLog 
  ) 
 
Begin 
  { 
    # Adjusting ErrorActionPreference to stop on all errors, since using [Microsoft.Win32.RegistryKey] 
        # does not have a native ErrorAction Parameter, this may need to be changed if used within another 
        # function. 
    $TempErrAct = $ErrorActionPreference 
    $ErrorActionPreference = "Stop" 
  }#End Begin Script Block 
Process 
  { 
    Foreach ($Computer in $ComputerName) 
      { 
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
               
            # Creating Custom PSObject and Select-Object Splat 
                        $SelectSplat = @{ 
                            Property=('Computer','CBServicing','WindowsUpdate','CCMClientSDK','PendFileRename','PendFileRenVal','RebootPending') 
                            } 
            New-Object -TypeName PSObject -Property @{ 
                Computer=$WMI_OS.CSName 
                CBServicing=$CBSRebootPend 
                WindowsUpdate=$WUAURebootReq 
                CCMClientSDK=$SCCM 
                PendFileRename=$PendFileRename 
                                PendFileRenVal=$RegValuePFRO 
                RebootPending=$Pending 
                } | Select-Object @SelectSplat 
 
          }#End Try 
 
        Catch 
          { 
            Write-Warning "$Computer`: $_" 
             
            # If $ErrorLog, log the file to a user specified location/path 
            If ($ErrorLog) 
              { 
                Out-File -InputObject "$Computer`,$_" -FilePath $ErrorLog -Append 
 
              }#End If ($ErrorLog) 
               
          }#End Catch 
           
      }#End Foreach ($Computer in $ComputerName) 
       
  }#End Process 
   
End 
  { 
    # Resetting ErrorActionPref 
    $ErrorActionPreference = $TempErrAct 
  }#End End 
   
}#End Function
<#
.Synopsis
   Get the User Name from Active Directory by supplying the User ID.
.DESCRIPTION
   Long description
.EXAMPLE
   Get-Name -UserID x15

    Matherly Toby
#>
# function name: grab username from AD user ID
# syntax: name <userid>
function Get-Name
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $UserID
    )

    Begin
    {
    }
    Process
    {

      echo " " 
      (Get-ADUser $UserID).name 
      echo " " 
    }
    End
    {
    }
}


<#
.Synopsis
   Get the User ID from Active Directory by supplying Last Name.
.DESCRIPTION
   Get the User ID from Active Directory by supplying Last Name.  Can also supply all or part of First name to narrow the search
.EXAMPLE
   get-userid -Last Matherly
 
givenname                                                surname                                                  Samaccountname                                         
---------                                                -------                                                  --------------                                         
Toby                                                     Matherly                                                 x15                                                 
.EXAMPLE
   PS C:\scripts> Get-UserID -Last porter -First d
 

givenname                                                surname                                                  Samaccountname                                         
---------                                                -------                                                  --------------                                         
David                                                    Porter                                                   adhp019                                                
Debra                                                    Porter-Smith                                             fdxp2    
#>
function Get-UserID
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Last Name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Last,

        # First Name
        $First
    )

    Begin
    {
    }
    Process
    {
      $Last = $Last + "*"
      echo " " 
      if (! $First) { 
         Get-ADUser -Filter 'Surname -like $Last' | Select-Object givenname, surname, Samaccountname
      } else {
         $First = $First + "*"
         Get-ADUser -Filter 'Surname -like $Last -and givenname -like $First' | Select-Object givenname, surname, Samaccountname
      }
      echo " " 
    }
    End
    {
    }
}
<#
.Synopsis
   Connect to Cisco VPN.
.DESCRIPTION
   Long description
.EXAMPLE
   Connect-Cisco -Connect vpn
#>
function Connect-Cisco
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Connect help description
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Connect
    )

 if (! $Connect) {
   "You will connect to inin...if you need to connect to admin hub use the -connect flag:"
   "connect-cisco -connect admin"
 }
 & 'C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe' 'disconnect'
 if ($Connect -eq "admin") {
    $connection_string='vpn.admin.hosted-inin.com'
    & 'C:\Program Files (x86)\RSA SecurID Software Token\SecurID.exe'
    & 'C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe' 'connect' 'vpn.admin.hosted-inin.com'
    get-process -Name "SecurID" | %{ $_.CloseMainWindow() }
 } else {
    & 'C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe' 'connect' 'vpn.inin.com'
 }

}
<#
.Synopsis
   Connect to Cisco VPN.
.DESCRIPTION
   Long description
.EXAMPLE
   Connect-Cisco -Connect vpn
#>
function Disconnect-Cisco
{

 & 'C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe' 'disconnect'

}
# Alias definitions
New-Alias -Name qc -value Test-ServerBuild
New-Alias -Name sign -value Set-Signature
New-Alias -Name egh -value Backup-File
#– Need to be included at the end of your *psm1 file.
Export-ModuleMember -alias * -function *

