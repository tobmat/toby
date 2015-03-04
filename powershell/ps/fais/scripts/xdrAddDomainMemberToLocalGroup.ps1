Function Add-DomainMemberToLocalGroup
{ 
  [cmdletBinding()] 
  Param
  (
    [Parameter(Mandatory=$True)] [string]$computer,
    [Parameter(Mandatory=$True)] [string]$group,
    [Parameter(Mandatory=$True)] [string]$domain,
    [Parameter(Mandatory=$True)] [string]$member 
  )

  $de = [ADSI]"WinNT://$computer/$Group,group" 
  $de.psbase.Invoke("Add",([ADSI]"WinNT://$domain/$member").path)
} #end function Add-DomainMemberToLocalGroup

Function Convert-CsvToHashTable 
{ 
  Param([string]$path) 
  $hashTable = @{} 
  import-csv -path $path |  
  foreach-object
  { 
    if($_.key -ne "") 
    {
      $hashTable[$_.key] = $_.value
    } 
    Else
    {
      Return $hashtable
      $hashTable = @{}
    }
  } 
} #end function convert-CsvToHashTable 


Function Test-IsAdministrator 
{ 
  param()  
  $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent() 
  (New-Object Security.Principal.WindowsPrincipal $currentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) 
} #end function Test-IsAdministrator

# *** Entry point to script ***

#Add-DomainMemberToLocalGroup -computer mred1 -group HSGGroup -domain nwtraders -member bob 
If(-not (Test-IsAdministrator))  
{ "Admin rights are required for this script" ; exit } 
# Convert-CsvToHashTable -path C:\fso\addUsersToGroup.csv |  
# ForEach-Object { Add-DomainMemberToLocalGroup @_ }


Add-DomainMemberToLocalGroup -computer d12c0934 -group administrators -domain ssfhs -member "member server admins"
# SIG # Begin signature block
# MIIEHQYJKoZIhvcNAQcCoIIEDjCCBAoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJQDPB8mIAphfQxmWNy+mb8Vi
# O3egggIxMIICLTCCAZqgAwIBAgIQ8HDaMjy48IJGsMuXkmLObDAJBgUrDgMCHQUA
# MCIxIDAeBgNVBAMTF1hEUiBTY3JpcHQgU2lnbmluZyBDZXJ0MB4XDTEzMDQxNzIy
# MjE0M1oXDTM5MTIzMTIzNTk1OVowIjEgMB4GA1UEAxMXWERSIFNjcmlwdCBTaWdu
# aW5nIENlcnQwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALWQSoYD8h+JGySa
# oAe2zWhXemwTtWuFikgl0Lu0a2kbJbIHbCTJsXKXEokCN+z69NPFFT5HFaTc6BrZ
# mFvz4IQPh9SCaxsKGxEqSdZsNnMY/ypd4ABJ/tds/Kyvf6fopaFGBQK3Fwnrrd/u
# /BajkQ6Fl1p9yWOAlxSxmA3bOYp3AgMBAAGjbDBqMBMGA1UdJQQMMAoGCCsGAQUF
# BwMDMFMGA1UdAQRMMEqAEFeqxqyD5V34WqJ5Aaqn/VmhJDAiMSAwHgYDVQQDExdY
# RFIgU2NyaXB0IFNpZ25pbmcgQ2VydIIQDS+jKzPHo7JIGFcQHzCjpTAJBgUrDgMC
# HQUAA4GBAB5bePT4ES2nRnJWT0iem9V3yKRiqv++GODP2NpKI930gLClIEmt+WSm
# c4Sj/pVfPqBJW5tyOcIvlCRfouVvZEkh9iLo56vh01zrxVN1OShqRLn/ckPLAvCU
# 7SGSTfZlbzC5TVvOPsxSl4z1/f49SfPaBpXCRdy3Elv9WC2wMEdKMYIBVjCCAVIC
# AQEwNjAiMSAwHgYDVQQDExdYRFIgU2NyaXB0IFNpZ25pbmcgQ2VydAIQ8HDaMjy4
# 8IJGsMuXkmLObDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKA
# ADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYK
# KwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUNJWSHj+wbif5sGXrgqsSROT5vOYw
# DQYJKoZIhvcNAQEBBQAEgYCKvIYzdoNnR6Zu2N1QJg1gn4il1Vso+QEkhghhZbP9
# CCwgeRjA5jaw2LkGa4EHQiwhsYwZ1oKnnzHQY6ZO3GMXjGaFyyBzdUOpQevciMrR
# WUWtHUtGJx5hMA/5UoxgWXcMTEBEJ/nf4rUstGuIEJ6fZLAizlhIJ6sgGMYLlbgM
# Fg==
# SIG # End signature block
