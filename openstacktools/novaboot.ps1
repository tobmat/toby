#neutron net-show phase3_network | Select-String " id " | %{$data = $_.tostring().split("|")}
#$test =$data[2].split(" ")
#$test[1]

#+---------------------------------------------------------------+--------+
#| Name                                                          | Status |
#+---------------------------------------------------------------+--------+
#| AudioCodes-CloudImage                                         | ACTIVE |
#| CentOS 6.5 x64 (pre installed sahara agent, hdp, 2.0.6)       | ACTIVE |
#| CentOS-7                                                      | ACTIVE |
#| Fedora 20 x64 (pre installed murano agent)                    | ACTIVE |
#| Frafos-SBC-2.2.1                                              | ACTIVE |
#| NetScaler                                                     | ACTIVE |
#| Qualys                                                        | ACTIVE |
#| Server2012R2                                                  | ACTIVE |
#| TestVM                                                        | ACTIVE |
#| Ubuntu 13.10 x64 (pre installed sahara agent, vanilla, 2.3.0) | ACTIVE |
#| Ubuntu 14.04 x64 LTS                                          | ACTIVE |
#| Ubuntu 14.04 x64 LTS (pre installed sahara agent)             | ACTIVE |
#| Ubuntu 14.04 x64 LTS dev                                      | ACTIVE |
#+---------------------------------------------------------------+--------+

$image="Server2012R2"

#+-----------+-----------+------+-----------+------+-------+
#| Name      | Memory_MB | Disk | Ephemeral | Swap | VCPUs |
#+-----------+-----------+------+-----------+------+-------+
#| m1.tiny   | 512       | 1    | 0         |      | 1     |
#| m1.small  | 2048      | 20   | 0         |      | 1     |
#| i1.medium | 8192      | 20   | 0         |      | 2     |
#| m1.medium | 4096      | 40   | 0         |      | 2     |
#| c1.medium | 6144      | 100  | 100       |      | 3     |
#| m1.large  | 8192      | 80   | 0         |      | 4     |
#| m1.xlarge | 16384     | 160  | 0         |      | 8     |
#| i1.large  | 8192      | 40   | 0         |      | 4     |
#| m2.large  | 16384     | 100  | 0         |      | 4     |
#| i1.small  | 2048      | 30   | 0         |      | 1     |
#| s1.large  | 8192      | 200  | 0         |      | 4     |
#+-----------+-----------+------+-----------+------+-------+


$flavor="m1.medium"

#use "nova network-list" command to determine the network ID's you need

$netid1="06e3f074-ecd8-46e6-80c4-201fa832b1b9"
$netid2="9065ca99-013f-4857-8d1d-cdb4dd911573"
$netid3=""

#use "nova secgroup-list" to get security groups available
$secgroup="secgroup_open"

$servername="tobytest"

$userdata=".\input\test.ps1"
 
nova boot --image $image --flavor $flavor --nic net-id=$netid1 --nic net-id=$netid2 --security-groups $secgroup --user-data $userdata $servername
