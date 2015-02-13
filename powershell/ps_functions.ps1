# function bye: hold history over from prior session, must use instead of exit
# syntax: bye
### Test for diretory to hold history file and create it if it's not there
#Import-Module -Name \\oaintpwshell\scripts\modules\tm_handy\tm_handy.psm1 -Verbose
#if (!(Test-Path ~\PowerShell -PathType Container))
#{   New-Item ~\PowerShell -ItemType Directory
#}

#$MaximumHistoryCount = 31KB
#function bye 
#{   Get-History -Count $MaximumHistoryCount |Export-CSV ~\PowerShell\history.csv
#    exit
#}
### Test to see if history file exists, if so add it to the history of the current session
#if (Test-path ~\PowerShell\History.csv)
#{   Import-CSV ~\PowerShell\History.csv |Add-History
#}

# function egh: backup scripts to history dir
# syntax: egh <filename>
function egh([string]$a)
{
 $ts = (get-date -uformat %Y%m%d%H%M)

 if ("$a" -like "*.ps1") {
  if ("$a" -like "*PowerShell_profile*") {
    copy $a history\PowerShell_profile-$ts }
  else {
    copy $a history\$a-$ts }}
 else {
  copy c:\scripts\$a.ps1 c:\scripts\history\$a.ps1-$ts
 }
}

# function grep: emulate Unix grep command
# syntax: grep <pattern> <filename>
function grep($a,$b) {
  select-string -path $b -pattern $a -ErrorAction SilentlyContinue -Exclude *~
}

# function histd: get command history for current session
# syntax: histd
function histd() {
  get-history -count 500| ft id,endexecutiontime,commandline -auto | more
}

# function ilo: get ilo info
# syntax: ilo <ilo name>
#function ilo([string]$a) 
#{
#  echo " "
#  $url = "http://$a.ssfhs.org/xmldata?item=All"
#  $feed=[xml](new-object system.net.webclient).downloadstring($url)
#  "iLo type: " + $feed.RIMP.mp.pn 
#  "firmware: " + $feed.RIMP.mp.fwri
#  "-------------------------------"
#  "| Current firmware iLo : 1.91 |" 
#  "| Current firmware iLo2: 2.07 |" 
#  "| Current firmware iLo3: 1.28 |" 
#  "-------------------------------"
#  echo " "
#}

# Used in info function below
$TotalGB = @{Name="Capacity(GB)";expression={[math]::round(($_.Capacity/ 1073741824),2)}}
$FreeGB = @{Name="FreeSpace(GB)";expression={[math]::round(($_.FreeSpace / 1073741824),2)}}
$FreePerc = @{Name="Free(%)";expression={[math]::round(((($_.FreeSpace / 1073741824)/($_.Capacity / 1073741824)) * 100),0)}}

# function info: get remote system info
# syntax: info <server name>
function info([string]$a)
{

if(-not(Test-Connection -ComputerName $a -Count 1 -Quiet)){
 echo "Could not contact $a"
}
else {

#get-wmiobject -computername $a win32_computersystem
$wmic=get-wmiobject -computername $a win32_computersystem
echo " "
"Server Name         : " + $wmic.Name
"Server Make         : " + $wmic.Manufacturer
"Server Model        : " + $wmic.Model
"Domain              : " + $wmic.Domain
"Total Usable Memory : " + [math]::round($($wmic.TotalPhysicalMemory/1gb)) + "GB"
echo " "
"Serial Number       : " + (Get-WmiObject -computername $a win32_bios).serialnumber
echo " "
#echo "BIOS Firmware" 
$wmib=gwmi win32_bios -computername $a
#"Release Date        : " + (Get-WmiObject -computername $a win32_bios).releasedate | %{$_.split(".")[0]}
"BIOS Firmware R Date: " + $wmib.ConvertToDateTime($wmib.releasedate)

echo " "
$ip = nslookup $a | Select-String Address | ForEach-Object {$_.Line} | select-object -last 1 | %{$_.split(":")[1]}
$ip = $ip.TrimStart("  ")
"IP Address          : " + $ip
echo " "
$wmiw=get-wmiobject -computername $a win32_operatingsystem
$sname=$wmiw.Name | out-string | %{$_.split("|")[0]} 
"Windows OS          : " + $sname + $wmiw.OSArchitecture 
"OS Version          : " + $wmiw.version 
"Service Pack        : " + $wmiw.servicepackmajorversion
echo " "
#"Install Date        : " + ([WMI]'').ConvertToDateTime((Get-WmiObject Win32_OperatingSystem -computername $a).InstallDate).DateTime
echo " "
$wmi=gwmi win32_operatingsystem -computername $a
#"Last Reboot         : " + (gwmi win32_operatingSystem -computer $a).lastbootuptime |  %{$_.split(".")[0]}
"Install Date        : " + $wmi.ConvertToDateTime($wmi.InstallDate)
"Last Reboot         : " + $wmi.ConvertToDateTime($wmi.LastBootUpTime)
echo " "
#$front = $a.Substring(0,3)
#$back = $a.Substring(5)
#$iloname = $front + "il" + $back
#if(Test-Connection -ComputerName $iloname -Count 1 -Quiet){
#   echo " "
#  $url = "http://$iloname.ssfhs.org/xmldata?item=All"
#  $feed=[xml](new-object system.net.webclient).downloadstring($url)
#  "iLo Name            : " + $iloname
#  "iLo type            : " + $feed.RIMP.mp.pn 
#  "firmware            : " + $feed.RIMP.mp.fwri
#  "-------------------------------"
#  "| Current firmware iLo : 1.91 |" 
#  "| Current firmware iLo2: 2.07 |" 
#  "| Current firmware iLo3: 1.28 |" 
#  "-------------------------------"
#  echo " "
#}

# Get current space info from server
$volumes = Get-WmiObject -computer $a win32_volume | Where-object {$_.Capacity -ne $null}
$volumes | Select Name, Label, $TotalGB, $FreeGB, $FreePerc | Format-Table -AutoSize

# Display pagefile location
Get-WmiObject -class Win32_PageFileSetting -ComputerName $a | select name

echo " "
echo "Processor(s)" 
echo " "
get-wmiobject -computername $a win32_processor | select-object Name
 }
} # end of info function

# function push_script: copy scripts to S drive for team access
# syntax: push_script <scriptname>
#function push_script([string]$a)
#{
#  $sdrive = "\\oaintfile2\Shared\Groups"
#  $hdrive = "\\oaintfile2\x15$"
#  if (! $a) {
#    copy c:\scripts\*.ps1 $sdrive\infrastructure\powershell\scripts
#    copy $profile $sdrive\infrastructure\powershell\scripts
#
#  }
#  else {
#
#   if ("$a" -like "*.ps1") {
#    if ("$a" -like "*PowerShell_profile*") {
#       copy $profile $sdrive\infrastructure\powershell\scripts }
#    else {
#       copy c:\scripts\$a $sdrive\infrastructure\powershell\scripts }}
#   else {    
#    copy c:\scripts\$a.ps1 $sdrive\infrastructure\powershell\scripts
#   }
#  }
#}

# function pull_script: copy scripts from S drive to local dir for use
# syntax: pull_script <scriptname>
#function pull_script([string]$a)
#{
#  $sdrive = "\\oaintfile2\Shared\Groups"
#  if (! $a) {
#    copy $sdrive\infrastructure\powershell\scripts\*.ps1 c:\scripts\
#    copy $sdrive\infrastructure\powershell\scripts\Microsoft.Powershell_profile.ps1 $profile
#
#  }
#  else {
#
#   if ("$a" -like "*.ps1") {
#    if ("$a" -like "*PowerShell_profile*") {
#       copy $sdrive\infrastructure\powershell\scripts\Microsoft.Powershell_profile.ps1 $profile }
#    else {
#       copy $sdrive\infrastructure\powershell\scripts\$a c:\scripts\ }}
#   else {    
#    copy $sdrive\infrastructure\powershell\scripts\$a.ps1 c:\scripts\
#   }
#  }
#}
#
# function rdp: simplify remote desktop
# syntax: rdp <server name>
function rdp([string]$a)
{
  mstsc /v:$a;
}

# function tport: Test whether a port is open on a remote server
# syntax: tport -TargetHost <servername> -TartgetPort <portnumber>
function tport {
[cmdletbinding()]
param(                        

[parameter(mandatory=$true)]
[string]$TargetHost,                        

[parameter(mandatory=$true)]
[int32]$TargetPort,                        

[int32] $Timeout = 10000                        

)                        

$outputobj = New-Object -TypeName PSobject            

$outputobj | Add-Member -MemberType NoteProperty -Name TargetHostName -Value $TargetHost            

if(test-Connection -ComputerName $TargetHost -count 2) {
    $outputobj | Add-Member -MemberType NoteProperty -Name TargetHostStatus -Value "ONLINE"
} else {
    $outputobj | Add-Member -MemberType NoteProperty -Name TargetHostStatus -Value "OFFLINE"
}            

$outputobj | Add-Member -MemberType NoteProperty -Name PortNumber -Value $targetport            

$Socket = New-Object System.Net.Sockets.TCPClient
$Connection = $Socket.BeginConnect($Targethost,$TargetPort,$null,$null)
$Connection.AsyncWaitHandle.WaitOne($timeout,$false)  | Out-Null            

if($Socket.Connected -eq $true) {
    $outputobj | Add-Member -MemberType NoteProperty -Name ConnectionStatus -Value "Success"
} else {
    $outputobj | Add-Member -MemberType NoteProperty -Name ConnectionStatus -Value "Failed"
}            

$Socket.Close | Out-Null
$outputobj | select TargetHostName, TargetHostStatus, PortNumber, Connectionstatus | ft -AutoSize            

}

## function vi: invoke VIM script for editing
## syntax: vi <scriptname>
#function vi([string]$a)
#{
# if ("$a" -like "*.ps1") { 
# invoke-item $a }
# else {
#  if (!(Test-Path c:\scripts\$a.ps1)) {
#     New-Item c:\scripts\$a.ps1 -type file
#  }
#  invoke-item c:\scripts\$a.ps1
# }
#}

## function name: grab username from AD user ID
## syntax: name <userid>
#function name($n) {
# if (! $n) { $n = read-host "Enter AD user ID: " }
# echo " " 
# (Get-ADUser $n).name 
# echo " " 
#}

## function id: grab userid from AD user Lastname
## syntax: id <lastname>* NOTE - Must use * as wildcard at the end
#function id($i) {
# if (! $i) { $n = read-host "Enter AD user last name: " }
# echo " " 
# Get-ADUser -Filter 'name -like $i' | select-object SamAccountName,name 
# echo " " 
#}
#
## function phone: get phone number using AD user ID
## syntax: phone <userid>
#function phone($p) {
# if (! $p) { $p = read-host "Enter AD user ID: " }
# echo " " 
# Invoke-Sqlcmd -Query "SELECT [LoginID],[LastName],[FirstName],[Num],[Ext] FROM [PhoneList_Prod].[dbo].[phones$] where [loginID]='$p'" -ServerInstance "oaintdbvs9\sql9" -database PhoneList_Prod
# echo " " 
#}

# function logcheck: list last 5 system messages from a server
# syntax: logcheck <servername>
function logcheck([string]$a)
{
  if (! $a) { $a = read-host "Enter Server Name: " }
  $loginfo = get-eventlog -computername $a -log System -newest 5 -EntryType error
  $loginfo | format-list -property timewritten,source,eventID,MachineName,Entrytype, message
}

# function invoke-speech: reads text out loud
# syntax: echo "hello" | invoke-speech
$voice = New-Object -ComObject SAPI.SPVoice
$voice.Rate = -3
 
function invoke-speech
{
  param([Parameter(ValueFromPipeline=$true)][string] $say )

  process
 {
  $voice.Speak($say) | out-null;    
 }
}
 
new-alias -name out-voice -value invoke-speech -ErrorAction silentlycontinue;

## function findh: search command history
## syntax: findh <search-string>
#function findh([string]$a) 
#{ get-history -c 2000 | where-object {$_.commandLine -like "*$a*"} }
#
## function space: display space info on server
## syntax: space <servername>
#$TotalGB = @{Name="Capacity(GB)";expression={[math]::round(($_.Capacity/ 1073741824),2)}}
#$FreeGB = @{Name="FreeSpace(GB)";expression={[math]::round(($_.FreeSpace / 1073741824),2)}}
#$FreePerc = @{Name="Free(%)";expression={[math]::round(((($_.FreeSpace / 1073741824)/($_.Capacity / 1073741824)) * 100),0)}}
#
## Generate a random password
## Usage: random-password <length>
Function random-password ($length = 15)
{
        $punc = 46..46
        $digits = 48..57
        $letters = 65..90 + 97..122
 
        # Thanks to
        # https://blogs.technet.com/b/heyscriptingguy/archive/2012/01/07/use-pow
        $password = get-random -count $length `
                -input ($punc + $digits + $letters) |
                        % -begin { $aa = $null } `
                        -process {$aa += [char]$_} `
                        -end {$aa}
 
        return $password
}

function space([string]$a) {
$volumes = Get-WmiObject -computer $a win32_volume | Where-object {$_.Capacity -ne $null}
$volumes | Select SystemName, Label, $TotalGB, $FreeGB, $FreePerc | Format-Table -AutoSize
}

# emulate Unix lt command (list files in modified date order)
# Usage: lt
Function lt
{
 get-childitem | sort lastwritetime
}

# list members from AD group
# Usage: adg <"group name">
function adg([string]$a)
{
 $group=Get-ADGroup "$a"
 " "
 "AD Group: $a"
 "Members:"
 foreach ($member in Get-ADGroupMember $group) { $member.name }
 " "
}
function oncall($search)
{
$heatinfo=Invoke-Sqlcmd -InputFile \\oaintpwshell\scripts\sql\current_oncall.sql -ServerInstance oaintheatdb

if (! $search) {
 $heatinfo | more
}
else
{ 
 for ($i=0; $i -le $heatinfo.Length; $i++) 
 { 
  if ($heatinfo[$i].GroupDesc -like "*$search*" -or $heatinfo[$i].GroupName -like "*$search*") 
   { 
     $heatinfo[$i]
     #$heatinfo[$i].GroupName.tostring() + ", " + $heatinfo[$i].GroupDesc.tostring() + ", " + $heatinfo[$i].Supervisor.tostring()
   } 
 }
}
}
function qc($server)
{
 "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 # Test that Forefront has been installed 
 if (Get-process -ComputerName $server -Name MsMpEng -ErrorAction silentlycontinue ) 
    {"Wahoo! Forefront has been installed!!!"}
 else
    { "Danger!!! Forefront has not been installed...." }
 # Test that Netbackup has been installed 
 if (Get-service -ComputerName $server -Name "Netbackup Client*" -ErrorAction silentlycontinue ) 
    {"Yes and it counts! Netbackup has been installed!!!"}
 else
    { "Emergency!!! Netbackup has not been installed...." }
 " "
 "Check for reboot schedule"
  Get-SchedTasks -ComputerName $server | %{if ($_.name -like "*reboot*" ) { $_ } }
 "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}


function diff($file1, $file2)
{
 compare (Get-Content $file1) (Get-Content $file2)
}
