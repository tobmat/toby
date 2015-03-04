$choice = read-host "Which POC would you like to access? (Enter P for (Piston/Plumgrid) or M for (Mirantis)"

#set tenant name
Set-Item -Path Env:OS_TENANT_NAME -Value "admin"
$choice
if ($choice -eq "P") {
  echo "here I am P!"
  # grant access to admin tenant to get tenant list
  Set-Item -Path Env:OS_TENANT_ID -Value "359f2f272c6143ec9e9f6b47f9a1bad8"
  Set-Item -Path Env:OS_PASSWORD -Value "plumgrid"
  Set-Item -Path Env:OS_AUTH_URL -Value "http://62.193.12.3:5000/v2.0"
} elseif ($choice -eq "M") {
  echo "here I am M!"
  Set-Item -Path Env:OS_TENANT_ID -Value "21bfa81a22aa4761bee0dfc8c13bc4bf"
  Set-Item -Path Env:OS_PASSWORD -Value "INTERACTIVE2014"
  Set-Item -Path Env:OS_AUTH_URL -Value "http://198.11.218.194:5000/v2.0"
} else { "Your choice is invalid at this time." }

# Display tenant list
keystone tenant-list
$tenantid = Read-Host "Copy and paste tenant ID from above"
$tenantname = Read-Host "Copy and paste tenant name from above"

Set-Item -Path Env:OS_TENANT_NAME -Value $tenantname
Set-Item -Path Env:OS_TENANT_ID -Value $tenantid

"You should be all set!"
