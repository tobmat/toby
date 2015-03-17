

  <#
.Synopsis
   Sets local user variables needed to access OpenStack environment using command line tools
.DESCRIPTION
   Parses admin-openrc.sh file downloaded from OpenStack environment to set local user enviroment variables.
.EXAMPLE
   .\set_openstack_user_var.ps1 -filename <full path to file>\admin-openrc.sh
.INPUTS
   Fully qualified path to admin-openrc.sh, default is set to "U:\scripts\input\admin-openrc.sh"
.OUTPUTS
   Prior Local Variable values (blank if they didn't exist before)
.NOTES
   To download admin-openrc.sh from OpenStack go to Access & Security, API Access tab, and select "Download OpenStack RC File".
.FUNCTIONALITY
   Setup
#>
param($filename=".\source\admin-openrc.sh")

if (test-path $filename) {

 function set_user_var($var_name,$var_value)
 {
  "Set-Item -Path Env:$var_name -Value $var_value" >> .\source\${newfile}.ps1
 }

 $varline=select-string -path $filename -Pattern "export"
 $tenant=select-string -path $filename -Pattern "OS_TENANT_NAME"
 $temp=$tenant.ToString().Split(" ")[1]
 $newfile=$temp.Split("=")[1].Replace('"',"")
 if (test-path .\source\${newfile}.ps1){
 del .\source\${newfile}.ps1
 }

 foreach ($line in $varline) {
   $temp=$line.ToString().Split(" ")[1]
   $var_name=$temp.Split("=")[0]
   $var_value=$temp.Split("=")[1].Replace('"',"")
   if ($var_name -eq "OS_PASSWORD") {
    $version=Read-Host "Select version to run 'm' for Mirantis or 'p' for Piston"
    if ($version -eq "m") {
      $var_value="Interactive2014"
      set_user_var "OS_AUTH_URL" "http://198.11.218.194:5000/v2.0"
    }else { 
      $var_value="plumgrid"
      set_user_var "OS_AUTH_URL" "http://62.193.12.3:5000/v2.0"
    }
   }
   set_user_var $var_name $var_value 
 }

} else { "Please enter a valid filename, $filename does not exist!"}
