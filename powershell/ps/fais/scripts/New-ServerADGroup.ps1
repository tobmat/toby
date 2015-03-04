<#
.Synopsis
   Add <Servername> Admins group to Active Directory.
.DESCRIPTION
   Add <Servername> Admins group to Active Directory.
.EXAMPLE
   New-ServerADGroup -ComputerName A78NTDB2
.PARAMETER ServerName 
   Name of ServerName you want to create group for.
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function New-ServerADGroup
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param
    (
        # Param1 help description
        [Parameter( 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]

        [Alias("cn")] 
        $ComputerName
     )

    Begin
    {
     if (! $ComputerName) {
       $ComputerName = read-host "Enter Server Name: "
    }
     $front = $ComputerName.Substring(0,1)
    }
    Process
    {

      # test first character of servername to determine location 
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

        New-ADGroup -Name "$ComputerName Admins" -SamAccountName "$ComputerName Admins" -GroupCategory Security -GroupScope Global -DisplayName "$ComputerName Admins" -Path "OU=Security Groups,$OU,OU=ADS,DC=ssfhs,DC=org" -Description "$ComputerName Admins"

    }

    End
    {
    }
}






# SIG # Begin signature block
# MIIPWwYJKoZIhvcNAQcCoIIPTDCCD0gCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQURZSV9uGxBAN5FSdYaCmq2VFq
# 0PKgggy/MIIF5zCCBM+gAwIBAgIKYU4uYQAAAAAAAzANBgkqhkiG9w0BAQUFADAm
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFKxdQrmpK5wc
# xm1QE4fSDFNWlGsgMA0GCSqGSIb3DQEBAQUABIIBAHZdVqDllamZNArGq7h2wI//
# zXjy6eABOCcgxtLCv/x6WmAzLJVpmVaAMVlod/NTFARvHo5CS06iDpdnV/UiNQgr
# ko3IVyY0fd2pJY6oqtUFLqyuHlvX0oVCFGFDOn5WXSlfun/euSHMTA/gyZfKi0mV
# mBqH4Izji20qYRgC2vGUpAxDit91y9WNcAiC1Qa0Oe4g6vSn7zZsusIrgkGArHmC
# c89K704Mbqv2Uv5jfUGfC1mIdD/dms79U+hDuN8IJpn5VPJf5RrFH9izp4Udz8ca
# 9nanl7PWWulG6rhQqTWhdN+VmhzBp+uZh/LcLnNPqU/fGJUaEFIniN1a/o1mJoY=
# SIG # End signature block
