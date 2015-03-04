# Name   : sql2014_install.ps1
# Purpose: install SQL Server
# Date   : 12/16/2014 
# Author : Toby Matherly
#

##SA account
##$sapw= read-host "Enter SA password (12 long no special characters):"
#$sapw1 = Get-Credential -Credential sa
#$sapw= $sapw1.GetNetworkCredential().password

$sapw= 'Interactive2014'

$configfile="C:\tmp\SQL_Config.ini"

$mountResult = Mount-DiskImage -ImagePath c:\tmp\sql_server_2014_standard_edition_x64.iso  -PassThru
$drive = ($mountResult | Get-Volume).DriveLetter


& "${drive}:\setup.exe" /SAPWD=$sapw /CONFIGURATIONFILE=$configfile /IACCEPTSQLSERVERLICENSETERMS 

###& 'e:\setup.exe' /SAPWD=$sapw /CONFIGURATIONFILE=$configfile /IACCEPTSQLSERVERLICENSETERMS 

DisMount-DiskImage -ImagePath c:\tmp\sql_server_2014_standard_edition_x64.iso

# Delete schedule task after it runs
SchTasks /Delete /TN "bootscript" /F