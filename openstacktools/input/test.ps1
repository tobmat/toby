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