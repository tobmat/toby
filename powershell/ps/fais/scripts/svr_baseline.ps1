# Name   : svr_baseline.ps1
# Purpose: Complete Server baseline tasks for 2003, 2008, 2008R2 servers
# Date   : ???
# Author : Toby Matherly (x15)
# Detail :
#          1.  Set guest password and disable account
#          2.  Set remote desktop
#          3.  Add Needed groups to local admin group
#          4.  Set password and flags for Linus account
#
# Update : 2013-04-01 randomize Guest Account pw
# Update : 2013-07-12 fix issue setting Admin account to password doesn't expire
#
param($strComputer)

## Turn off ugly red errors! ##
$erroractionpreference = "SilentlyContinue"

##### Local function
# Add, Remove or List users in a server's local group.  User is assumed to be a domain user.

function local($server, $group, $user, $action, $detail)
{
  if (! $server) {
    $server = read-host "Enter server: "
  }

  if (! $group) {
    $group = read-host "Enter group: "
  }

  if (! $action) {
    $action = read-host "Add, Remove or List: "
  }

  $objGroup = [ADSI]("WinNT://$server/$group")

  if ($action.ToLower() -eq "list") {
    $members = @($objGroup.psbase.Invoke("Members"))
    $members | foreach {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)} 
  }

  else {

    if (! $user) {
      $user = read-host "Enter domain user id: "
    }
    $objADUser = [ADSI]("WinNT://$user")
    $objGroup.PSBase.Invoke($action,$objADUser.PSBase.Path)
    if(-not $?) {
      echo "  "
      echo "+++ WARNING, the follow action failed +++"
      echo "   "
      write-host "    >>> $detail <<<" -foregroundcolor "red"
      echo "   "
      echo "+++ If you have run this script more than once this could just mean it has already been done."
      echo "  "
    } 
    else {
      " "
      "Action: $action"
      "  User: $user"
      " Group: $group" 
    }
  }
}


##### Local function
# Generate a random password
# Usage: random-password <length>
Function random-password ($length = 15)
{
        $punc = 46..46
        $digits = 48..57
        $letters = 65..90 + 97..122
 
        # Thanks to
        # https://blogs.technet.com/b/heyscriptingguy/archive/2012/01/07/use-pow
        $password = get-random -count $length `
                -input ($punc + $digits + $letters) |
                        % -begin { $aa = $null } `
                        -process {$aa += [char]$_} `
                        -end {$aa}
 
        return $password
}
###$strGuestpw  = "Alverno123"
$strGuestpw  = random-password 10
# These are ADS_USER_FLAG_ENUM enumeration values
$EnableUser = 512 
$DisableUser = 2
$PWneverexp = 65536
$Usrcantchpw = 64

if (! $strComputer) {

  $strComputer = read-host "Enter server: "
   if (! $strComputer) {
     echo "No server was entered, cannot continue..."
     exit
   }
}

if(-not(Test-Connection -ComputerName $strComputer -Count 1 -Quiet))
{
 echo "Could not connect to $strComputer..."
}

else {
  if (dsquery computer -name $strComputer | select-string "CN=Computers") {
    echo "It looks like your server hasn't been moved from the standard OU..."
    echo "Please move your server to the correct location and try again!"
    dsquery computer -name oaintpwshell | select-string "CN=Computers"
    exit
  }

if (! $strPassword) {

   ###$strPassword = read-host "Enter Linus Password: "
   $strPassword = Get-Credential -Credential Linus
   if (! $strPassword) {
     echo "No password was entered, cannot continue..."
     exit
   }
}


# Test for SQL
if (! $strSQL) {
  $strSQL = read-host "Is SQL installed?(y|n): "
 }

if (! $strOS) {
  $strOS = read-host "Is your OS 2003 ?(y|n): "
}

 # Enable Remote Desktop
 $strRemote = read-host "Enable Remote Desktop? (y|n): "
 
 if ( "$strRemote" -eq "y" ) {
   echo "   "
   echo "+++ Activate Remote Desktop +++"
   echo "   "   
   ### Command is different between 2003 and 2008
   if ( "$strOS" -eq "y" ) {
    ### Enable RDP for 2003

    (Get-WmiObject -computername $strComputer -authentication 6 -class "win32_TerminalServiceSetting" -Namespace root\cimv2).setallowtsconnections(1) | out-null # clears unwanted output
   } 
   else {
    ### Enable RDP for 2008

    (Get-WmiObject -computername $strComputer -authentication 6 -class "win32_TerminalServiceSetting" -Namespace root\cimv2\terminalservices).setallowtsconnections(1) | out-null # clears unwanted output
   }
  "RDP has been enabled"
 }

 # set value to pass to local script
 $server = "$strComputer"

 ### Handle Group Baseline tasks ###
 #echo " Updated Admin group..."
 local $server Administrators 'ssfhs/Member Server Admins' Add 'Add Member Server Admins to Administrators group'
 ### Removed because this doesn't always happen
 ### Add <Servername Admins> group to local Administrators group
 ###$sgroup = "ssfhs/" + $server + " Admins"
 ###local $server Administrators $sgroup Add 'Add <Server> Admins to Administrators group'
 
 if ( "$strSQL" -eq "y" ) {
   local $server Administrators 'ssfhs/AIS Database' Add 'Add AIS Database Group to Administrators group'
 } 
   
 local $server Guests Guest Remove 'Remove Guest from Guests group'

### 2003 only ####
 if ( "$strOS" -eq "y" ) {
   
   local $server HelpServicesGroup Support_388945a0 Remove  'Remove HelpServicesGroup from Support_388945a0 group'

   echo "Performance Log Users: (Should only be NT AUTHORTY\NETWORK SERVICE)"
   local $server 'Performance Log Users' Guests List 
   echo "-----------------------"
   local $server Users 'ssfhs/AIS Operations' Add  'Add AIS Operations to Users group'
   
echo " Updated Users group..."

   local $server Users 'ssfhs/AIS Solution Support' Add 'Add AIS Solution Support to Users group'
   echo "Users:"  

   local $server Users 'ssfhs/AIS Operations' List
   echo "-----------------------"
   }

 ### Handle User Baseline tasks ###

 # Baseline Linus User account #
 $objUser = [ADSI]("WinNT://$strComputer/Linus, user")

 ## Set password for Linus account
 $objUser.psbase.invoke("SetPassword",$strPassword.GetNetworkCredential().password) 
 if(-not $?) {
   echo "  "
   echo "+++ The invoke for setting Linus password didn't work!  Have you moved to the correct OU?"
   echo "  "
 } 
 else {
   $objUser.psbase.CommitChanges()

   ## Set flags for Linus account
   ## Set password never expires (Can't change user password in 2012 so 2nd command will fail
   $objUser.userflags = $PWneverexp
   $objUser.setinfo()
   ## Following command also sets User can't change password flag for 2003 and 2008
   $objUser.userflags = $PWneverexp + $Usrcantchpw + $EnableUser
   $objUser.setinfo()
   " "
   "Action: Change Linus password and set flags"
 }


 # Baseline Guest User account #
 $objUser = [ADSI]("WinNT://$strComputer/Guest, user")

 ## Set password for Guest account
 $objUser.psbase.invoke("SetPassword",$strGuestpw)
 $objUser.psbase.CommitChanges()

 ## Set flags for Guest account
 $objUser.userflags = $PWneverexp + $DisableUser + $Usrcantchpw
 $objUser.setinfo()
   " "
   "Action: Baseline Guest Account"

### 2003 only ####
 if ( "$strOS" -eq "y" ) {
  
  # Baseline SUPPORT_388945a0 User account #
  $objUser = [ADSI]("WinNT://$strComputer/SUPPORT_388945a0, user")
  "Action: Baseline SUPPORT_388945a0 Account"
 } 

}

# SIG # Begin signature block
# MIIPWwYJKoZIhvcNAQcCoIIPTDCCD0gCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1rI8DLWHAkkz8Bb8lu/9MYF/
# AcKgggy/MIIF5zCCBM+gAwIBAgIKYU4uYQAAAAAAAzANBgkqhkiG9w0BAQUFADAm
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFHtjSurUVag/
# p/n/hSbLojXm0IfnMA0GCSqGSIb3DQEBAQUABIIBADpiPy1NlzUCUT2FjCTnQT23
# VRwp3++WfFZRGaDBkPYWg4/jP2jN0sNE3Cq553lP+EKst7nD1tA684PIWl6AJF0t
# f73JT7pwoVZLV7UGh0DA/u4+rE+AhAsi9pnrPtnakn9mFnZ2TweYJeGcGbm+FEfS
# puTSX4WGXSgalTGQtVa4SZACeZLE8SIqNCsFtJ+3090PPQ4SL/KdeBg5I2R5oXkO
# XuEDJ1hpEjzTQTIGLrkRr49dliEHfCDU3vyAxmPhV+shLb56sMnZXYGDidXbCia2
# 5D1X44l88/wmbOU0ifu7j/KKNEYuziVKBFDG7A0NeJI9y7XrTzwcRKhyzI8TLSI=
# SIG # End signature block
