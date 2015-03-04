
Import-Module active*

$erroractionpreference = "SilentlyContinue"
$rtn = $null
$resultsarray = $null
$facility = $null

$resultsarray =@() 
$error.clear()

if (! $facility) {
   $facility = read-host "Enter facility you want to report on.  Enter 'x' for all "
}

       switch -regex ($facility)
        { 
        "[a]" {$ADresult = Get-ADComputer -Filter { (Name -like "a*nt*") -or (Name -like "a*mf*")}} 
        "[b]" {$ADresult = Get-ADComputer -Filter { (Name -like "b*nt*") -or (Name -like "b*mf*")}} 
        "[c]" {$ADresult = Get-ADComputer -Filter { (Name -like "c*nt*") -or (Name -like "c*mf*")}} 
        "[d]" {$ADresult = Get-ADComputer -Filter { (Name -like "d*nt*") -or (Name -like "d*mf*")}} 
        "[e]" {$ADresult = Get-ADComputer -Filter { (Name -like "e*nt*") -or (Name -like "e*mf*")}} 
        "[f]" {$ADresult = Get-ADComputer -Filter { (Name -like "f*nt*") -or (Name -like "f*mf*")}} 
        "[m]" {$ADresult = Get-ADComputer -Filter { (Name -like "m*nt*") -or (Name -like "m*mf*")}} 
        "[n]" {$ADresult = Get-ADComputer -Filter { (Name -like "n*nt*") -or (Name -like "n*mf*")}} 
        "[o]" {$ADresult = Get-ADComputer -Filter { (Name -like "o*nt*") -or (Name -like "o*mf*")}} 
        "[p]" {$ADresult = Get-ADComputer -Filter { (Name -like "p*nt*") -or (Name -like "p*mf*")}} 
        "[s]" {$ADresult = Get-ADComputer -Filter { (Name -like "s*nt*") -or (Name -like "s*mf*")}} 
        "[t]" {$ADresult = Get-ADComputer -Filter { (Name -like "t*nt*") -or (Name -like "t*mf*")}} 
        "[x]" {$ADresult = Get-ADComputer  -Filter { (Name -like "a*nt*") -or (Name -like "a*mf*") -or (name -like "oaint*") -or (name -like "oaimf*") -or (Name -like "b*nt*") -or (Name -like "b*mf*") -or (Name -like "c*nt*") -or (Name -like "d*nt*") -or (Name -like "e*nt*") -or (Name -like "f*nt*") -or (Name -like "m*nt*") -or (Name -like "n*nt*") -or (Name -like "p*nt*") -or (Name -like "p*vm*") -or (Name -like "s*nt*") -or (Name -like "t*nt*")}} 
        default {
           "$facility is a unknown."
           exit
         } 
        }



foreach ($record in $ADresult) {

   $rtn = Test-Connection -CN $record.name -Count 1 -BufferSize 16 -Quiet
   IF($rtn -match 'True') {

   $os=Get-WmiObject win32_operatingsystem -computername $record.name 

   if ($error.Count -gt 0) { 

      $obj=New-Object PSObject
       
      $obj | Add-Member -MemberType "Noteproperty" -name "Computer" -value $record.Name
      $obj | Add-Member -MemberType "Noteproperty" -name "OS" -value "Can't Access Server..."
      $obj | Add-Member -MemberType "Noteproperty" -name "ServicePack" -value ""
      $obj | Add-Member -MemberType "Noteproperty" -name "Mfg" -value ""
      $obj | Add-Member -MemberType "Noteproperty" -name "Model" -value ""
      $resultsarray +=$obj
      $error.clear()

   } else {

         $sys=Get-WmiObject win32_computersystem -computername $record.name

         $obj=New-Object PSObject
         
         $obj | Add-Member -MemberType "Noteproperty" -name "Computer" -value $sys.caption
         $obj | Add-Member -MemberType "Noteproperty" -name "OS" -value $os.Caption
         $obj | Add-Member -MemberType "Noteproperty" -name "ServicePack" -value $os.csdversion
         $obj | Add-Member -MemberType "Noteproperty" -name "Mfg" -value $sys.manufacturer
         $obj | Add-Member -MemberType "Noteproperty" -name "Model" -value $sys.model

         $resultsarray +=$obj
     }
  }
 }
 $count2000=($resultsarray -like "*2000*").Count
 $count2003=($resultsarray -like "*2003*").Count
 $count2008=($resultsarray -like "*2008*").Count
 $count2012=($resultsarray -like "*2012*").Count

 $obj=New-Object PSObject
 $obj | Add-Member -MemberType "Noteproperty" -name "Computer" -value "Total 2000 Servers"
 $obj | Add-Member -MemberType "Noteproperty" -name "OS" -value $count2000
 $obj | Add-Member -MemberType "Noteproperty" -name "ServicePack" -value ""
 $obj | Add-Member -MemberType "Noteproperty" -name "Mfg" -value ""
 $obj | Add-Member -MemberType "Noteproperty" -name "Model" -value ""

 $resultsarray +=$obj
 $obj=New-Object PSObject
 $obj | Add-Member -MemberType "Noteproperty" -name "Computer" -value "Total 2003 Servers"
 $obj | Add-Member -MemberType "Noteproperty" -name "OS" -value $count2003
 $obj | Add-Member -MemberType "Noteproperty" -name "ServicePack" -value ""
 $obj | Add-Member -MemberType "Noteproperty" -name "Mfg" -value ""
 $obj | Add-Member -MemberType "Noteproperty" -name "Model" -value ""

 $resultsarray +=$obj

 $obj=New-Object PSObject
 $obj | Add-Member -MemberType "Noteproperty" -name "Computer" -value "Total 2008 Servers"
 $obj | Add-Member -MemberType "Noteproperty" -name "OS" -value $count2008
 $obj | Add-Member -MemberType "Noteproperty" -name "ServicePack" -value ""
 $obj | Add-Member -MemberType "Noteproperty" -name "Mfg" -value ""
 $obj | Add-Member -MemberType "Noteproperty" -name "Model" -value ""

 $resultsarray +=$obj

 $obj=New-Object PSObject
 $obj | Add-Member -MemberType "Noteproperty" -name "Computer" -value "Total 2012 Servers"
 $obj | Add-Member -MemberType "Noteproperty" -name "OS" -value $count2012
 $obj | Add-Member -MemberType "Noteproperty" -name "ServicePack" -value ""
 $obj | Add-Member -MemberType "Noteproperty" -name "Mfg" -value ""
 $obj | Add-Member -MemberType "Noteproperty" -name "Model" -value ""

 $resultsarray +=$obj

 $resultsarray 



# SIG # Begin signature block
# MIIPWwYJKoZIhvcNAQcCoIIPTDCCD0gCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUuVxvrcUe5iclEcfdwW3CfFTu
# Z9igggy/MIIF5zCCBM+gAwIBAgIKYU4uYQAAAAAAAzANBgkqhkiG9w0BAQUFADAm
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFN7thrTFtlbK
# 0tN4+l5J41ZbkEEOMA0GCSqGSIb3DQEBAQUABIIBACiOR69CCQWcq+knDy/QZAoZ
# esUU0fTM+WydWgz5+hGoMmgy4Ue09sEidNiNZEiD+0UoS4wWRSa8vK7WAnepDWkQ
# dW4GmVjetRP8MGy9uxEjOdvudeNdCRuEO6WLv29h+5apmQCDIPxpR3FcveVqMa4C
# wpeNIcJhoLIG0GB1YBCxbQym3W44myedbhqiLKOpf1pJfO8o9D/mtODFc9z/DGPu
# Y+8Wb1p/LNco91TdPg1LYr3C0oi+PcbQNQpp8zxMTMSG81rc5HK+eJVKITOZ1luY
# ykji35VPVriZOdIB0AfNYexhxxaQtM6HhiXXwDYQ7CmTW5tUxDKpMQMAzJsJVsc=
# SIG # End signature block
