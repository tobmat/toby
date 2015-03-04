# Name   : svr_menu.ps1
# Purpose: Menu driven script to execute server build scripts
# Date   : 11/30/2012 
# Author : Toby Matherly (x15)
# Detail : see below
# TODO   : Add copy of windows task files for reboot
# TODO   : Add opening of NBU request form

$strComputer=$env:computername
$choice="nothing"
clear
while ($choice -ne "x")
{
 "===================="
 "= Server Menu 2.0  ="
 "===================="

 "1. Join Domain (will reboot server)"
 "2. Server Baseline"
 "3. Netbackup 7.1 plus NBU 7.1.0.3 Upgrade (x64 support only)"
 "4. Forefront Install"
 "5. Combo (baseline, NBU, and forefront)"
 "6. Change Execution Policy to Allsigned"
 "7. Configure Insight Manager"
 "8. Install SCCM"
 "9. Leftovers (disable LMhosts, IE ESC for Admins, and UAC; create Reboot task; reboot)"
 "x. Exit"
 " "
 $choice = read-host "What would you like to do?"
 " "
 switch -regex ($choice) {
     "[1]" { 
	    "===================== "
            "Join server to domain"
	    "===================== "
            " "
            if (test-path -Path "\\ssfhs\shared\Oshared\Groups\Source\")
            {
              "Server is already joined to the domain...."
            }
            else {
              \\oaintpwshell\scripts\svr_join_domain.ps1
            }
           }
     "[2]" { 
	    "================ "
            "Baseline server"
	    "================ "
            " "
            \\oaintpwshell\scripts\svr_baseline.ps1 $strComputer
           }
     "[3]" { 
	    "================= "
            "Netbackup install"
	    "================= "
            " "
            if (test-path -Path "HKLM:\software\veritas\netbackup\currentversion")
            {
              "It appears Netbackup has already been installed..."
              $mversion = (Get-ItemProperty -Path "HKLM:\software\veritas\netbackup\currentversion").minorversion 
              $cversion = (Get-ItemProperty -Path "HKLM:\software\veritas\netbackup\currentversion").version
              "=================="
              "Version " + $cversion + ".0." + $mversion
              "=================="
            }
            else
            {
              \\oaintpwshell\scripts\svr_nbu_install.ps1
            }
           }
     "[4]" { 
	    "================= "
            "Forefront install"
	    "================= "
            " "
            if ((Get-Process -Name msseces  -ErrorAction silentlycontinue).processname -eq "msseces") 
            {  "Forefront has already been installed..." }
            else { 
              \\oaintsccmc\packages\fep2010\client\fep_2010.exe
              wait-event -Timeout 60
              if ((Get-Process -Name msseces  -ErrorAction silentlycontinue).processname -eq "msseces") 
              {  "The forefront install has completed..." }
              else { "The forefront process isn't running, need to check!" }
            }
           }

     "[5]" { 
	    "================ "
            "Baseline server"
            "================ "
            " "
            \\oaintpwshell\scripts\svr_baseline.ps1 $strComputer
	    "================= "
            "Netbackup install"
	    "================= "
            " "
            if (test-path -Path "HKLM:\software\veritas\netbackup\currentversion")
            {
              "It appears Netbackup has already been installed..."
              $mversion = (Get-ItemProperty -Path "HKLM:\software\veritas\netbackup\currentversion").minorversion 
              $cversion = (Get-ItemProperty -Path "HKLM:\software\veritas\netbackup\currentversion").version
              "=================="
              "Version " + $cversion + ".0." + $mversion
              "=================="
            }
            else
            {
              \\oaintpwshell\scripts\svr_nbu_install.ps1
            }
            " "
	    "================= "
            "Forefront install"
	    "================= "
            if ((Get-Process -Name msseces  -ErrorAction silentlycontinue).processname -eq "msseces") 
            {  "Forefront has already been installed..." }
            else { 
              \\oaintsccmc\packages\fep2010\client\fep_2010.exe
              wait-event -Timeout 60
              if ((Get-Process -Name msseces  -ErrorAction silentlycontinue).processname -eq "msseces") 
              {  "The forefront install has completed..." }
              else { "The forefront process isn't running, need to check!" }
            }
           }
     "[6]" { 
            "set-executionpolicy allsigned..."
            set-executionpolicy allsigned
           }
     "[7]" { 
            "Configure Insight Manager..."
            if (test-path hklm:\system\currentcontrolset\services\snmp\parameters\permittedManagers) {
            new-itemproperty -path hklm:\system\currentcontrolset\services\snmp\parameters\permittedManagers\ -name 2 -value "oaintnsite" 
            }
            if (test-path hklm:\system\currentcontrolset\services\snmp\parameters\TrapConfiguration\public) {
             new-itemproperty -path hklm:\system\currentcontrolset\services\snmp\parameters\TrapConfiguration\public\ -name 2 -value "oaintnsite" 
            }
           }
     "[8]" {
             "Install SCCM Client..."
              if ((Get-Process -Name CcmExec -ErrorAction SilentlyContinue).ProcessName -eq "ccmexec")
              {
                "SCCM has already been installed..."
              }
              else
              {
                 Out-Null [\\oaintfile2\shared\groups\source\sccm\sccm.cmd]
                 while ((Get-Process -Name CcmExec -ErrorAction SilentlyContinue).ProcessName -ne "ccmexec")
                 {
                   Wait-Event -Timeout 10
                 }

                 if ((Get-Process -Name CcmExec -ErrorAction SilentlyContinue).ProcessName -eq "ccmexec")
                 {
                  "SCCM install complete"
                 }
              }
            }
     "[9]" {
             #Disable LMHosts lookup
             $nic = [wmiclass]'Win32_NetworkAdapterConfiguration'
             $nic.enablewins($true,$false) | out-null
             "LMhosts lookup has been disabled."

             #Disable IE ESC for Administrators
             Set-ItemProperty -Path 'registry::hklm\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' -Name 'IsInstalled' -Value 0
             "IE Enhanced Security Config disabled for Administrators."
             
             #Disable IE ESC for Users
             #Set-ItemProperty -Path 'registry::hklm\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}' -Name 'IsInstalled' -Value 0
             
             #Create Reboot task
             Copy-Item "\\ssfhs\shared\oshared\groups\source\microsoft\rebootschedulefiles\windows 2008\rebootw2008.cmd" c:\windows\system32
             Out-Null [schtasks.exe /create /ru "system" /rp "" /tn "Reboot" /xml "\\ssfhs\shared\oshared\groups\source\microsoft\rebootschedulefiles\windows 2008\rebootw2008.xml"]
             "The reboot task has been created.  Don't forget to adjust the schedule!!!"

             #Disable UAC
             Set-ItemProperty -Path 'registry::hklm\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLUA' -Value 0
             "User Access Controll has been disabled."

             #Reboot
             "Server will be rebooted in 5 seconds."
             Start-Sleep -s 5
             Restart-Computer
           }
     "[x]" { 
            "Thanks for playing"
           }

  default { 
            "Your last selection was invalid $choice."
          }
 }

 " "
 " "
 " "
}


# SIG # Begin signature block
# MIIEHQYJKoZIhvcNAQcCoIIEDjCCBAoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCnefZhUIoDw0GZG8PufJO/YL
# y3CgggIxMIICLTCCAZqgAwIBAgIQ8HDaMjy48IJGsMuXkmLObDAJBgUrDgMCHQUA
# MCIxIDAeBgNVBAMTF1hEUiBTY3JpcHQgU2lnbmluZyBDZXJ0MB4XDTEzMDQxNzIy
# MjE0M1oXDTM5MTIzMTIzNTk1OVowIjEgMB4GA1UEAxMXWERSIFNjcmlwdCBTaWdu
# aW5nIENlcnQwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALWQSoYD8h+JGySa
# oAe2zWhXemwTtWuFikgl0Lu0a2kbJbIHbCTJsXKXEokCN+z69NPFFT5HFaTc6BrZ
# mFvz4IQPh9SCaxsKGxEqSdZsNnMY/ypd4ABJ/tds/Kyvf6fopaFGBQK3Fwnrrd/u
# /BajkQ6Fl1p9yWOAlxSxmA3bOYp3AgMBAAGjbDBqMBMGA1UdJQQMMAoGCCsGAQUF
# BwMDMFMGA1UdAQRMMEqAEFeqxqyD5V34WqJ5Aaqn/VmhJDAiMSAwHgYDVQQDExdY
# RFIgU2NyaXB0IFNpZ25pbmcgQ2VydIIQDS+jKzPHo7JIGFcQHzCjpTAJBgUrDgMC
# HQUAA4GBAB5bePT4ES2nRnJWT0iem9V3yKRiqv++GODP2NpKI930gLClIEmt+WSm
# c4Sj/pVfPqBJW5tyOcIvlCRfouVvZEkh9iLo56vh01zrxVN1OShqRLn/ckPLAvCU
# 7SGSTfZlbzC5TVvOPsxSl4z1/f49SfPaBpXCRdy3Elv9WC2wMEdKMYIBVjCCAVIC
# AQEwNjAiMSAwHgYDVQQDExdYRFIgU2NyaXB0IFNpZ25pbmcgQ2VydAIQ8HDaMjy4
# 8IJGsMuXkmLObDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKA
# ADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYK
# KwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUuFLyhH5mkDd/KsNmHA/Dykz14qsw
# DQYJKoZIhvcNAQEBBQAEgYA1urUPH3mVMlLVaPcepQxWgnU90+1jfhrbcp0GquNL
# 94ZmuJHjVnT9xkkJnSyao9RNWDRf1ADlZ8/EVvs/GuZi+aItGL0/hUwjzzWywrpT
# hJbbuEsswP7Jbu37i+TSUtodtAs/AtXeByMpJwx+p2pn/7qx5cGtyGM4JgMOVC8Z
# Rw==
# SIG # End signature block
