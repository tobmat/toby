# Name   : s_pscribe_reboot_servers.ps1
# Purpose: Automate Weekly reboot of Southern Powerscribe Servers
# Date   : 5/15/2013 
# Author : Toby Matherly (x15)
# Detail : see below

# Function to reboot servers and test when they come back up
param($continue)
function reboot($server)
{
 $reboot_start=get-date 
 Out-file -append -filepath c:\scripts\logs\s_pscribe_reboot_servers_log.txt -inputobject "$server : Reboot started at ($reboot_start)`n"
 If (Test-Connection -Computer $server -count 1 -Quiet) { 
   Try { 
       Restart-Computer -ComputerName $server -Force -ea stop 
       Do { 
          Start-Sleep -Seconds 5 
          $j++        
          #Write-Verbose "Waiting for $server to shutdown..." 
          Write-Output "$server : Shutting Down...$($j)" 
          Out-file -append -filepath c:\scripts\logs\s_pscribe_reboot_servers_log.txt -inputobject "$server : Shutting down..."
          } 
          While ((Test-Connection -ComputerName $server -Count 1 -Quiet))    
             Do { 
                Start-Sleep -Seconds 5 
                $i++        
                Write-Output "$server : Rebooting...$($i)" 
                Out-file -append -filepath c:\scripts\logs\s_pscribe_reboot_servers_log.txt -inputobject "$server : Rebooting...$($i)"
                #5 minute threshold (5*60) 
                If($i -eq 60) { 
                    $ErrorActionPreference = "Stop";
                    Write-Error "$server : +++ ACTION REQUIRED +++ Reboot of server failed. Complete steps manually." 
                } 
             } 
              While (-NOT(Test-Connection -ComputerName $server -Count 1 -Quiet)) 
                $reboot_end=get-date 
                Out-file -append -filepath c:\scripts\logs\s_pscribe_reboot_servers_log.txt -inputobject "$server : Reboot completed at ($reboot_end)"
                Write-Output "$Server : is back up." 
    } Catch { 
       Write-Warning "$($Error[0])" 
       "Exiting script and sending an email...."
       Out-file -append -filepath c:\scripts\logs\s_pscribe_reboot_servers_log.txt -inputobject "$($Error[0])"
       $subject="Southern Powerscribe Script ERROR - $server server did not restart after reboot."
       $end_time=get-date
       Out-file -append -filepath c:\scripts\logs\s_pscribe_reboot_servers_log.txt -inputobject "SCRIPT END TIME: $end_time"
       $body=(get-content  c:\scripts\logs\s_pscribe_reboot_servers_log.txt | out-string)
       $to = "toby.matherly@franciscanalliance.org,bobby.haavisto@franciscanalliance.org,3177250158@archwireless.net,3179050272@ipnpaging.com"
       send_mail $subject $body $to
       exit
    } 
 } Else { 
   Write-Output $False 
 } 
}

# Function to test services after server is rebooted
function test_service($service, $displayname, $server)
{
 Try {
   Do { 
       Start-Sleep -Seconds 5 
       $i++        
       If($i -gt 1) { 
         Write-Output "$service ($displayname) service still down...$($i)" 
         Out-file -append -filepath c:\scripts\logs\s_pscribe_reboot_servers_log.txt -inputobject "     $service ($displayname) service still down...$($i)"
       }
       #10 minute threshold (5*60) 
       If($i -eq 60) { 
          $ErrorActionPreference = "Stop";
          Write-Error "`n $server : +++ ACTION REQUIRED +++ $service ($displayname) service did not restart after reboot.  complete process manually" 
          #Write-Output $False 
       } 
   } 
   ##########While ( (Get-Service -Name $service -cn $server).status -ne "Running")
   While ( (Get-Service -Name $service -cn $server -ErrorAction silentlycontinue).status -ne "Running")
   $output=$server + " : " + $service + "($displayname) service is running!"
   $output
   Out-file -append -filepath c:\scripts\logs\s_pscribe_reboot_servers_log.txt -inputobject $output
  } Catch {
       "Exiting script and sending an email...."
       Out-file -append -filepath c:\scripts\logs\s_pscribe_reboot_servers_log.txt -inputobject "$($Error[0])"
       $subject="Southern Powerscribe Script ERROR - $displayname service did not restart after reboot of $server."
       $end_time=get-date
       Out-file -append -filepath c:\scripts\logs\s_pscribe_reboot_servers_log.txt -inputobject "SCRIPT END TIME: $end_time"
       $body=(get-content  c:\scripts\logs\s_pscribe_reboot_servers_log.txt | out-string)
       $to = "toby.matherly@franciscanalliance.org,bobby.haavisto@franciscanalliance.org,3177250158@archwireless.net,3179050272@ipnpaging.com"
       send_mail $subject $body $to
       exit
  }
}

function send_mail ($subject, $body, $to)
{
  $smtpServer = "smtp.ssfhs.org"
  $from = "toby.matherly@franciscanalliance.org"

  $msg = new-object Net.Mail.MailMessage
  #$att = new-object Net.Mail.Attachment($filename)
  $smtp = new-object Net.Mail.SmtpClient($smtpServer)
  $msg.From = $from
  $msg.To.Add($to)
  $msg.Subject = $subject
  $msg.Body = $body
  #$msg.Attachments.Add($att)
  $smtp.Send($msg)
}

### Function to handle problems with stopping services ####
function w_error ($text)
{
      Out-file -append -filepath c:\scripts\logs\n_pscribe_reboot_servers_log.txt -inputobject  "+++ ACTION REQUIRED +++ $text : The steps to stop the services wasn't successful, try manual rerunning the script"
   Write-Error "+++ ACTION REQUIRED +++ $text : The steps to stop the services wasn't successful, try manual rerunning the script"
   ###"Pretend $text services were stopped...."
}

$start=get-date
Out-file -filepath c:\scripts\logs\s_pscribe_reboot_servers_log.txt -inputobject "SCRIPT START TIME: $start"


##############################################
############## Start of script ###############
##############################################


if ($continue -ne "YES") {
   #$continue = read-host "WAIT!  This script will reboot the southern powerscribe servers.  To continue type YES"
   if ($continue -ne "YES") { 
     "YES was not entered... exiting script! $continue" ##> c:\scripts\logs\toby.txt
     exit
   }
      
}

Try {
 ### Force Terminating Error so will move to catch logic
 $ErrorActionPreference = "Stop";

 ### Stop eG services so they don't restart services we are shutting down ###
 Stop-Service  -force -InputObject (Get-Service -DisplayName "eG*Agent*" -cn OAINTPWRSINF)
 Stop-Service  -force -InputObject (Get-Service -DisplayName "eG*Agent*" -cn OAINTPWRSWEB)
 Stop-Service  -force -InputObject (Get-Service -DisplayName "eG*Agent*" -cn OAINTPWRSDB)
 Stop-Service  -force -InputObject (Get-Service -DisplayName "eG*Agent*" -cn OAINTPWRSVR)
 Stop-Service  -force -InputObject (Get-Service -DisplayName "eG*Agent*" -cn OAINTPWRSTEL)

 ### Confirm all services have been stopped
 if ( (Get-Service -DisplayName "eG*Agent*" -cn OAINTPWRSINF,OAINTPWRSWEB,OAINTPWRSDB,OAINTPWRSVR,OAINTPWRSTEL | Where-Object {$_.Status -eq "Running"})) 
    {  
      w_error "eG"
    }

 ### Stop services before rebooting servers
 Stop-Service  -force -InputObject (Get-Service -DisplayName "PowerXpress_D_GateWay0*" -cn OAINTPWRSINF)
 Stop-Service  -force -InputObject (Get-Service -DisplayName "HSG-HL7*" -cn OAINTPWRSINF)
 Stop-Service  -force -InputObject (Get-Service -DisplayName "PSRecogServer*" -cn OAINTPWRSVR)
 Stop-Service  -force -InputObject (Get-Service -DisplayName "SDKWatchdog*" -cn OAINTPWRSVR)
 Stop-Service  -force -InputObject (Get-Service -DisplayName "HSG_TelServer*" -cn OAINTPWRSTEL)
 Stop-Service  -force -InputObject (Get-Service -DisplayName "Apache*" -cn OAINTPWRSWEB)
 Out-file -append -filepath c:\scripts\logs\n_pscribe_reboot_servers_log.txt -inputobject "Completed stopping services..."

 ### Confirm all services have been stopped on OAINTPWRSINF
 if ( (get-service -cn oaintpwrsinf | Where-Object {($_.DisplayName -like "Power*" -and $_.Status -eq "Running") -or ($_.DisplayName -like "HSG-HL7*" -and $_.Status -eq "Running")})) 
    {
      w_error "OAINTPWRSINF"
    }

 ### Confirm all services have been stopped on OAINTPWRSVR
 if ( (get-service -cn oaintpwrsvr | Where-Object {($_.DisplayName -like "PSRecogServer*" -and $_.Status -eq "Running") -or ($_.DisplayName -like "SDKWatchdog*" -and $_.Status -eq "Running")})) 
    {
      w_error "OAINTPWRSVR"
    }

 ### Confirm all services have been stopped on OAINTPWRSTEL
 if ( (get-service -cn oaintpwrstel | Where-Object {($_.DisplayName -like "HSG_TelServer*" -and $_.Status -eq "Running")})) 
    {
      w_error "OAINTPWRSTEL"
    }

 ### Confirm all services have been stopped on OAINTPWRSWEB
 if ( (get-service -cn oaintpwrsweb | Where-Object {($_.DisplayName -like "Apache*" -and $_.Status -eq "Running")})) 
    {
      w_error "OAINTPWRSWEB"
    }
} Catch {
    "Exiting script and sending an email...."
    Out-file -append -filepath c:\scripts\logs\s_pscribe_reboot_servers_log.txt -inputobject "$($Error[0])"
    $subject="Southern Powerscribe Script ERROR - service(s) did not shutdown"
    $end_time=get-date
    Out-file -append -filepath c:\scripts\logs\s_pscribe_reboot_servers_log.txt -inputobject "SCRIPT END TIME: $end_time"
    $body=(get-content  c:\scripts\logs\s_pscribe_reboot_servers_log.txt | out-string)
    $to = "toby.matherly@franciscanalliance.org,bobby.haavisto@franciscanalliance.org,3177250158@archwireless.net,3179050272@ipnpaging.com"
    send_mail $subject $body $to
    exit
}


Out-file -append -filepath c:\scripts\logs\s_pscribe_reboot_servers_log.txt -inputobject "UPDATE : All necessary services have been stopped.  Proceeding with reboots.`n"
# Reboot servers and test that services come back up

###reboot "OAINTPWSHELL"
###test_service "TapiSrv" "Telephony" "OAINTPWSHELL"

### This will reboot server and then wait until server is back up before proceeding
reboot "OAINTPWRSWEB"
test_service "Tomcat5" "Apache Tomcat" "OAINTPWRSWEB"

reboot "OAINTPWRSDB"
reboot "OAINTPWRSVR"
reboot "OAINTPWRSINF"

test_service "PowerXpress_D_GateWay0" "PowerXpress_D_GateWay0" "OAINTPWRSINF"
test_service "HSG_HL7Client_SaintFrancisSo" "HSG-HL7Client: SaintFrancisSo" "OAINTPWRSINF"
test_service "HSG_HL7Server_SaintFrancisSo" "HSG-HL7Server: SaintFrancisSo" "OAINTPWRSINF"

reboot "OAINTPWRSTEL"
test_service "RtfDispatcher" "Dialogic Runtime Tracing Dispatcher" "OAINTPWRSTEL"
test_service "HSG_TelServer" "HSG_TelServer" "OAINTPWRSTEL"

$subject="Southern Powerscribe Script Completed Successfully"

$end_time=get-date
Out-file -append -filepath c:\scripts\logs\s_pscribe_reboot_servers_log.txt -inputobject "SCRIPT END TIME: $end_time"
Out-file -filepath c:\scripts\logs\s_pscribe_reboot_servers_completed.txt -inputobject "SCRIPT END TIME: $end_time"
$body=(get-content  c:\scripts\logs\s_pscribe_reboot_servers_log.txt | out-string)
$to = "toby.matherly@franciscanalliance.org,bobby.haavisto@franciscanalliance.org"
send_mail $subject $body $to

# SIG # Begin signature block
# MIIPWwYJKoZIhvcNAQcCoIIPTDCCD0gCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU85ep0qa2b5Yiy9WWTwpqzhpn
# Thegggy/MIIF5zCCBM+gAwIBAgIKYU4uYQAAAAAAAzANBgkqhkiG9w0BAQUFADAm
# MSQwIgYDVQQDExtGcmFuY2lzY2FuIEFsbGlhbmNlIFJvb3QgQ0EwHhcNMTIwNzMx
# MTc1ODMwWhcNMjIwNzMxMTgwODMwWjBXMRMwEQYKCZImiZPyLGQBGRYDb3JnMRUw
# EwYKCZImiZPyLGQBGRYFc3NmaHMxKTAnBgNVBAMTIEZyYW5jaXNjYW4gQWxsaWFu
# Y2UgSXNzdWluZyBDQSAyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# yCVSlA0pbHQ5oA/hQbsbrkJ/bARsHjZihho/nMc+aVD6mXtwmShor0WpdG0AaoGN
# Qxge1xsxpvxTXVR+yXZsp312iQIzZLyEIOsOEFn2AuAsOAVekWyEgvnfelDo4hRS
# wVwK1HCiK0bmLL4TVf3xOUDTlk3TTYqbyVDQW/PQG5vKufe39+fRv9RpqMNdzUA1
# VZqeGCVPyvx9smqNU8iKNIIV98LuYjZU4Cua6qUCAHJhdCpD9giDLMlsGSopRE+q
# TOYTHSan2y/jzntX2OSFkG38Amr5WNq6+cAgeBVwJbuBLJhjZ+tLnLV7m+zs6tdB
# qXnTU2x11fpvluVKodwS3wIDAQABo4IC5DCCAuAwEAYJKwYBBAGCNxUBBAMCAQAw
# HQYDVR0OBBYEFFdyf3w9oXIov18Ha3J9EfaX/naNMBkGCSsGAQQBgjcUAgQMHgoA
# UwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQY
# MBaAFDNIlFgU5SKf8lA64GHHCcOlMAIOMIIBJAYDVR0fBIIBGzCCARcwggEToIIB
# D6CCAQuGPGh0dHA6Ly9jZXJ0cy5zc2Zocy5vcmcvRnJhbmNpc2NhbiUyMEFsbGlh
# bmNlJTIwUm9vdCUyMENBLmNybIaBymxkYXA6Ly8vQ049RnJhbmNpc2NhbiUyMEFs
# bGlhbmNlJTIwUm9vdCUyMENBLENOPU9BSU5UQ0FST09ULENOPUNEUCxDTj1QdWJs
# aWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9u
# LERDPXNzZmhzLERDPW9yZz9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/
# b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwggEpBggrBgEFBQcBAQSC
# ARswggEXMFQGCCsGAQUFBzAChkhodHRwOi8vY2VydHMuc3NmaHMub3JnL09BSU5U
# Q0FST09UX0ZyYW5jaXNjYW4lMjBBbGxpYW5jZSUyMFJvb3QlMjBDQS5jcnQwgb4G
# CCsGAQUFBzAChoGxbGRhcDovLy9DTj1GcmFuY2lzY2FuJTIwQWxsaWFuY2UlMjBS
# b290JTIwQ0EsQ049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNl
# cnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9c3NmaHMsREM9b3JnP2NBQ2VydGlm
# aWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0aG9yaXR5MA0G
# CSqGSIb3DQEBBQUAA4IBAQBE96ULndNWTghTP6fe4TuEfLweUu1jkV7H3dWXhZG3
# PDN9k5K7+0Rf2SNW0YFdsYJxdjuOTSsa3n+s/WnZf4Cphy/J6bjcjng2tty2PISc
# N2LpOlndR5L1IKsddT8oVuVmc9zh1Vz1Kuu/CzTQ9wOFwTiqztuNWDowLQAvUXbK
# 9N0Zxdvr8ymNp7ThdRPbEeg+UYZM+rn6494sPdUF+1T89Sxf0zRVjoMczmm70NlZ
# bzc2Jq5keNVe7skrgTExgXspNhSV4aIxBT8e8MrsCaILc7aqzCO5eyh7asmz/N3K
# A8fpc+NHZegVaSUwLMzPH1pQw6GjMkqqZmdjuT7CcQt3MIIG0DCCBbigAwIBAgIK
# YSzb3gAAAAAAeTANBgkqhkiG9w0BAQUFADBXMRMwEQYKCZImiZPyLGQBGRYDb3Jn
# MRUwEwYKCZImiZPyLGQBGRYFc3NmaHMxKTAnBgNVBAMTIEZyYW5jaXNjYW4gQWxs
# aWFuY2UgSXNzdWluZyBDQSAyMB4XDTEzMDczMDE5MTIxNloXDTE4MDcyOTE5MTIx
# NlowgYsxEzARBgoJkiaJk/IsZAEZFgNvcmcxFTATBgoJkiaJk/IsZAEZFgVzc2Zo
# czEMMAoGA1UECxMDQURTMRMwEQYDVQQLEwpFbnRlcnByaXNlMQ4wDAYDVQQLEwVV
# c2VyczESMBAGA1UECxMJUGxhdCBUZXN0MRYwFAYDVQQDEw1NYXRoZXJseSBUb2J5
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAjCbx9UeNZdNA3hiiMmHP
# ubmZAGuk4wCh1Ck/CyHtmpCwZOjF5btW22yptkhGxyyJz4xEst43F0RYmlxd+mE5
# GMJy6TsIAs5yj5YzxrGwWFg0UDUqe58gaAMnfxs5KPLKuZtZiafAMo84wLaDb+VW
# K41NDNi4EAj25EsLyEGAx54P8O6PHgXwNbnGJCA4+XpyOJLtQzLThJWxK/nJptCd
# /2FhIwjNliyAkdvhXrxSVzyQOYXWsgvSKfE1Deg5WJ7tjZIhu7KPEU/5zEnovSqo
# AxGeh2NCrmBNqa1Ehu1YOogx8hMWrOhxbpYVgyMWcF2xm6l2YFCbwvGQnazbSbNt
# UwIDAQABo4IDZzCCA2MwPQYJKwYBBAGCNxUHBDAwLgYmKwYBBAGCNxUIgZqcH4Ki
# wj2CjYk8hbX9EYSjvgBGhO6KPIGywUcCAWQCAQMwEwYDVR0lBAwwCgYIKwYBBQUH
# AwMwCwYDVR0PBAQDAgeAMBsGCSsGAQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYD
# VR0OBBYEFNNCzTr+J0O8pbhBFZGioGJ72vaLMB8GA1UdIwQYMBaAFFdyf3w9oXIo
# v18Ha3J9EfaX/naNMIIBMgYDVR0fBIIBKTCCASUwggEhoIIBHaCCARmGQ2h0dHA6
# Ly9jZXJ0cy5zc2Zocy5vcmcvRnJhbmNpc2NhbiUyMEFsbGlhbmNlJTIwSXNzdWlu
# ZyUyMENBJTIwMi5jcmyGgdFsZGFwOi8vL0NOPUZyYW5jaXNjYW4lMjBBbGxpYW5j
# ZSUyMElzc3VpbmclMjBDQSUyMDIsQ049T0FJTlRDQUlTUzMsQ049Q0RQLENOPVB1
# YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRp
# b24sREM9c3NmaHMsREM9b3JnP2NlcnRpZmljYXRlUmV2b2NhdGlvbkxpc3Q/YmFz
# ZT9vYmplY3RDbGFzcz1jUkxEaXN0cmlidXRpb25Qb2ludDCCAUEGCCsGAQUFBwEB
# BIIBMzCCAS8wZQYIKwYBBQUHMAKGWWh0dHA6Ly9jZXJ0cy5zc2Zocy5vcmcvT0FJ
# TlRDQUlTUzMuc3NmaHMub3JnX0ZyYW5jaXNjYW4lMjBBbGxpYW5jZSUyMElzc3Vp
# bmclMjBDQSUyMDIuY3J0MIHFBggrBgEFBQcwAoaBuGxkYXA6Ly8vQ049RnJhbmNp
# c2NhbiUyMEFsbGlhbmNlJTIwSXNzdWluZyUyMENBJTIwMixDTj1BSUEsQ049UHVi
# bGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlv
# bixEQz1zc2ZocyxEQz1vcmc/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29iamVjdENsYXNz
# PWNlcnRpZmljYXRpb25BdXRob3JpdHkwKAYDVR0RBCEwH6AdBgorBgEEAYI3FAID
# oA8MDXgxNUBzc2Zocy5vcmcwDQYJKoZIhvcNAQEFBQADggEBABd3HeogWKmXyRNL
# AAupLpcrdlSkk+eNwPdZMzlffAilBhc8lSgKasAxQyf4Qy73A/r/ZpLzNATX1hXu
# 8FqgEWpOOVRboOQrHsl6a8PkgAUxxgHfRt3Y6L467T9TUIEXtq+6waZlLqkRO/Aq
# 6y/cJYfWfdsjHVLv08kkq4O7SPRUaslWYMWpY/SLe6NlaJgkhAESdlD9FWKc1UET
# cYtFnfMThg7+kpTLOH9uENQyawlkJ9yt3xVIW5oD/VKKXivtxF0CqhuQaea1Zltf
# n+vOOLrir9Pp9KtzLXK8WMFj2VeWjX1q68wcfOV8zww9v1btfaaztuTicDC1Kndx
# R3oQbUcxggIGMIICAgIBATBlMFcxEzARBgoJkiaJk/IsZAEZFgNvcmcxFTATBgoJ
# kiaJk/IsZAEZFgVzc2ZoczEpMCcGA1UEAxMgRnJhbmNpc2NhbiBBbGxpYW5jZSBJ
# c3N1aW5nIENBIDICCmEs294AAAAAAHkwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcC
# AQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYB
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFH/XDAyOJ8sd
# Fj3D3tG9UR66VyLBMA0GCSqGSIb3DQEBAQUABIIBABA76+TNcvHNHDIdx0gebIgc
# FDN9MVmHAUdST+9b6ugx34A+gazMTPSQEHX8xNrWVSbixcTnC260qmqVbx6DIrDn
# Wv4Whwwcmj2Djt8A7+aN900gTam3h9QSBHHaq0fqWOBjr9zERhs7/Oskvafm+wtY
# jym4AbfmCiRXnK1HsA+BeeGYCAX5RQH5LwPrMGT9rPJa6IbyMmkyXYaRiR1aw/tk
# pZlhwEN+vnuf3+brgPNiARuzF8K4K3yMbJ/VbLRKQrcPu/pIaWyp8qXCSKayrW4X
# HsUdFkbNOywdgTKFe5KID0lSgxQ+/guZTTSmWc56qrgt9jcHCuzalJzqv7THdyc=
# SIG # End signature block
