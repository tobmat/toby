# Script to report snapshots
# flags -vcenter <servername>, default localhost
#       -help displays help on parameters

param(
    [string]$vcenter = "oaintvcs01",
    [switch]$help = $false
)
 
"`nScript to increase disk size."
if ($help) {
"Optional parameters:
-help:               display this help
-vcenter servername: connect to vCenter server servername (default is localhost)
"
exit
} else {
"(Use -help for list of parameters)"
}
 
if (!(get-pssnapin -name "VMware.VimAutomation.Core" -ErrorAction SilentlyContinue )) { add-pssnapin "VMware.VimAutomation.Core" }
 
write-host "`nConnecting to vCenter server $vcenter ..."
Connect-VIServer $vcenter | out-null

"This script will allow you to increase the size of a VM disk and complete the diskpart on the server"
"Use with caution..." 
$vmname = read-host "Enter name of VM : "
### Convert space to GB ###
$TotalGB = @{Name="Capacity(GB)";expression={[math]::round(($_.CapacityKB / (1024 *1024)),2)}}

### Get disk info from VM ###
$diskinfo=Get-HardDisk -VM $vmname

### Display disk info ###
$diskinfo | select Parent, Name, $TotalGB

$diskneeded = read-host "Enter which disk you want to expand: "
$expand = "Hard disk " + $diskneeded

$newValue= read-host "What is the new total amount of disk you need for $expand ? "
$number = $newValue -as [Double]
### Convert to KB
$totalKB=[math]::round(($number * (1024 *1024)),2)

$diskinfo=Get-HardDisk -VM $vmname -name $expand

$diskinfo | Set-HardDisk -CapacityKB $totalKB

Disconnect-VIServer -Force -Confirm:$false

"Connect to diskpart to add disk to OS"
invoke-command -ComputerName $vmname -ScriptBlock {"rescan", "list volume" | diskpart}

$volume = read-host "Select Volume to Extend:"
$select = "select volume $volume"
invoke-command -ComputerName $vmname -ScriptBlock {
 param($value) 
 $value, "extend", "exit" | diskpart} -argumentlist $select


# SIG # Begin signature block
# MIIMwwYJKoZIhvcNAQcCoIIMtDCCDLACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+FkrJBs2t8/2EkETfAaUYFAM
# bsSgggq0MIIFMTCCBBmgAwIBAgIKQGBHegABAAApbjANBgkqhkiG9w0BAQUFADBL
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU//FJUIPBIile7TFbY5a0
# EeIffoEwDQYJKoZIhvcNAQEBBQAEgYAtkymcQtatnTtM34L5MoeWtRlmPAthFO4Q
# KVqsPQFmT5/pjxCHLHNEQJN+5nHruDZvBRVICi+6sN1+C0Wfs2LQ9Q4kn9C/T62f
# 7u1bXY0YEvVQk0WvyVpLnHzr+X7ddtWT13AD6N1/8bRqlXyA5n8BQdox/2H8n0rr
# iGtqQJsGXw==
# SIG # End signature block
