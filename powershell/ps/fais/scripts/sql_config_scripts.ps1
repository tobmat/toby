# Name   : sql_config_scripts.ps1
# Purpose: Run SQL setup scripts for 2008, 2008R2, and 2012 SQL installs
# Date   : 11/26/2013 
# Author : Toby Matherly (x15)
# Detail : see below
#

# get local server name
#$servername = gc env:computername


if (! $servername) {
  $servername = read-host "Enter instance name or servername for default instance"
}

if (! $sqlversion) {
  $sqlversion = read-host "Enter SQL verion '2008', 2008R2 or '2012': "
}

if ($sqlversion -eq "2008" -or $sqlversion -eq "2008R2") {
  # 2008 config scripts
  #
  
  $D_value = read-host "Enter Drive location of the Database File (usually D or F)"
  $X_value = read-host "Enter Drive location of the Log File (usually D or G)"
  $script1= Get-Content "\\oaintpwshell\scripts\sql\01CreateMaintenanceDB.sql" | % {$_ -replace "DDD", $D_value }
  $script1= $script1 | % {$_ -replace "XXX", $X_value }
  $script1 | Out-File \\oaintpwshell\scripts\sql\01temp.sql
  Invoke-Sqlcmd -InputFile \\oaintpwshell\scripts\sql\01temp.sql -ServerInstance $servername

  # Added to exit out of SQL mode in 2012 so the rest of the script works!
  C:

  $B_value = read-host "Enter Drive location of the Backup File (usually D or K)"
  $script2= Get-Content "\\oaintpwshell\scripts\sql\02CreateBackupPath.sql" | % {$_ -replace "BBB", $B_value }
  $script2 | Out-File \\oaintpwshell\scripts\sql\02temp.sql
  Invoke-Sqlcmd -InputFile \\oaintpwshell\scripts\sql\02temp.sql -ServerInstance $servername

  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2008\03Enable_XPCMDSHELL.sql" -ServerInstance $servername
  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2008\04AIS_CheckDB.sql" -ServerInstance $servername
  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2008\05AIS_xp_fixeddrives.sql" -ServerInstance $servername
  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2008\07DB Security Baseline.sql" -ServerInstance $servername
  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2008\08dba_indexStats_sp.sql" -ServerInstance $servername
  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2008\09IndexMaintenanceScript.sql" -ServerInstance $servername
  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2008\10SetupSQLServerLog.sql" -ServerInstance $servername
  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2008\11CreateJobFailureNotification.sql" -ServerInstance $servername
}

if ($sqlversion -eq "2008") {
  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2008\06BackupJobProc.sql" -ServerInstance $servername
}

if ($sqlversion -eq "2008R2") {
  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2008\06BackupJobProc(2008R2).sql" -ServerInstance $servername
}

if ($sqlversion -eq "2012") {
  # 2012 config scripts
  $D_value = read-host "Enter Drive location of the Database File (usually D or F)"
  $X_value = read-host "Enter Drive location of the Log File (usually D or G)"
  $script1= Get-Content "\\oaintpwshell\scripts\sql\01CreateMaintenanceDB.sql" | % {$_ -replace "DDD", $D_value }
  $script1= $script1 | % {$_ -replace "XXX", $X_value }
  $script1 | Out-File \\oaintpwshell\scripts\sql\01temp.sql
  Invoke-Sqlcmd -InputFile \\oaintpwshell\scripts\sql\01temp.sql -ServerInstance $servername

  $B_value = read-host "Enter Drive location of the Backup File (usually D or K)"
  $script2= Get-Content "\\oaintpwshell\scripts\sql\02CreateBackupPath.sql" | % {$_ -replace "BBB", $B_value }
  $script2 | Out-File \\oaintpwshell\scripts\sql\02temp.sql
  Invoke-Sqlcmd -InputFile \\oaintpwshell\scripts\sql\02temp.sql -ServerInstance $servername

  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2012\03Enable_XPCMDSHELL.sql" -ServerInstance $servername
  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2012\04AIS_CheckDB.sql" -ServerInstance $servername
  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2012\05AIS_xp_fixeddrives.sql" -ServerInstance $servername
  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2012\06BackupJobProc.sql" -ServerInstance $servername
  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2012\07DB Security Baseline.sql" -ServerInstance $servername
  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2012\08dba_indexStats_sp.sql" -ServerInstance $servername
  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2012\09IndexMaintenanceScript.sql" -ServerInstance $servername
  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2012\10SetupSQLServerLog.sql" -ServerInstance $servername
  Invoke-Sqlcmd -InputFile "\\ssfhs\shared\OShared\Groups\Database\Database\Private\Documents\SQL_Server\MSSQL_Scripts\Binn\Setup Scripts 2012\11CreateJobFailureNotification.sql" -ServerInstance $servername
}

"setting up master/target relationship for job scheduling..."
$script3= Get-Content "\\oaintpwshell\scripts\sql\SetTargets.sql" | % {$_ -replace "SERVERNAME", $servername }
$script3 | Out-File \\oaintpwshell\scripts\sql\03temp.sql

if ($sqlversion -eq "2008" -or $sqlversion -eq "2008R2") {
  Invoke-Sqlcmd -InputFile \\oaintpwshell\scripts\sql\03temp.sql -ServerInstance OAINTSQLMSX\SQL2K8
}
if ($sqlversion -eq "2012") {
  Invoke-Sqlcmd -InputFile \\oaintpwshell\scripts\sql\03temp.sql -ServerInstance OAINTSQLMSX\SQL2K12
}



# SIG # Begin signature block
# MIIPWwYJKoZIhvcNAQcCoIIPTDCCD0gCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUt3kA7jy4K2pnTp+V+Q3wLwUD
# 8D+gggy/MIIF5zCCBM+gAwIBAgIKYU4uYQAAAAAAAzANBgkqhkiG9w0BAQUFADAm
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFC4Zs9dqYbeA
# Z98wP90GXCTibvhNMA0GCSqGSIb3DQEBAQUABIIBAEqxWnXcatgQLWTGbSZrIMnu
# i72nUKlLPMFcL8LyF9pSkPCp8HPNHSk/UOdQyFM8fhHev7uu1+ocUrHd3zb72Qk0
# AA75ZSRwINtGZI0f4XoSKh5xYsIaPY+NqgbiWAbvbdAznGo1j83V7OWTlBNvlEnf
# xXxq7btSdhgwBQur7GFQG72cvMg8OXiFZQKf7wm1I1r+kPo4EQSGGMnypVHkbhc4
# mWr6DgXYvd5mP9Kv+VwG4sVcsHGE359RJ79By80Qop/XDPa5GIGH1ahFjMz0QoYu
# Timab6J5tcL64KgVHW8GUhMNeXuHPvFME6Hd69rlkoesw33OdNane6YE3Uwmgk4=
# SIG # End signature block
