# bc_info.sh
# Build xml file for Baby Chef
ts=$(date "+%Y%m%d-%H%M%S")
fpath=$(pwd)
fn=$(hostname -f)
xml_final=$fpath/$fn-$ts.xml


# create temp files
tmp0=/tmp/tmp0-$$-$RANDOM.tmp
tmp1=/tmp/tmp1-$$-$RANDOM.tmp
xml_temp=/tmp/xml_temp-$$-$RANDOM.tmp

# System Info
InvDate=$(date "+%m/%d/%Y %H:%M:%S")
IPaddress=$(ifconfig eth0 | grep "inet addr" | cut -d ":" -f2- | cut -d " " -f1)
systemFQDN=$(hostname -f)
systemName=$(echo $systemFQDN | cut -d . -f1)
systemDomain=$(echo $systemFQDN | cut -d . -f2-)

# OS Info
OSNameVer=$(cat /etc/issue.net)

# Memory Info
MemoryTotal=$(free | grep Mem | awk '{print $2}')
MemoryFree=$(free | grep Mem | awk '{print $4}')
MemoryPerUsed=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
VMemoryTotal=$(free | grep Swap | awk '{print $2}')
VMemoryFree=$(free | grep Swap | awk '{print $4}')


#Build XML
echo "<?xml version=\"1.0\"?>"                                                           > $xml_temp
echo "<ComputerAssetInformation>"                                                       >> $xml_temp
echo " <SystemConfiguration>"                                                           >> $xml_temp
echo "   <InventoryDate>$InvDate</InventoryDate>"                                       >> $xml_temp
echo "   <enclosureSerialNumber>UNKNOWN</enclosureSerialNumber>"                               >> $xml_temp
echo "   <enclosureChassisType>UNKNOWN</enclosureChassisType>"                                 >> $xml_temp
echo "   <enclosurePath>UNKNOWN</enclosurePath>"                                               >> $xml_temp
echo "   <enclosureManufacturer>UNKNOWN</enclosureManufacturer>"                              >> $xml_temp
echo "   <biosName>UNKNOWN</biosName>"                                                         >> $xml_temp
echo "   <biosVersion>UNKNOWN</biosVersion>"                                                   >> $xml_temp
echo "   <biosReleaseDate>UNKNOWN</biosReleaseDate>"                                           >> $xml_temp
echo "   <biosSMBIOSBIOSVersion>UNKNOWN</biosSMBIOSBIOSVersion>"                               >> $xml_temp
echo "   <biosSMBIOSMajorVersion>UNKNOWN</biosSMBIOSMajorVersion>"                             >> $xml_temp
echo "   <biosSMBIOSMinorVersion>UNKNOWN</biosSMBIOSMinorVersion>"                             >> $xml_temp
echo "   <systemName>$systemName</systemName>"                                          >> $xml_temp
echo "   <systemDomain>$systemDomain</systemDomain>"                                    >> $xml_temp
echo "   <systemFQDN>$systemFQDN</systemFQDN>"                                          >> $xml_temp
echo "   <systemIPAddress>$IPaddress</systemIPAddress>"                                 >> $xml_temp
echo "   <systemDomainRole>UNKNOWN</systemDomainRole>"                                         >> $xml_temp
echo "   <systemUUID>UNKNOWN</systemUUID>"                                                     >> $xml_temp
echo "   <systemType>UNKNOWN</systemType>"                                                     >> $xml_temp
echo "   <systemDescription>UNKNOWN</systemDescription>"                                       >> $xml_temp
echo "   <systemManufacturer>UNKNOWN</systemManufacturer>"                                     >> $xml_temp
echo "   <systemModel>UNKNOWN</systemModel>"                                                   >> $xml_temp
echo "   <systemProductID>UNKNOWN</systemProductID>"                                                           >> $xml_temp
echo "   <systemTimeZone>(UTC-05:00) Eastern Time (US &amp; Canada)</systemTimeZone>"   >> $xml_temp
echo "   <systemPendingReboot>UNKNOWN</systemPendingReboot>"                                   >> $xml_temp
echo "   <systemRDPconfiguration>UNKNOWN</systemRDPconfiguration>"                             >> $xml_temp
echo "   <systemCurrentCulture>English (United States)</systemCurrentCulture>"          >> $xml_temp
echo "   <systemFirewallEnabled>UNKNOWN</systemFirewallEnabled>"                               >> $xml_temp
echo "   <IsVirtual>True</IsVirtual>"                                                   >> $xml_temp
echo "   <vm_Type>UNKNOWN</vm_Type>"                                                           >> $xml_temp
echo "   <vm_PhysicalHostName>UNKNOWN</vm_PhysicalHostName>"                                   >> $xml_temp
echo "   <Cluster>UNKNOWN</Cluster>"                                                                   >> $xml_temp
echo "   <IPconfig>UNKNOWN</IPconfig>"                                                         >> $xml_temp
echo "   <Routes>UNKNOWN</Routes>"                                                             >> $xml_temp
echo " </SystemConfiguration>"                                                          >> $xml_temp
echo " <Memory>"                                                                        >> $xml_temp
echo "   <PhysicalMemoryTotalDIMMs>UNKNOWN</PhysicalMemoryTotalDIMMs>"               >> $xml_temp
echo "   <PhysicalMemoryTotalDIMMsFree>UNKNOWN</PhysicalMemoryTotalDIMMsFree>"               >> $xml_temp
echo "   <PhysicalMemoryTotal>$MemoryTotal</PhysicalMemoryTotal>"               >> $xml_temp
echo "   <PhysicalMemoryFree>$MemoryFree</PhysicalMemoryFree> "                 >> $xml_temp
echo "   <PhysicalMemoryPercentUsed>$MemoryPerUsed</PhysicalMemoryPercentUsed>" >> $xml_temp
echo "   <VirtualMemoryTotal>$VMemoryTotal</VirtualMemoryTotal>"                >> $xml_temp
echo "   <VirtualMemoryFree>$VMemoryFree</VirtualMemoryFree>"                   >> $xml_temp
echo " </Memory>"                                                               >> $xml_temp
echo " <ServerResourcesSnapshot>"                          >> $xml_temp
echo "    <FQDN>$systemFQDN</FQDN>"                          >> $xml_temp
echo "    <IPAddress>$IPaddress</IPAddress>"                          >> $xml_temp
echo "    <UpTime>15:22:37:10</UpTime>"                          >> $xml_temp
echo "    <Platform>W2K8R2</Platform>"                          >> $xml_temp
echo "    <Storage>UNKNOWN</Storage>"                          >> $xml_temp
echo "    <cpuCoreCount>UNKNOWN4</cpuCoreCount>"                          >> $xml_temp
echo "    <cpuCount>UNKNOWN1</cpuCount>"                          >> $xml_temp
echo "    <cpuAverageLoad>UNKNOWN2</cpuAverageLoad>"                          >> $xml_temp
echo "    <memoryTotal>UNKNOWN4</memoryTotal>"                          >> $xml_temp
echo "    <memoryFree>UNKNOWN3</memoryFree>"                          >> $xml_temp
echo "    <memoryPercentUsed>UNKNOWN37</memoryPercentUsed>"                          >> $xml_temp
echo "    <testbabychef>UNKNOWNbabychef</testbabychef>"                          >> $xml_temp
echo " </ServerResourcesSnapshot>"                          >> $xml_temp
#echo " <OperatingSystem>"                                                       >> $xml_temp
#echo "   <Name>$OSNameVer</Name>"                                               >> $xml_temp
#echo " </OperatingSystem>"                                                      >> $xml_temp
#echo " <Processors>"                                                            >> $xml_temp
#echo " </Processors>"                                                           >> $xml_temp
echo "</ComputerAssetInformation>"                                              >> $xml_temp

# Extract Proc information
count=0
###TotalCPUs=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
touch $tmp0
TotalCPUs=0
while [ $count -lt $TotalCPUs ]
do
   count=`expr $count + 1`
   DeviceID=$(cat /proc/cpuinfo | grep ^processor | awk '{print $3}' | sed -n "$count p")
   ProcName=$(cat /proc/cpuinfo | grep "^model name" | cut -d : -f 2 | sed -n "$count p") 
   ProcAddrW=$(cat /proc/cpuinfo | grep "^address sizes" | cut -d : -f2 | sed -n "$count p")
   ProcNumCores=$(cat /proc/cpuinfo | grep "^cpu cores" | awk '{print $4}' | sed -n "$count p")
   ProcMan=$(sudo dmidecode --type processor | grep Manufacturer: | awk '{print $2}' | sed -n "$count p")
   ProcFamily=$(sudo dmidecode --type processor | grep Family: | awk '{print $2}' | sed -n "$count p")
   ProcID=$(sudo dmidecode --type processor | grep ID: | cut -d : -f2 | sed -n "$count p")
   ProcStatus=$(sudo dmidecode --type processor | grep Status: | cut -d : -f2 | sed -n "$count p")
   ProcExClock=$(sudo dmidecode --type processor | grep "External Clock:" | cut -d : -f2 | sed -n "$count p")
   ProcMaxSpeed=$(sudo dmidecode --type processor | grep "Max Speed:" | cut -d : -f2 | sed -n "$count p")
   ProcSocket=$(sudo dmidecode --type processor sudo dmidecode --type processor | grep "Socket Designation:" | cut -d : -f2 | sed -n "$count p")
   ProcArch=$(lscpu | grep ^Architecture | awk '{print $2}')
   ProcCurrSpeed=$(sudo dmidecode --type processor | grep "Current Speed:" | cut -d : -f2 | sed -n "$count p")

   echo " <Processor>"                                                      >> $tmp0
   echo "  <DeviceID>$DeviceID</DeviceID>"                                  >> $tmp0
   echo "  <Name>$ProcName</Name>"                                          >> $tmp0
   echo "  <Manufacturer>$ProcMan</Manufacturer>"                           >> $tmp0
   echo "  <Family>$ProcFamily</Family>"                                    >> $tmp0
   echo "  <ProcessorId>$ProcID</ProcessorId>"                              >> $tmp0
   echo "  <Status>$ProcStatus</Status>"                                    >> $tmp0
   echo "  <AddressWidth>$ProcAddrW</AddressWidth>"                         >> $tmp0
   echo "  <ExternalClock>$ProcExClock</ExternalClock>"                     >> $tmp0
   echo "  <MaxClockSpeed>$ProcMaxSpeed</MaxClockSpeed>"                    >> $tmp0
   echo "  <SocketDesignation>$ProcSocket</SocketDesignation>"              >> $tmp0
   echo "  <Architecture>$ProcArch</Architecture>"                          >> $tmp0
   echo "  <CurrentClockSpeed>$ProcCurrSpeed</CurrentClockSpeed>"           >> $tmp0
   echo "  <NumberOfCores>$ProcNumCores</NumberOfCores>"                    >> $tmp0
   echo " </Processor>"                                                     >> $tmp0
done

while read line
do
 echo $line >> $tmp1 
 if [ "$line" == "<Processors>" ]; then
  cat $tmp0  >> $tmp1
 fi
done < $xml_temp

cat $tmp1 > $xml_final

#Upload File 
name_final=$fn-$ts.xml
uri_name=$(echo $name_final | sed 's/\./%2E/g')
uri="http://172.31.63.28/babychefAPI/api/serverFileUpload?filename=$uri_name"
curl -F upload=@$xml_final $uri

filenameEncoded=$(echo $v | sed -s "s|\.|%2E|g")

# cleanup temp files
rm $tmp0 $tmp1 $xml_temp
