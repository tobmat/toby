# restart oaintipcc2 services

# Function to test services 
function test_service($service, $displayname, $server, $logfile)
{
 Try {
   Do { 
       Start-Sleep -Seconds 5 
       $i++        
       If($i -gt 1) { 
         ###Write-Output "$service ($displayname) service still down...$($i)" 
         Out-file -append -filepath $logfile "     $service ($displayname) service still down...$($i)"
       }
       #5 minute threshold (5*30) 
       If($i -eq 30) { 
          $ErrorActionPreference = "Stop";
          Write-Error "`n $server : +++ ACTION REQUIRED +++ $service ($displayname) service did not restart.  complete process manually" 
          #Write-Output $False 
       } 
   } 
   While ( (Get-Service -Name $service -cn $server).status -ne "Running")
   $output=$server + " : " + $service + "($displayname) service is running!"
   $output
   Out-file -append -filepath $logfile -inputobject $output
  } Catch {
       "Exiting script and sending an email...."
       Out-file -append -filepath $logfile -inputobject "$($Error[0])"
       $subject="OAINTIPCC2 Script ERROR - $displayname service did not restart."
       $end_time=get-date
       Out-file -append -filepath $logfile -inputobject "SCRIPT END TIME: $end_time"
       $body=(get-content $logfile | out-string)
       send_mail $subject $body
       exit
  }
}

function send_mail ($subject, $body)
{
  $smtpServer = "smtp.ssfhs.org"
  $to = "toby.matherly@franciscanalliance.org"
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

function w_error ($text)
{
   Write-Error "+++ ACTION REQUIRED +++ $text : The steps to stop the services wasn't successful, try manual rerunning the script"
   #"Pretend $text services were stopped...."
}

## START OF SCRIPT
$logfile="c:\scripts\logs\rs_oaintipcc2_services_log.txt"
$start=get-date
Out-file -filepath $logfile -inputobject "SCRIPT START TIME: $start"

Try {
 ### Force Terminating Error so will move to catch logic
 $ErrorActionPreference = "Stop";

 ### Stop services before rebooting servers
 Stop-Service -force -InputObject (Get-Service -Name "IPCM Web Portal" -cn oaintipcc2)

 ### Confirm all services have been stopped on OAINTIPCC2
# if ( (get-service -cn oaintipcc2 | Where-Object {($_.Name -like "IPCM Web Portal" -and $_.Status -eq "Running")} )) 
 if ( (get-service -cn oaintipcc2 -name "IPCM Web Portal" | % {$_.Status -eq "Running"} ))
    {
      w_error "oaintipcc2"
    } else {

        Out-file -append -filepath $logfile -inputobject "Services were stopped successfully, start services now...`n"
        # Start Services
        Start-Service -InputObject (get-service -Name "IPCM Web Portal" -ComputerName "oaintipcc2")
    }

} Catch {
    "Exiting script and sending an email...."
    Out-file -append -filepath $logfile -inputobject "$($Error[0])"
    $subject="oaintipcc2 Script ERROR - service(s) did not shutdown"
    $end_time=get-date
    Out-file -append -filepath $logfile -inputobject "SCRIPT END TIME: $end_time"
    $body=(get-content $logfile | out-string)
    send_mail $subject $body
    exit
}

test_service "IPCM Web Portal" "IPCM Web Portal" "oaintipcc2" $logfile

##$subject="oaintipcc2 Service Restart Script Completed Successfully"
##$end_time=get-date
##Out-file -append -filepath $logfile -inputobject "SCRIPT END TIME: $end_time"
##$body=(get-content  $logfile | out-string)
##send_mail $subject $body

# SIG # Begin signature block
# MIIMwwYJKoZIhvcNAQcCoIIMtDCCDLACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUFgcnlksFL11T1VbpukP9rd2g
# vSygggq0MIIFMTCCBBmgAwIBAgIKQGBHegABAAApbjANBgkqhkiG9w0BAQUFADBL
# MRMwEQYKCZImiZPyLGQBGRYDb3JnMRUwEwYKCZImiZPyLGQBGRYFc3NmaHMxHTAb
# BgNVBAMTFHNzZmhzLU9BSU5UQ0FJU1MxLUNBMB4XDTEzMDEyODE0NTMzOFoXDTE0
# MDEyODE0NTMzOFowgYsxEzARBgoJkiaJk/IsZAEZFgNvcmcxFTATBgoJkiaJk/Is
# ZAEZFgVzc2ZoczEMMAoGA1UECxMDQURTMRMwEQYDVQQLEwpFbnRlcnByaXNlMQ4w
# DAYDVQQLEwVVc2VyczESMBAGA1UECxMJUGxhdCBUZXN0MRYwFAYDVQQDEw1NYXRo
# ZXJseSBUb2J5MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC1K0OXgbQfBpUQ
# gVDlQN0QxaUi9T3BfbSqjUmK8GWO8L99NSv5rAiEOV+ritDuMSbOP52TQoibu894
# iaMyL51BLQwA9ixrA8fjs2Gh1GDpG6bYi0REdL/jmG9qrBluQSHNQ3c2H8WNEkM+
# ZyPeq328wRguFgMb7AJbVUKtdfvPyQIDAQABo4ICWDCCAlQwJQYJKwYBBAGCNxQC
# BBgeFgBDAG8AZABlAFMAaQBnAG4AaQBuAGcwEwYDVR0lBAwwCgYIKwYBBQUHAwMw
# CwYDVR0PBAQDAgeAMB0GA1UdDgQWBBRfGhxo5XwSG+UHzmdQBI1gJ0E4ZDAfBgNV
# HSMEGDAWgBTEdGD72+7OTkbnvbjri7jMeNaq0DCB1wYDVR0fBIHPMIHMMIHJoIHG
# oIHDhoHAbGRhcDovLy9DTj1zc2Zocy1PQUlOVENBSVNTMS1DQSgxKSxDTj1PQUlO
# VENBSVNTMSxDTj1DRFAsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2Vy
# dmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1zc2ZocyxEQz1vcmc/Y2VydGlmaWNh
# dGVSZXZvY2F0aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3RyaWJ1dGlv
# blBvaW50MIHEBggrBgEFBQcBAQSBtzCBtDCBsQYIKwYBBQUHMAKGgaRsZGFwOi8v
# L0NOPXNzZmhzLU9BSU5UQ0FJU1MxLUNBLENOPUFJQSxDTj1QdWJsaWMlMjBLZXkl
# MjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPXNzZmhz
# LERDPW9yZz9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNh
# dGlvbkF1dGhvcml0eTAoBgNVHREEITAfoB0GCisGAQQBgjcUAgOgDwwNeDE1QHNz
# ZmhzLm9yZzANBgkqhkiG9w0BAQUFAAOCAQEAeZR8WluRfH2a2OxggFqwZ2bl7RiR
# Quuj72752Yub2JLtpxNm+0uDgQAbl95qWxzYUApHg7Quv3OwAsSXqZ06UjB6nhAi
# ufyFbCyaVEedWE8zqnzgvQiFSDeWTVvURWdzzWeZE13lcsIbh8Q/bY9yeQEMvrDt
# mWvMajq204fWJTLeJhqfRHXoVP10ay13T1NDpeOMB/N1co3k47pM7Bz6hG6TNHJF
# +FXtzUgpZFgL40TAlyP3so1QWp4pR5mpPIoBaCtE+DgJpVcLfuZzSsDvH1QpyZ74
# fSYzcV3KM+oevHO5XuSdvfhQT2V3egkcSWf76Vmt40R2BSKdTOKFzyURvDCCBXsw
# ggNjoAMCAQICCjCQGhoAAAAAAAMwDQYJKoZIhvcNAQEFBQAwQzETMBEGCgmSJomT
# 8ixkARkWA29yZzEVMBMGCgmSJomT8ixkARkWBXNzZmhzMRUwEwYDVQQDEwxPQUlO
# VENBUk9PVDEwHhcNMTIwMjA5MTgxMzE1WhcNNDkwMjA5MTgyMzE1WjBLMRMwEQYK
# CZImiZPyLGQBGRYDb3JnMRUwEwYKCZImiZPyLGQBGRYFc3NmaHMxHTAbBgNVBAMT
# FHNzZmhzLU9BSU5UQ0FJU1MxLUNBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
# CgKCAQEAolurz4GEFoi/dNOmystSmIffhG9iEzfcMBYDpDRUIx5IzZoPUKV9xPhA
# jVwoMkTjUjhWAUrIlqyMi7KgNP09AolsWcUdcIQdCG/N1uIZmM2PlE7Tejeuvhlz
# s0tCUEPgpCZ1BbEhle8E5eMS/sUL1bXI+3LrBzg0mSmYoUCMEQzHhm35fGUK3pOP
# HlK/W7Ak7wxlWWJEEP51O19+Lw8Nsmk5136r511zmIJiJGNcEsHfgg+OXadQkwRj
# 0kaYP4TIJdA9JXxtB3ekr7JNBSMxiEuy5+K9hDfCBElWwJJ+F/BEhHAnO/+Y+p9z
# AoU0y+O6JgAobhcdpiTwHvHvxWTecQIDAQABo4IBZzCCAWMwEgYJKwYBBAGCNxUB
# BAUCAwEAATAjBgkrBgEEAYI3FQIEFgQUKhx58/85cK5MLXE0SSoRYDhaWg4wHQYD
# VR0OBBYEFMR0YPvb7s5ORue9uOuLuMx41qrQMBkGCSsGAQQBgjcUAgQMHgoAUwB1
# AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaA
# FLqXlcqlOPOPK4Io2IEcq1BowDyrMEkGA1UdHwRCMEAwPqA8oDqGOGh0dHA6Ly9v
# YWludGNhaXNzMS5zc2Zocy5vcmcvQ2VydEVucm9sbC9PQUlOVENBUk9PVDEuY3Js
# MGQGCCsGAQUFBwEBBFgwVjBUBggrBgEFBQcwAoZIaHR0cDovL29haW50Y2Fpc3Mx
# LnNzZmhzLm9yZy8lMjBDZXJ0RW5yb2xsL09BSU5UQ0FST09UMV9PQUlOVENBUk9P
# VDEuY3J0MA0GCSqGSIb3DQEBBQUAA4ICAQB6EVDQCpR5U5XhWL7GxakB0ht4wnDV
# 6FgQ7iSfjfLSQ3m/Knr84SOSQtOyaItipVNJCcLw/e73vUvl6m7ul0elYMdPP36n
# N0F2g8GxqazthSv5ZaT+L4ENJU3cUt6mcjW5RzH47HVDAiwjIAQ/6Fd/kUc2a2vt
# hwhQPI+KIahfgCYSemK4YQ1YhWd9u712IQeItM+vcHcIMMTAf4Zu7oCYrgngoZFw
# 5WQ1F5Q3Dvlhk+A9d+LZlcq4+P8u3eOlmtCmKqWpR0lQMYb/zZgUuWroG1JBNr5j
# fr3Q/j49WQ8T6YwnmOm49vWDaJ6onqWoD6fknJSxPOU6h7/n6Q+2CIa6mU0+Ugrh
# 6TE2opXX5+aXB3TuI0XYyWROUcPMYWJH4BEGUz7ldNGcwHxs73B3wN/0Y1Xxg1s+
# +FNMIqxyaN1PavY4ji2EWusjS2mjNT+uzX6w2+iew9Q/s4O3lW/11s+KKcSmNqqS
# yUcTnmpFzUfMkKt1aCKoygkM0oeqnvFeqNOB2AOJltgweSSFchLaHJUgToYWBeIw
# BSdCBxHGmvTQtr5GoWmwP+3jM7AjD3cOBtl11ac+EXfVq0+ixeLHlSRXKZOtMD7Y
# E6GHt7xfFBTXEvjiCTMTxUHayrLzkGiaQh4AcyZ0HI+R+cw2ObQfjwsDZkzBsFgx
# udbVupY5p2DSyjGCAXkwggF1AgEBMFkwSzETMBEGCgmSJomT8ixkARkWA29yZzEV
# MBMGCgmSJomT8ixkARkWBXNzZmhzMR0wGwYDVQQDExRzc2Zocy1PQUlOVENBSVNT
# MS1DQQIKQGBHegABAAApbjAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUTkUI0qiZVY+tdj74DkdV
# ldN6JF8wDQYJKoZIhvcNAQEBBQAEgYBGTnzwexPoIF+UE+GR1KIu3EvTVq8EG90n
# ALG8JcG8U26E4H3kNYLLvh7jECTkkB3+q/1jhgPOC3h9xaEz7+xZG2dUoEsI+XuJ
# wuimqY/zlFhpws9Qw5r5C9wWJw059IAuNPvDltBPPKEiK6yoTgHr/bZ6Kg0Rju86
# KAYmai1TCg==
# SIG # End signature block