# Name   : svr_nbu_install.ps1
# Purpose: Netbackup Install script
# Date   : 2013-07-05
# Author : Toby Matherly
# Detail : This currently installs NBU 7.5.0.6 x64 bit
#
# Update : 20120801: Add new media servers for priority 1-2
# Update : 20120801: oailxbkp7, oailxbkp8
# Future : 20120801: add error logic to test copy of NBU install files and cleanup

param($reboot)

# Set variables for script
$CLIENT=$env:computername
$front = $CLIENT.Substring(0,1)
$setup_path="c:\windows\temp\x64"
$script_path="\\oaintpwshell\scripts"
$response_file= "c:\windows\temp\silentclient.resp" 
$nbu_path= "\\oaintfile2\Shared\Groups\Source\NetBackup\7.5.0.6\Uncompressed Installers\Win2012_x64\PC_Clnt\x64"

# Test to see if server is joined to domain
if (test-path -Path "\\ssfhs\shared\Oshared\Groups\Source\")
{
  "Looks like server is joined to the domain, proceeding..."
  "Copying NBU install files to local machine..."
  copy $nbu_path c:\windows\temp\ -recurse
}
else
{
   "Looks like server is NOT joined to the domain, Need to log into oaintfile2 to proceed..."
   net use \\oaintfile2\shared\Groups 
   "Copying NBU install files to local machine..."
   copy $nbu_path c:\windows\temp\ -recurse
} 

# test first character of servername to determine location 
switch -regex ($front)
    { 
        "[a-f,m,n,p,s]" {$MASTERSERVER="oailxbkprm"} 
        "[a]" {$ADDITIONALSERVERS="a78lxbkpm1"} 
        "[b]" {$ADDITIONALSERVERS="bhantmedia"} 
        "[c,s]" {$ADDITIONALSERVERS="csentmedia"} 
        "[d]" {$ADDITIONALSERVERS="dmcntmedia"} 
        "[e]" {$ADDITIONALSERVERS="e01lxbkpm1"} 
        "[f]" {$ADDITIONALSERVERS="fntmedia"}
        "[m]" {$ADDITIONALSERVERS="mcbntmedia"}
        "[n]" {$ADDITIONALSERVERS="nalntmedia"}
        "[p]" {$ADDITIONALSERVERS="pcpntmedia"} 
        default {
   	           if (! $priority) {
    	             $priority = read-host "Enter DR priority, for (1-2) enter 1, for (3-6) enter 3: "
  	           }
	           if ($priority -eq "1") {
	             $MASTERSERVER="oairsbkp1" 
                     $ADDITIONALSERVERS="oairsbkp2,oailxbkp6,oailxbkp7,oailxbkp8" 

	           } 
	           elseif ($priority -eq "3") {
	             $MASTERSERVER="oailxbkp36mm" 
                     $ADDITIONALSERVERS="oailxbkp36m1,oailxbkp36m2" 

	           } 
                   else {  
                     # if no priority is entered defaulting to priority 1 settings
	             $MASTERSERVER="oairsbkp1" 
                     $ADDITIONALSERVERS="oairsbkp2,oailxbkp6,oailxbkp7,oailxbkp8" 
                   }
         } 
    }
# build response file for silent install
"INSTALLDIR:C:\Program Files\VERITAS\"         > $response_file
"MASTERSERVERNAME:$MASTERSERVER"              >> $response_file
"ADDITIONALSERVERS:$ADDITIONALSERVERS"        >> $response_file
"NETBACKUPCLIENTINSTALL:1"                    >> $response_file
"SERVERS:$MASTERSERVER,$ADDITIONALSERVERS"    >> $response_file
"CLIENTNAME:$CLIENT"                          >> $response_file
"NBSTARTTRACKER:0"                            >> $response_file
"STARTUP:Automatic"                           >> $response_file
"NBSTARTSERVICES:1"                           >> $response_file
"VNETD_PORT:13724"                            >> $response_file
"CLIENTSLAVENAME:$CLIENT"                     >> $response_file
"SILENTINSTALL:1"                             >> $response_file
"ISPUSHINSTALL:1"                             >> $response_file
"ISCUSTOMINSTALL:1"                           >> $response_file
"REBOOT:ReallySuppress"                       >> $response_file
"NUMERICINSTALLTYPE:1"                        >> $response_file
"INSTALLDEBUG:0"                              >> $response_file
"STOP_NBU_PROCESSES:0"                        >> $response_file
"ABORT_REBOOT_INSTALL:0"                      >> $response_file
"PBXCONFIGURECS:FALSE"                        >> $response_file

# remove unwanted null characters from response file
(get-content $response_file) -replace '\x00','' | set-content $response_file

# run silent install
& "$setup_path\setup.exe" -s /REALLYLOCAL /RESPFILE:"'$response_file'"

# datestamp start of install
date
"Installing NBU..."
" "

# test for setup.exe process running to determine when install is complete
do {$finished=(Get-Process setup -ErrorAction silentlycontinue).id;wait-event -Timeout 5 }
while ($finished)

if (test-path -Path "HKLM:\software\veritas\netbackup\currentversion")
  {
  "The install has completed!"
  }
else
  {
  "The install wasn't successful, please try again.  See windows logs for more info"
  }
# datestamp start of upgrade
date
"Remove NBU install files from local machine"
remove-item C:\windows\temp\x64 -Recurse

if ($reboot) {
 restart-computer
}

# SIG # Begin signature block
# MIIPWwYJKoZIhvcNAQcCoIIPTDCCD0gCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUwUoTMzXyL7jjD/jdIpRUO4RJ
# OAagggy/MIIF5zCCBM+gAwIBAgIKYU4uYQAAAAAAAzANBgkqhkiG9w0BAQUFADAm
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFELEQGT+sdEU
# 8wSBFUZ1sp294/rLMA0GCSqGSIb3DQEBAQUABIIBABC+TDyC42oVD7LDHIKxT9NJ
# 8pOXoi2BJc3ulbxdABHw2WHXyo2e0+EisZPhGuMG7RuzRZhuopHITLPApr1q04SR
# krihlU70/9gnHZjQIb64+7lV7S2T+/YmDqJC9d1eAmc9QQMHmJ2wZ2Y5bXGAfnSW
# HRBDtdtbiD3AzZzyX26QL5f8KombQunAJT3WChmXm1o3z4vOAIED6qIfLzXiaVwZ
# Hl8C4N0gBvFbO9l98y4UL3E5IwmOmH+iZXA9ZsV+RbP2aqBSYlSftFA1uw3Rm49Q
# 92yHl6iJGoo54vPZRpfD8/JXDbyzhK1rdAcKM4GAcmlRtnhITaDY2wFXS4/sD8s=
# SIG # End signature block
