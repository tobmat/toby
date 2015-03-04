<#
.Synopsis
   Sets local user variables needed to access OpenStack environment using command line tools
.DESCRIPTION
   Parses admin-openrc.sh file downloaded from OpenStack environment to set local user enviroment variables.
.EXAMPLE
   .\set_openstack_user_var.ps1 -filename <full path to file>\admin-openrc.sh -password <password>
.INPUTS
   Fully qualified path to admin-openrc.sh, default is set to "U:\scripts\ps\input\admin-openrc.sh"
   Password - Default is Interactive2014
.OUTPUTS
   Prior Local Variable values (blank if they didn't exist before)
.NOTES
   To download admin-openrc.sh from OpenStack go to Access & Security, API Access tab, and select "Download OpenStack RC File".
.FUNCTIONALITY
   Setup
#>
param($filename="U:\scripts\ps\input\admin-openrc.sh",$password="Interactive2014")

if (test-path $filename) {

 function set_user_var($var_name,$var_value)
 {
  [Environment]::SetEnvironmentVariable($var_name, $var_value, "User")
  #"Var Name: $var_name"
  #"Var Value: $var_value"
 }

 $varline=select-string -path $filename -Pattern "export"
 " "
 "====================================="
 "Values Before:"
 "OS_PASSWORD:    $Env:OS_PASSWORD"
 "OS_TENANT_ID:   $Env:OS_TENANT_ID"
 "OS_TENANT_NAME: $Env:OS_TENANT_NAME"
 "OS_USERNAME:    $Env:OS_USERNAME"
 "====================================="
 " "
 "Note:  You must open new powershell session for variables to take effect!!!"

 foreach ($line in $varline) {
   $temp=$line.ToString().Split(" ")[1]
   $var_name=$temp.Split("=")[0]
   $var_value=$temp.Split("=")[1].Replace('"',"")
   if ($var_name -eq "OS_PASSWORD") {
    $var_value=$password
   }
   set_user_var $var_name $var_value
 }
} else { "Please enter a valid filename, $filename does not exist!"}
