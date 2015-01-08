#ps1
#Establish COM Connection for Logging
$port= new-Object System.IO.Ports.SerialPort COM1,9600,None,8,one
$port.open()
$port.WriteLine('Setting local admin password')
$strPassword = "Interactive2014"
$objUser = [ADSI]("WinNT://./Administrator, user")
$objUser.psbase.invoke("SetPassword",$strPassword)
$port.WriteLine('Finished setting local admin password')
Set-ExecutionPolicy Unrestricted -Force

# Create Folders
Write-Host 'Creating I3 Folders'
$port.WriteLine('Creating c:\tmp folder')
New-Item -ItemType directory -Path C:\tmp -erroraction SilentlyContinue

# Set Nic Order, relies on nvspbind.exe
Write-Host 'Setting NIC Order'
$port.WriteLine('Setting NIC Order')
$prefix = "Ethernet "
$netAdapters = Get-NetAdapterHardwareInfo | Sort-Object Slot,Device
$i = 1
foreach ($netAdapter in $netAdapters){
    $interface = $netadapter | Get-NetAdapter
    $old = $interface.Name
    $newName = $prefix + $i
    if ($i -eq 1) {$newName = 'Ethernet'}
    else {$newName = $prefix + $i}
    $i++
    $interface | Rename-NetAdapter -NewName $newName
    Write-Host "Rename" $old "to:" $newName
    c:\tools\nvspbind.exe /-- $newName ms_tcpip
}

# Download Files
Write-Host 'Downloading Files'
$port.WriteLine('Downloading Files...')
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$client = new-object System.Net.WebClient
$port.WriteLine('Downloading join.domain.ps1')
#$port.WriteLine('Downloading nic_order.ps1...')
#$client.DownloadFile( 'http://swift.oncaas.com/devops/nic_order.ps1', 'c:\tmp\nic_order.ps1' )
$client.DownloadFile( 'http://swift.oncaas.com/devops/join_domain.ps1', 'c:\tmp\join_domain.ps1' )
$port.WriteLine('Downloading SQL_Config.ini')
$client.DownloadFile( 'http://swift.oncaas.com/devops/SQL_Config.ini', 'c:\tmp\SQL_Config.ini' )
$port.WriteLine('Downloading sql2014_install.ps1...')
$client.DownloadFile( 'http://swift.oncaas.com/devops/sql2014_install.ps1', 'c:\tmp\sql2014_install.ps1' )
$port.WriteLine('Downloading sql_server_2014_standard_edition_x64.iso...')
$client.DownloadFile( 'http://swift.oncaas.com/devops/sql_server_2014_standard_edition_x64.iso', 'c:\tmp\sql_server_2014_standard_edition_x64.iso' )
$port.WriteLine('Downloading sqlbootscript.xml...')
$client.DownloadFile( 'http://swift.oncaas.com/devops/sqlbootscript.xml', 'c:\tmp\sqlbootscript.xml' )

# Run Scripts Before Restart
$port.WriteLine('Running join domain script.')
c:\tmp\join_domain.ps1
$port.WriteLine('Running Nic Order script.')
c:\tmp\nic_order.ps1

$port.WriteLine('Add scheduled tasks to install sql...')
#schtasks.exe /create /TN bootscript /SC ONSTART /TR 'powershell.exe -ExecutionPolicy Bypass -noninteractive -File C:\tmp\sql2014_install.ps1' /RU SYSTEM

schtasks.exe /create /TN bootscript /XML C:\tmp\sqlbootscript.xml

#$trigger = New-JobTrigger -AtStartup -RandomDelay 00:00:30
#Register-ScheduledJob -Trigger $trigger -FilePath C:\tmp\sql2014_install.ps1 -Name bootscript

$port.WriteLine('Reboot computer to join domain and install sql...')
shutdown /r /f
#>