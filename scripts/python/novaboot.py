#neutron net-show phase3_network | Select-String " id " | %{$data = $_.tostring().split("|")}
#$test =$data[2].split(" ")
#$test[1]

nova boot --image "Server2012R2" --flavor 3 tobytest --nic net-id=06e3f074-ecd8-46e6-80c4-201fa832b1b9 --nic net-id=9065ca99-013f-4857-8d1d-cdb4dd911573 --security-groups "secgroup_open" --user-data C:\Users\Toby.Matherly\Documents\GitHub\caas2\scripts\test.ps1
#nova boot --image fbeeeb51-1bf8-4af2-919e-b2d1069ade66 --flavor 3 tobytest --nic net-id=06e3f074-ecd8-46e6-80c4-201fa832b1b9 --nic net-id=9065ca99-013f-4857-8d1d-cdb4dd911573 --security-groups "secgroup_open" --user-data C:\Users\Toby.Matherly\Documents\GitHub\caas2\scripts\test.ps1