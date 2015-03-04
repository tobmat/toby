
# Move AD object to another OU in AD
$group="csentdti1 admins"
Move-ADObject "CN=$group,OU=Security Groups,OU=A-StFrancis,OU=ADS,DC=ssfhs,DC=org" -TargetPath "OU=Security Groups,OU=O-Alverno,OU=ADS,DC=ssfhs,DC=org"

 $error.clear()

# Hash table example with for loop
$hash = $null
$hash = @{}
$proc = get-process | Sort-Object -Property name -Unique
foreach ($p in $proc)
{
 $hash.add($p.name,$p.id)
}
$hash | ogv


#Set error action
$erroractionpreference = "SilentlyContinue"

# test a script to see if it will run in powershell version 2
powershell.exe -version 2 -file scriptname.ps1 


# switch example
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


#test variable is set and prompt for value
   if (! $ComputerName) {
       $ComputerName = read-host "Enter Server Name: "
    }


# work with error variable
    if ($error.Count -gt 0) {}
     $error.clear()


# format date into variable
$ts = (get-date -uformat %Y%m%d%H%M)


  get-wmiobject -computername A78NTDB1 win32_processor

  $wmib=gwmi win32_bios -computername $_.dnshostname
  $wmib.ConvertToDateTime($wmib.releasedate)

  # Citrix Scripts
  \\oaintfile2\shared\Groups\Source\Epic\Installs\scripts\powershell



#Load list of names from adresults into an array
 foreach ($record in $ADresult) { $resultsarray+=$record.name }

 #run invoke command against an array, pass arguements to a script
 Invoke-Command -ComputerName $resultsarray -FilePath C:\scripts\temp.ps1 -ArgumentList $day,$hour,$minute -SessionOption (New-PSSessionOption -NoMachineProfile)

 #parse a comma delimited file with spaces after name
Get-Content c:\scripts\data\test.txt | ForEach-Object { $_ -split "[, -]"} | Select-String "[A-Z]" |=

#WMI commands:

gwmi -List win32*  # list all win32 options

get-wmiobject -computername A78NTDB1 win32_operatingsystem
get-wmiobject -computername A78NTDB1 win32_computersystem
get-wmiobject win32_BIOS | select SerialNumber  #get serial number from PC


# get eventlog info

Get-EventLog -LogName application -Newest 3
Get-EventLog -logname application | where { $_.message -match 'Security' }
Get-EventLog -logname application -InstanceId 1001 -After 20110801
Get-EventLog -logname application -InstanceId 1001
Get-EventLog -LogName system -Newest 3
Get-EventLog -LogName system -Newest 9 | Format-List -property * | more
Get-EventLog -LogName system -Newest 3 -ComputerName A78NTDB1 | Format-List -Property * | more
get-eventlog system -computername a78ntdb1 -newest 1 -entry error | ft timewritten,source,eventid,message
-wrap –auto

# WRITE TO A FILE
#1.	Use arrows > or >> (append) – default to unicode
#2.	Out-File –FilePath C:\scripts\files\*.* -encoding ascii –width ### 
#3.	ConvertTo-Csv -NoTypeInformation

# out of memory error

#outofmemoryexception – enter this command on destination server:
set-item wsman:localhost\Shell\MaxMemoryPerShellMB 512
#(default is 150)

select-string # grep eqivalent
select-object –last # <- tail, where # is number of lines
select-object –first # <- head, where # is number of lines

Get-Content c:\scripts\test.txt | Measure-Object # like grep -c

%{$_.split("|")[0]} #– (like shell cut) where “|” is the delimiter and [0] is the reference

#Powershell remoting:
Enable-PSRemoting -force
Invoke-Command -ComputerName a78ntnuer1 –FilePath c:\scripts\Test.ps1
Invoke-Command -ComputerName (get-content c:\scripts\servers.txt) –FilePath c:\scripts\Test.ps1

etsn # alias to enter remote session
exsn # alias to exit remote session
#Get to servers on different domain:
Enter-PSSession ihpntpstest.indianaheart.local -Credential indianaheart.local\x15

#Get list of apps installed on a server:
Get-WmiObject -Class Win32_Product -ComputerName oaintpwshell  | Format-Wide -Column 1

#Get age of the server via windows install date:
([WMI]'').ConvertToDateTime((Get-WmiObject Win32_OperatingSystem -computername amvntsmsdp).InstallDate)

#Get uptime of server:
(gwmi win32_operatingSystem -computer remotePC).lastbootuptime

#Get list of servers and OS’s in AD:
PS C:\scripts> Get-Content c:\scripts\data\servers.txt | foreach-object { Get-ADComputer $_ -properties * } | sort-object -property operatingsystem,name | ft name,operatingsystem

#Create a file with all servers in AD:
PS C:\scripts> Get-ADComputer -Filter { (Name -like "a*nt*") -or (Name -like "a*mf*") -or (name -like "oaint*") -or (name -like "oaimf*") -or (Name -like "b*nt*") -or (Name -like "b*mf*") -or (Name -like "c*nt*") -or (Name -like "d*nt*") -or (Name -like "e*nt*") -or (Name -like "f*nt*") -or (Name -like "m*nt*") -or (Name -like "n*nt*") -or (Name -like "p*nt*") -or (Name -like "p*vm*") -or (Name -like "s*nt*") -or (Name -like "t*nt*")} -properties dnshostname | sort dnshostname | ft name > c:\scripts\data\servers.txt

#Video driver info on a server:
gwmi -computer oaintpwshell win32_videocontroller | select DeviceID, Name,DriverVersion|ft –a
pnputil #– executable to install driver from command line

Get-WmiObject -Class Win32_LogicalDisk -Filter 'DriveType=3'  ##<<< list real harddrives

#PowerCLI (VM commands):
add-pssnapin "VMware.VimAutomation.Core"
Connect-VIServer -Server oaintvcc02
Disconnect-VIServer -Server oaintvcc02

#SQL powershell commands:
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -argumentList oaintdbt4
$server.logins | Select-Object name
$server.Databases | Select-Object name
$server.information
Add-PSSnapin sqlserverprovidersnapin100
add-pssnapin sqlservercmdletsnapin100
SELECT [LoginID],[LastName],[FirstName],[Num],[Ext] FROM [PhoneList_Prod].[dbo].[phones$] where [loginID]='x08'
Invoke-Sqlcmd -Query "SELECT [LoginID],[LastName],[FirstName],[Num],[Ext] FROM [PhoneList_Prod].[dbo].[phones$] where [loginID]='$testid'" -ServerInstance "oaintdbvs2\sql2" -database PhoneList_Prod

#Start service on remote computer:
restart-service -whatif -InputObject (get-service -displayname "Healthmatics*" -cn SCVNTSQL1)

#Retreive password text after –assecurestring read-host
[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))

#Environment variables
$env:COMPUTERNAME 

#AD Recycle Bin
#http://falsufyani.wordpress.com/2011/05/28/restore-deleted-computer-account-using-ad-recycle-bin/

Get-ADObject -SearchBase "CN=Deleted Objects,DC=SSFHS,DC=ORG" -ldapFilter:"(msDs-lastKnownRDN=A78NTDB1)" -IncludeDeletedObjects -Properties lastKnownParent

Get-ADObject -Filter {objectguid -eq "babd8fbd-c083-4085-a044-38fd35536fe3"} -IncludeDeletedObjects | Restore-ADObject

#Convert comma delimited list of strings to newline delimited
Get-Content c:\scripts\data\test.txt | ForEach-Object { $_ -split "[, -]"} | Select-String "[A-Z]"

#DNS cmdlets
#Grab entry
Get-DnsRecord -ZoneName 10.in-addr.arpa -Server oaintaddc1 -Name 116.7.90.10.in-addr.arpa
#Grab entry and then remove it
Get-DnsRecord -ZoneName ssfhs.org -Server oaintaddc1 -Name oaintextdb | Remove-DnsObject

#Get all info from format-table (ft)
Invoke-Sqlcmd -InputFile .\temp2.sql -ServerInstance oaintdbvs9\sql9 | ft -AutoSize | Out-String -Width 4096 | Out-File .\loginfo.txt

#Here is a simple one-liner that saves the current command history to file:
Get-History | Export-Clixml $env:temp\myHistory.xml 
#Once you start a new PowerShell console or ISE editor instance, you can load the saved history back into PowerShell:
Import-Clixml $env:temp\myHistory.xml | Add-History 

#UPDATE Path variables

$env:PSModulePath -split ';'

$env:PSModulePath += ';g:\mypersonalmodules'

#refresh modules in powershell 3 and above
Get-Module -ListAvailable -Refresh 

#CIM sessions
$session = New-CimSession –ComputerName localhost
$os = Get-CimInstance –ClassName Win32_OperatingSystem –CimSession $session
$bios = Get-CimInstance -ClassName Win32_BIOS -CimSession $session 
