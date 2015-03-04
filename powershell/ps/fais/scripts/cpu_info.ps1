# Name:    cpu_info.ps1
# Author:  web (modified by Toby Matherly)
# Details: script gathers CPU / Hyperthreading info for servers
 # This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.</pre>
# Author: Amit Banerjee

# Purpose: Helps identify the number of physical processors, logical processors and hyperthreading on the server.

# Provide the computer information
param($vComputerName)
if (! $vComputerName) {
    $vComputerName = read-host "Enter server: "
}

$vLogicalCPUs = 0

$vPhysicalCPUs = 0

$vCPUCores = 0

$vSocketDesignation = 0

$vIsHyperThreaded = -1

# Get the Processor information from the WMI object

$vProcessors = [object[]]$(get-WMIObject Win32_Processor -ComputerName $vComputerName)

# To account for older machines

if ($vProcessors[0].NumberOfCores -eq $null)

{

$vSocketDesignation = new-object hashtable

$vProcessors |%{$vSocketDesignation[$_.SocketDesignation] = 1}

$vPhysicalCPUs = $vSocketDesignation.count

$vLogicalCPUs = $vProcessors.count

}

# If the necessary hotfixes are installed as mentioned below, then the NumberOfCores and NumberOfLogicalProcessors can be fetched correctly

else

{

# For any machine of Windows Server 2008 or above

# For Windows Server 2003, KB932370 needs to be installed

# For Windows XP, KB936235 needs to be installed

$vCores = $vProcessors.count

$vLogicalCPUs = $($vProcessors|measure-object NumberOfLogicalProcessors -sum).Sum

$vPhysicalCPUs = $($vProcessors|measure-object NumberOfCores -sum).Sum

}

# Additional code can be written here to input the data below into a database

###"Logical CPUs: {0}; Physical CPUs: {1}; Number of Cores: {2}" -f $vLogicalCPUs,$vPhysicalCPUs,$vCores

if ($vLogicalCPUs -gt $vPhysicalCPUs)

{

###"Hyperthreading: Active"
$hyper="A"

}

else

{

###"Hyperthreading: Inactive"
$hyper="I"

}
"$vComputerName,{0},{1},{2},$hyper" -f $vLogicalCPUs,$vPhysicalCPUs,$vCores


# SIG # Begin signature block
# MIIMwwYJKoZIhvcNAQcCoIIMtDCCDLACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3ytfzEUKxPyGuZ1t3eGAzAzs
# ff6gggq0MIIFMTCCBBmgAwIBAgIKGMkYXwABAAAoajANBgkqhkiG9w0BAQUFADBL
# MRMwEQYKCZImiZPyLGQBGRYDb3JnMRUwEwYKCZImiZPyLGQBGRYFc3NmaHMxHTAb
# BgNVBAMTFHNzZmhzLU9BSU5UQ0FJU1MxLUNBMB4XDTEzMDExNzE5NDgxN1oXDTE0
# MDExNzE5NDgxN1owgYsxEzARBgoJkiaJk/IsZAEZFgNvcmcxFTATBgoJkiaJk/Is
# ZAEZFgVzc2ZoczEMMAoGA1UECxMDQURTMRMwEQYDVQQLEwpFbnRlcnByaXNlMQ4w
# DAYDVQQLEwVVc2VyczESMBAGA1UECxMJUGxhdCBUZXN0MRYwFAYDVQQDEw1NYXRo
# ZXJseSBUb2J5MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDtjiJklgV/uHfr
# GZcBJY43b+/tz8EkwQ3BzLxXld7dAo9IkPghe6qqQUKvLdfim4V7o6D4i4V+plZy
# ogPjp63KUY/6DSMLKBwLkTKcFZgBsAHmy0466xoAhyodvonrzBOkC2LSR8q9MO4h
# chy36ggXmwLtlox1qf4bBa5WmkCZ8QIDAQABo4ICWDCCAlQwJQYJKwYBBAGCNxQC
# BBgeFgBDAG8AZABlAFMAaQBnAG4AaQBuAGcwEwYDVR0lBAwwCgYIKwYBBQUHAwMw
# CwYDVR0PBAQDAgeAMB0GA1UdDgQWBBSIc1+JQZ3UfpD9Pte1B9cFMV1UTzAfBgNV
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
# ZmhzLm9yZzANBgkqhkiG9w0BAQUFAAOCAQEANMo0twTuX3uBhHpkA5sD3jM3Miy2
# PXH0QdZrvCyXbCYN9eerR1cyt5X8CNH9WZvtuwVBtwgkCY5YQHnPi53culqjYfGv
# Ou1Bt5giDVnqkZPFxN9se2aoHfI3V/OmPeX95gY2X1EwEodkfS2a62JHttHVo06G
# u4MM+w/EvO3DEuF9XAyJDbfXyciPP/MfA3ZRmB5GoRIUW2XU1PDK8mU82+UUFWM7
# qswHCbVaTvlXSoJnK4LE+yUVWVGAHyyukIT8afZ/Y1LH2UXMnXc8pfL5xoJog8b3
# 0fO5Z6e79KRLMCzZWDL4FyMNgj42vshADj3fNWVzW04vd7IJI3qbSoyf9jCCBXsw
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
# MS1DQQIKGMkYXwABAAAoajAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUEEPyB5/g5Nk6wm4NEtPg
# neiRM6owDQYJKoZIhvcNAQEBBQAEgYBWQ+6+sf8zDWJz4SXwEHQRrFXyHZg1OeW5
# 1uWNQeXZkQzCUzdXNqp3mLhsryh96ZDnhOuuARC/qVIQXLs3Ysjd8qgHWnH4n+Qi
# Ts7j6FZzoRlWTPxsbgJ0wgPpicgQ5rX+714XjNwBRHn7hOX0A37YfR1X7QsnCkzo
# 7JLneeiq0g==
# SIG # End signature block
