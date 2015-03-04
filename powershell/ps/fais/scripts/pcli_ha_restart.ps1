# Script to report restarts from HA events
# flags -vcenter <servername>, default localhost
#       -last <n>, <n> is last # hours, default is 24, use 72 if Monday and looking for weekend
#       -help displays help on parameters


param(
    [string]$vcenter = "oaintvcc02",
    [int]$last = 24,
    [switch]$help = $false
)
 
$maxevents = 250000
"`nScript to generate list of successful and failed VM restart attempts after an HA host failure."
if ($help) {
"Optional parameters:
-help:               display this help
-vcenter servername: connect to vCenter server servername (default is localhost)
-last n:             analyze events from the last n hours (default is 24)
"
exit
} else {
"(Use -help for list of parameters)"
}
 
$stop = get-date
$start = $stop - (New-TimeSpan -Hours $last)
 
if (!(get-pssnapin -name "VMware.VimAutomation.Core" -ErrorAction SilentlyContinue )) { add-pssnapin "VMware.VimAutomation.Core" }
 
write-host "`nConnecting to vCenter server $vcenter ..."
Connect-VIServer $vcenter | out-null
 
write-host "`nGetting all events from $start to $stop (max. $maxevents) ..."
$events = Get-VIEvent -Start $start -Finish $stop -MaxSamples $maxevents
 
write-host Got $events.Length events ...
 
write-host -nonewline "`nSearching for host failure events ..."
$ha = @()
$events | where-object { $_.EventTypeID -eq "com.vmware.vc.HA.DasHostFailedEvent" } | foreach { $ha += $_ }
write-host (" found " + $ha.Length + " event(s).")
if ($ha.Length -eq 0) {
    write-host "`nNo host failure events found in the last $last hours."
    write-host "Use parameter -last to specify number of hours to look back.`n"
    exit
} else {
    write-host ("`nLatest host failure event was " + $ha[0].ObjectName + " at " + $ha[0].CreatedTime + ".")
}
 
$events = $events | where-object { $_.CreatedTime -ge $ha[0].CreatedTime }
 
write-host "`nList of successful VM restarts:"
$events | where-object { $_.EventTypeID -eq "com.vmware.vc.ha.VmRestartedByHAEvent" } | foreach {
    write-host $_.CreatedTime: $_.ObjectName
}
 
write-host "`nList of failed VM restarts:"
$failures = @{}
$events | where-object { $_.FullFormattedMessage -like "vSphere HA stopped trying*" } | foreach {
    $vmname = $_.FullFormattedMessage.Split(" ")[6]
    if (!($failures.ContainsKey($vmname))) {
        $failures.Add($vmname,$_.CreatedTime)
        write-host $_.CreatedTime: $vmname
    }
}
 
Disconnect-VIServer -Force -Confirm:$false


# SIG # Begin signature block
# MIIMwwYJKoZIhvcNAQcCoIIMtDCCDLACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUX4QGZBF6V5Y3uS0h7dtML46J
# tm2gggq0MIIFMTCCBBmgAwIBAgIKGMkYXwABAAAoajANBgkqhkiG9w0BAQUFADBL
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU/4q3qrEV1LsfHxwt+4zw
# x7e4WOEwDQYJKoZIhvcNAQEBBQAEgYCJnvTc4hXPYfGatwCp742mWRN/fdBmjTtD
# y0dd6Zfhz2eYPlEOCnKGHl6UC4IQZbtwbq5nT9zrjeDpyL5nJQxXZ5RCca/yZ8QE
# m0sgIRi57jyy9R/6NmIPsVxjGlsffcjKFdFOCHFNVB1nNMTduBIdjPlUvEenQzDr
# NnWX6wzUwQ==
# SIG # End signature block
