
param($version)

if (! $version) { 
$version=Read-Host "Select version to run 'm' for Mirantis or 'p' for Piston"
}

$yaml='.\python\build-2nic-vm.yaml'
$stackname='stackname'

if ($version -eq 'm'){
 $vmname='sql01-test.oncaas.com'
 $local_network='phase3_network'
 $managment_network='management_network'
}

if ($version -eq 'p'){
 $local_ip='10.0.0.100'
 $management_ip='62.193.13.171'
 $vmname='DEV-DB-01'
 $local_network='DEV_INTERNAL_SECURE'
 $managment_network='DEV_EXT-MGMT_NET'
}

 
if ($version -eq 'm'){
heat stack-create -f $yaml -P name=$vmname -P nw_local=$local_network -P nw_mgt=$managment_network $stackname
}

if ($version -eq 'p'){
heat stack-create -f $yaml -P name=$vmname -P nw_local=$local_network -P ip_local=$local_ip -P nw_mgt=$managment_network -P ip_mgt=$management_ip $stackname
}
