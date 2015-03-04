# Name:    remote_cleanup.ps1
# Date:    12/25/2012
# Author:  Toby Matherly
# Details: Script to execute other scripts on remote-enabled machines
# This currently is scheduled to run 3rd Tuesday at 2 AM every month.
# Make sure reboot schedule doesn't conflict if you add a new cleanup script.

# Variables to reference script and log location
$logdir="\\oaintpwshell\scripts\logs"
$scriptdir="\\oaintpwshell\scripts"

function process_cleanup($server,$script,$info)
{
 $log="$logdir\" + $server + "_cleanup_log.txt"
 $elog="$logdir\ERROR_" + $server + "_log.txt"
 Invoke-Command -ComputerName $server -filepath $script -ArgumentList $info > $log
 # write errors to log file and then clear log variable
 $error > $elog
 if ($error.Count -gt 0) {
   ### Send email if errors
   $ScriptName = $MyInvocation.MyCommand.Name
   $subject = "$server script error ($ScriptName) "
   $body = (get-content $elog | out-string)
   $to = "toby.matherly@franciscanalliance.org"

   & $scriptdir\send_mail.ps1 $subject $body $to
 } 
 $error.clear()
}

# Runs cleanup script on oaintcgnswb1, added 8/26/2013 by x15
$server="OAINTCGNSWB1"
$script="$scriptdir\cleanup_files.ps1"
$info="180","C:\inetpub\logs\LogFiles\W3SVC1\"
process_cleanup $server $script $info

# Runs cleanup script on oaintkrapp2, added 7/05/2013 by x15
$server="OAINTKRAPP2"
$script="$scriptdir\cleanup_files.ps1"
$info="30","C:\inetpub\logs\LogFiles\W3SVC1\"
process_cleanup $server $script $info

# Runs cleanup script on oaintepclarap1, added 7/18/2013 by x15
$server="oaintepclarap1"
$script="$scriptdir\cleanup_files.ps1"
$info="42","C:\inetpub\logs\LogFiles\W3SVC1\"
process_cleanup $server $script $info

# Runs cleanup script on OAINTEPPRT1, added 7/18/2013 by x15
$server="OAINTEPPRT1"
$script="$scriptdir\cleanup_files.ps1"
$info="60","C:\inetpub\logs\LogFiles\FTPSVC1\"
process_cleanup $server $script $info

# Runs cleanup script on OAINTSYSPP, added 8/26/2013 by x15
$server="OAINTSYSPP"
$script="$scriptdir\cleanup_files.ps1"
$info="30","C:\inetpub\logs\LogFiles\W3SVC1\"
process_cleanup $server $script $info

# Runs cleanup script on OAINTICNCTWB1, added 9/19/2013 by x3y
$server="OAINTICNCTWB1"
$script="$scriptdir\cleanup_files.ps1"
$info="30","C:\inetpub\logs\LogFiles\W3SVC1\"
process_cleanup $server $script $info

# Runs cleanup script on OAINTSHPSFMG, added 9/20/2013 by x15
$server="OAINTSHPSFMG"
$script="$scriptdir\cleanup_files.ps1"
$info="30","C:\inetpub\logs\LogFiles\"
process_cleanup $server $script $info

# Runs cleanup script on OAINTEPBLOB1, added 10/31/2013 by x3y
$server="OAINTEPBLOB1"
$script="$scriptdir\cleanup_files.ps1"
$info="30","C:\inetpub\logs\LogFiles\W3SVC1\"
process_cleanup $server $script $info

# Runs cleanup script on OAIVMEPRWB, added 12/9/2013 by x3y
$server="OAIVMEPRWB"
$script="$scriptdir\cleanup_files.ps1"
$info="30","C:\Windows\system32\LogFiles\W3SVC2\"
process_cleanup $server $script $info

# Runs cleanup script on OAINTWEBF1, added 12/19/2013 by x3y
$server="OAINTWEBF1"
$script="$scriptdir\cleanup_files.ps1"
$info="30","C:\Windows\system32\LogFiles\W3SVC1043690266\*.log"
process_cleanup $server $script $info

# Runs cleanup script on OAINTONBASEWEB, added 12/27/2013 by x15
$server="OAINTONBASEWEB"
$script="$scriptdir\cleanup_files.ps1"
# W3SVC1 and W3SVC2 folders will be cleaned up
$info="30","C:\inetpub\logs\LogFiles\"
process_cleanup $server $script $info

# Runs cleanup script on OAINTEPCRLNK2, added 1/03/2014 by x15
$server="OAINTEPCRLNK2"
$script="$scriptdir\cleanup_files.ps1"
$info="30","C:\inetpub\logs\LogFiles\W3SVC1\"
process_cleanup $server $script $info

# Runs cleanup script on oaintfmp01, added 1/29/2014 by x15
$server="OAINTFMP01"
$script="$scriptdir\cleanup_files.ps1"
$info="30","C:\Windows\system32\LogFiles\W3SVC1\"
process_cleanup $server $script $info

# Runs cleanup script on several oaintmdver servers 
(get-date).ToString() + " === Starting OAINTMDVER* CLEANUP ===" > $logdir\oaintmdver_cleanup_log.txt
Invoke-Command -ComputerName oaintmdver, oaintmdver2, oaintmdver3, oaintmdver4, oaintmdver5, oaintmdver6, oaintmdver7, oaintmdver8, oaintmdver9, oaintmdver10, oaintmdver11, oaintmdver12, oaintmdver13, oaintmdver14 -filepath $scriptdir\cleanup_oaintmdver.ps1 >>  $logdir\logs\oaintmdver_cleanup_log.txt
(get-date).ToString() + " === ENDING OAINTMDVER* CLEANUP ===" >> $logdir\oaintmdver_cleanup_log.txt
# write errors to log file and then clear log variable
$error > $logdir\oaintmdver_error_log.txt
if ($error.Count -gt 0) {
   ### Send email if errors
   $subject = "OAINTMDVER script error"
   $body = (get-content $elog | out-string)
   $to = "toby.matherly@franciscanalliance.org"
   & $scriptdir\send_mail.ps1 $subject $body $to
 } 
$error.clear()

# SIG # Begin signature block
# MIIPWwYJKoZIhvcNAQcCoIIPTDCCD0gCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUgCsTiAfsnoDmQAj1yZDTs8Og
# 8kugggy/MIIF5zCCBM+gAwIBAgIKYU4uYQAAAAAAAzANBgkqhkiG9w0BAQUFADAm
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFDq9bm9E6+gw
# TAgOwmzfZbw/SW5CMA0GCSqGSIb3DQEBAQUABIIBAAmF8gl1vEeTS8POzgVTu4/N
# SMj8MZ6sIsyVZhrMqbBRTw2XLq5ox2khDtK7PjMmM9z0NXnmKPrYbnEXASf5zMYX
# lm5DwAdFeQ4dhrbavz7vagGYYH0slFVmgYmx/cYqd5StuYAVqwJ385cWXusDDVCE
# B21k8bB37+EMooLnAuunds2q/hFremYDdqhFc1EX2MEYrxg+Z5AZ7Tp0PabIl6AU
# 2sc21srjMBMugpY6eOZ2Ub5NpZttdKq+voc9W9h4fkoj+DxVQ/AQ00pvF9Pyduox
# LyifJcX2HXYUUNDLD/jK6kK8Eq2MdK8e3I53/oz17SQSUqxElViPWAZcHpgh0vk=
# SIG # End signature block
