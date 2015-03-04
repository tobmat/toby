# Name   : svr_join_domain.ps1 
# Purpose: Joins server to domain and put in the correct OU
# Date   : 11/30/2012 
# Author : Toby Matherly
# Detail : Uses the servername to determine which OU to move to, copies standard powershell profile from powershell server
#
# Update : changed -DomainName flag in Add-Computer command from "ssfhs" to "ssfhs.org"  due to issues with 2012

# Set variables for script
$CLIENT=$env:computername
$front = $CLIENT.Substring(0,1)

# create empty powershell file
new-item -path $env:windir\System32\WindowsPowerShell\v1.0\profile.ps1 -itemtype file -force | out-null
# copy standard powershell profile to new location
copy \\oaintpwshell\c$\scripts\profile.ps1  $env:windir\System32\WindowsPowerShell\v1.0\

if (! $user) {
  $error.clear()
  $user = read-host "Enter your userId (format ssfhs\userid):"
}
#$user = "ssfhs" + "\" + $user
if (! $citrix) {
  $citrix = read-host "Is this a citrix server? ('y' or 'n')"
}

#if ($citrix -eq "y") {
#  "Move to Citrix container and Reboot"
#  Add-Computer -DomainName ssfhs.org -credential $user -OUPath 'OU=Citrix Servers,OU=Servers,OU=Enterprise,OU=ADS,DC=ssfhs,DC=org'
#}

if ($citrix -eq "y") {
  "Move to Citrix container and Reboot"
  $citrix_version = read-host "Is this a Windows 2003 server? ('y' or 'n')"
  if ($citrix_version -eq "y") {
    Add-Computer -DomainName ssfhs.org -credential $user -OUPath 'OU=Citrix Profile Manager 4.1 for Windows 2003,OU=Citrix Servers,OU=Servers,OU=Enterprise,OU=ADS,DC=ssfhs,DC=org'
  } else {
    Add-Computer -DomainName ssfhs.org -credential $user -OUPath 'OU=Citrix Profile Manager 4.1 for Windows 2008,OU=Citrix Servers,OU=Servers,OU=Enterprise,OU=ADS,DC=ssfhs,DC=org'
  }
}
else {
 # Determine which OU to move server
 switch -regex ($front)  {
   "[a]" { 
           "Move to A-StFrancis OU and Reboot"
           Add-Computer -DomainName ssfhs.org -credential $user -OUPath 'OU=Servers,OU=A-StFrancis,OU=ADS,DC=ssfhs,DC=org'
         }
   "[b]" { 
           "Move to B-StMargaretMercy OU and Reboot"
           Add-Computer -DomainName ssfhs.org -credential $user -OUPath 'OU=Servers,OU=B-StMargaretMercy,OU=ADS,DC=ssfhs,DC=org'
         }
   "[c]" { 
           "Move to C-GLHS OU and Reboot"
           Add-Computer -DomainName ssfhs.org -credential $user -OUPath 'OU=Servers,OU=C-GLHS,OU=ADS,DC=ssfhs,DC=org'
         }
   "[d]" { 
           "Move to D-StAnthony OU and Reboot"
           Add-Computer -DomainName ssfhs.org -credential $user -OUPath 'OU=Servers,OU=D-StAnthony,OU=ADS,DC=ssfhs,DC=org'
         }
   "[e]" { 
           "Move to E-FPH OU and Reboot"
           Add-Computer -DomainName ssfhs.org -credential $user -OUPath 'OU=Servers,OU=E-FPH,OU=ADS,DC=ssfhs,DC=org'
         }
   "[f]" { 
           "Move to F-StJames OU and Reboot"
           Add-Computer -DomainName ssfhs.org -credential $user -OUPath 'OU=Servers,OU=F-StJames,OU=ADS,DC=ssfhs,DC=org'
         }
   "[o]" { 
           "Move to O-Enterprise OU and Reboot"
           Add-Computer -DomainName ssfhs.org -credential $user -OUPath 'OU=Servers,OU=Enterprise,OU=ADS,DC=ssfhs,DC=org'
         }
   "[p]" { 
           "Move to P-StAnthony OU and Reboot"
           Add-Computer -DomainName ssfhs.org -credential $user -OUPath 'OU=Servers,OU=P-StAnthony,OU=ADS,DC=ssfhs,DC=org'
         }
   "[s]" { 
           "Move to S-StClare OU and Reboot"
           Add-Computer -DomainName ssfhs.org -credential $user -OUPath 'OU=Servers,OU=S-StClare,OU=ADS,DC=ssfhs,DC=org'
         }
   "[t]" { 
           "Move to T-TonnBlank OU and Reboot"
           Add-Computer -DomainName ssfhs.org -credential $user -OUPath 'OU=Servers,OU=T-TonnBlank,OU=ADS,DC=ssfhs,DC=org'
         }
   default {
           "This server did not match any of the options above..."
           $reboot = "n"
           }
 }
} 

if ($error.count -gt 0) {
 write-host "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" -foreground yellow
 write-host " There was a problem. See error message above for more details!!!" -foreground yellow
 write-host "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" -foreground yellow
}
else {
  if (! $reboot) {
   "Server will be rebooted in 5 seconds"
    Start-Sleep -s 5
    Restart-Computer
  }
  else {
   "Server didn't match any of standard OU's.  You'll have to manually join to the domain."
  }
}


# SIG # Begin signature block
# MIIPWwYJKoZIhvcNAQcCoIIPTDCCD0gCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUi2q2nJwElcfcwZ/C2P7BuorT
# vYmgggy/MIIF5zCCBM+gAwIBAgIKYU4uYQAAAAAAAzANBgkqhkiG9w0BAQUFADAm
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFDaE/uQYJxm8
# VOkdUjLCjqpYsnmlMA0GCSqGSIb3DQEBAQUABIIBAHE0SjYGOzIt/ly6bm57aU5U
# PS+oPBCqhdxyW8qdm/1dRpoOzrxJrldHez1889ilLRZuYhNP3j7FYKTIeJsaGUg3
# w4kUeu7uSWzbohAxbUfhPifI2W8FpxU7NG9GNnVZOUdbjBtyKi9gjK8Vm2z8QsZd
# ICBslyOWrmcGfiyvvbISk+IaDKeE61U0WHFi5i3Mj3JsPnDybibV4Dg5Jn3xzku5
# XckvR5e8bEdFw2cI/l/qfMakTzrAcER1j32VRlAP5/AOpARsx9xo5WGxAWvxHnn8
# UgggXOgWlQDUGN34iRRdT6p+jb3SLEJDOKISU5UdBBGVSJ/TvI37PnjGiMIhCr4=
# SIG # End signature block