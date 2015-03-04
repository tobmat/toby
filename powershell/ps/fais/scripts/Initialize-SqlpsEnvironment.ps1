#
# Initialize-SqlpsEnvironment.ps1
#
# Loads the SQL Server provider extensions
#
# Usage: Powershell -NoExit -Command "& '.\Initialize-SqlPsEnvironment.ps1'"
#
# Change log:
# June 14, 2008: Michiel Wories
#   Initial Version
# June 17, 2008: Michiel Wories
#   Fixed issue with path that did not allow for snapin\provider:: prefix of path
#   Fixed issue with provider variables. Provider does not handle case yet
#   that these variables do not exist (bug has been filed)
$ErrorActionPreference = "Stop"
$sqlpsreg="HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.SqlServer.Management.PowerShell.sqlps"
if (Get-ChildItem $sqlpsreg -ErrorAction "SilentlyContinue")
{
    throw "SQL Server Powershell is not installed."
}
else
{
    $item = Get-ItemProperty $sqlpsreg
    $sqlpsPath = [System.IO.Path]::GetDirectoryName($item.Path)
}

#
# Preload the assemblies. Note that most assemblies will be loaded when the provider
# is used. if you work only within the provider this may not be needed. It will reduce
# the shell's footprint if you leave these out.
#
$assemblylist = 
"Microsoft.SqlServer.Smo",
"Microsoft.SqlServer.Dmf ",
"Microsoft.SqlServer.SqlWmiManagement ",
"Microsoft.SqlServer.ConnectionInfo ",
"Microsoft.SqlServer.SmoExtended ",
"Microsoft.SqlServer.Management.RegisteredServers ",
"Microsoft.SqlServer.Management.Sdk.Sfc ",
"Microsoft.SqlServer.SqlEnum ",
"Microsoft.SqlServer.RegSvrEnum ",
"Microsoft.SqlServer.WmiEnum ",
"Microsoft.SqlServer.ServiceBrokerEnum ",
"Microsoft.SqlServer.ConnectionInfoExtended ",
"Microsoft.SqlServer.Management.Collector ",
"Microsoft.SqlServer.Management.CollectorEnum"

foreach ($asm in $assemblylist)
{
    $asm = [Reflection.Assembly]::LoadWithPartialName($asm)
}
#
# Set variables that the provider expects (mandatory for the SQL provider)
#
Set-Variable -scope Global -name SqlServerMaximumChildItems -Value 0
Set-Variable -scope Global -name SqlServerConnectionTimeout -Value 30
Set-Variable -scope Global -name SqlServerIncludeSystemObjects -Value $false
Set-Variable -scope Global -name SqlServerMaximumTabCompletion -Value 1000
#
# Load the snapins, type data, format data
#
Push-Location
cd $sqlpsPath
Add-PSSnapin SqlServerCmdletSnapin100
Add-PSSnapin SqlServerProviderSnapin100
Update-TypeData -PrependPath SQLProvider.Types.ps1xml 
update-FormatData -prependpath SQLProvider.Format.ps1xml 
Pop-Location
Write-Host -ForegroundColor Yellow 'SQL Server Powershell extensions are loaded.'
Write-Host
Write-Host -ForegroundColor Yellow 'Type "cd SQLSERVER:\" to step into the provider.'
Write-Host
Write-Host -ForegroundColor Yellow 'For more information, type "help SQLServer".'
# SIG # Begin signature block
# MIIMwwYJKoZIhvcNAQcCoIIMtDCCDLACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU5nk8eqYl16k9dqMzjoG6tm7o
# sWSgggq0MIIFMTCCBBmgAwIBAgIKQGBHegABAAApbjANBgkqhkiG9w0BAQUFADBL
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUg+nFQ1iXWFWWzLbwQiXp
# +PDDNjcwDQYJKoZIhvcNAQEBBQAEgYAes3r57kZJ1Ot0cDAayt2hwsBarGDKtcUR
# lQMYX2L2KtFr34Q07RoEUYHQDN9abqZhjs2qpPpY7ikOrp7HH0Fgo8i9Ygkh13LF
# HPGB0pKNK+TemX1scfg0xuTMl3LBF56QZtu4V9lcKH6HILwcUb+eq0XZbBXJi71W
# a4XvRATL9g==
# SIG # End signature block
