
# Move AD object to another location in AD
$group="csentdti1 admins"
Move-ADObject "CN=$group,OU=Security Groups,OU=A-StFrancis,OU=ADS,DC=ssfhs,DC=org" -TargetPath "OU=Security Groups,OU=O-Alverno,OU=ADS,DC=ssfhs,DC=org"

 $error.clear()

# Hash table example
$hash = $null
$hash = @{}
$proc = get-process | Sort-Object -Property name -Unique
 
foreach ($p in $proc)
{
 $hash.add($p.name,$p.id)
}
$hash | ogv


$erroractionpreference = "SilentlyContinue"

powershell.exe -version 2 -file scriptname.ps1 --> test a script to see if it will run in powershell version 2

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


   if (! $ComputerName) {
       $ComputerName = read-host "Enter Server Name: "
    }


    if ($error.Count -gt 0) {}
     $error.clear()

 $log="$logdir\" + $server + "_cleanup_log.txt"
 $elog="$logdir\ERROR_" + $server + "_log.txt"

  $error > $elog

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
Get-Content c:\scripts\data\test.txt | ForEach-Object { $_ -split "[, -]"} | Select-String "[A-Z]" |