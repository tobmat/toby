# Restart the Running Healthmatics services on SCVNTSQL1

param($go)

if ("$go" -eq "go") {
   restart-service -InputObject (get-service -displayname "Healthmatics*" -cn SCVNTSQL1 | where-object {$_.Status -eq "Running"})
}
else {
   echo " "
   echo "This script will restart the running Healthmatics services on SCVNTSQL1" "Need to enter the parameter 'go' to actually restart the services"
   echo " "
   echo "Below are the services that will be restarted when you activate this script..."
   echo " "
   restart-service -whatif -InputObject (get-service -displayname "Healthmatics*" -cn SCVNTSQL1 | where-object {$_.Status -eq "Running"})
}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU5di/fnWly5HJV4/N9TOSyRXm
# 1uOgggI9MIICOTCCAaagAwIBAgIQyGQgAs4wJLxO1sbDL4c6SDAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2Vyc2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xMTA4MzExMzIzNTdaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# c2hlbGwgVXNlcjCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAtxKGt4dijvPa
# msfmiDyK+eH13LXH6N3AR+uytiTqLaZKYy56+CHR2y3OHzjLhcRKLuD5ZuNCRiSS
# PcXkw+SX8MSA8w4WiXp3XvOPe5OpbfPlBIJlVgUKK80xV7Q9sXVpLcnpH9qG3yXR
# wBV1b9+mWnrbIMf8TiGFDvqRPyYk2q0CAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYB
# BQUHAwMwXQYDVR0BBFYwVIAQ/wDiJab18Q1NiBeSLu3sL6EuMCwxKjAoBgNVBAMT
# IVBvd2Vyc2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQ3VBO/jsAlr5C0Mum
# MbaRwjAJBgUrDgMCHQUAA4GBAGy2OhUuB4qZBK2UlbCG6EEHdyF9XSfnECKoC3pu
# 8IELxgUtNj+WBrhfGST3JptXhlLvMDxP5vUAJdCUWlvLNrix/6xy+4U72xPXieV5
# rsZ/1ZcCQYd3lSWeejd9k2GEDGxSCXI+YGrygO83wRUCwkkYfVIEbA6DKVLr9CY0
# zbknMYIBYDCCAVwCAQEwQDAsMSowKAYDVQQDEyFQb3dlcnNoZWxsIExvY2FsIENl
# cnRpZmljYXRlIFJvb3QCEMhkIALOMCS8TtbGwy+HOkgwCQYFKw4DAhoFAKB4MBgG
# CisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcC
# AQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYE
# FNvg3FymgQh+gv1b+SOjvrXmqzghMA0GCSqGSIb3DQEBAQUABIGAcDZ47HWDMHYP
# 33vINFGumc1bJct200uacpRqeg1POrTs2/PzgYDZ1M1ROOr0ULX5srpeP7/doE+P
# vQFr+lm0U79bDqtXqHvD3aWF6DcL9XHfdfErY8Uz1tn5TLESLliI6Y3ZUoH49cYa
# M4JgiqJusAyfQFiL5M2T2ctHKWfrcfg=
# SIG # End signature block
