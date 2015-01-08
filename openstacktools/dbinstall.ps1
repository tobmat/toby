#neutron net-show phase3_network | Select-String " id " | %{$data = $_.tostring().split("|")}
#$test =$data[2].split(" ")
#$test[1]
param($version)

if (! $version) { 
$version=Read-Host "Select version to run 'm' for Mirantis or 'p' for Piston"
}

$image="Server2012R2"
$flavor="m1.medium"
$userdata=".\input\test.ps1"

#use "nova network-list" command to determine the network ID's you need
if ($version -eq "m"){
#Mirantis
$netid1="06e3f074-ecd8-46e6-80c4-201fa832b1b9"  #phase3
$netid2="9065ca99-013f-4857-8d1d-cdb4dd911573"  #management

$secgroup="secgroup_open"
$servername="sql01-dev.oncaas.com"
} elseif ($version -eq "p") {
#Piston
$netid1="xxx"  #CUST_INTERNAL_SECURE
$netid2="xxx"  #CUST_EXT-MGMT_NET

$secgroup="default"
$servername="CUST1-DB-01"
} else { "Please provide 'p' or 'm' to indicate version to run" }
 
nova boot --image $image --flavor $flavor --nic net-id=$netid1 --nic net-id=$netid2 --security-groups $secgroup --user-data $userdata $servername
