#!/bin/bash
#!/bin/expect

#------------------------------------------------- #
#create temp files

while read input; do
OLDIFS=$IFS
IFS=","
set -- $input
{
tmp0=/tmp/tmp0-$$-$RANDOM.tmp
d=`date +%Y%m%d-%H%M%S`
filename="/home/devops/sbc/${2}.xml"

# create backup
(/usr/bin/expect << EOF
spawn ssh user@$1
expect "password: "
send "acme\n"
expect ">"
send "show version\n"
expect ">"
send "show uptime\n"
expect ">"
send "show power\n"
expect ">"
send "show memory\n"
expect ">"
send "show prom-info all\n"
expect ">"
send "exit\n"
send "\n"
expect ">"
EOF
) | while read line; do
     echo $line | sed 's/\r//g' | sed 's/\t//g' >> $tmp0
    done

IFS=$OLDIFS

#BUILD UPTIME
time=$(sed -n '/show uptime/,/show power/p' $tmp0 | sed -E '/show/d' | tail -1 | cut -d "-" -f 2|sed s'/ up //g'|sed s'/ days  /:/g'|sed s'/ hours  /:/g'|sed s'/ minutes  /:/g'|sed s'/ seconds//g')

#BUILD VERSION
ver1=$(sed -n '/show version/,/show uptime/p' $tmp0 | sed '/show/d' | head -1)
ver2=$(sed -n '/show version/,/show uptime/p' $tmp0 | sed '/show/d' | tail -1)

#BUILD POWER
pow1=$(sed -n '/show power/,/show memory/p' $tmp0 | sed '/show/d' | head -1)
pow2=$(sed -n '/show power/,/show memory/p' $tmp0 | sed '/show/d' | tail -1)

#BUILD MEMORY
CurrentfreeBytes=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '4p'| sed -e 's/ \+/ /g' -e 's/^ *//g' | cut -d " " -f2)
CurrentfreeBlocks=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '4p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f3)
CurrentfreeAvgBlock=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '4p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f4)
CurrentfreeMaxBlock=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '4p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f5)

CurrentallocBytes=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '5p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f2)
CurrentallocBlocks=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '5p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f3)
CurrentallocAvgBlock=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '5p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f4)
CurrentallocMaxBlock=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '5p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f5)

CurrentinternalBytes=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '6p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f2)
CurrentinternalBlocks=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '6p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f3)
CurrentinternalAvgBlock=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '6p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f4)
CurrentinternalMaxBlock=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '6p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f5)

CumulativeallocBytes=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '8p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f2)
CumulativeallocBlocks=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '8p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f3)
CumulativeallocAvgBlock=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '8p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f4)
CumulativeallocMaxBlock=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '8p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f5)

PeakallocBytes=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '10p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f2)
PeakallocBlocks=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '10p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f3)
PeakallocAvgBlock=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '10p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f4)
PeakallocMaxBlock=$(sed -n '/show memory/,/show prom-info/p' $tmp0 | sed -E '/show/d' | sed -n '10p'| sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f5)

#BUILD MAIN BOARD
main_name=$(sed -n '/Contents of Main/,/Starting MAC/p' $tmp0 | sed -n '1p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f 3-4)
main_assy=$(sed -n '/Contents of Main/,/Starting MAC/p' $tmp0 | sed -n '2p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/Assy, //g')
main_part=$(sed -n '/Contents of Main/,/Starting MAC/p' $tmp0 | sed -n '3p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
main_serial=$(sed -n '/Contents of Main/,/Starting MAC/p' $tmp0 | sed -n '4p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
main_funct=$(sed -n '/Contents of Main/,/Starting MAC/p' $tmp0 | sed -n '5p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
main_board=$(sed -n '/Contents of Main/,/Starting MAC/p' $tmp0 | sed -n '6p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
main_PCB=$(sed -n '/Contents of Main/,/Starting MAC/p' $tmp0 | sed -n '7p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
main_ID=$(sed -n '/Contents of Main/,/Starting MAC/p' $tmp0 | sed -n '8p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g' | sed 's/&/and/g')
main_format=$(sed -n '/Contents of Main/,/Starting MAC/p' $tmp0 | sed -n '9p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
main_options=$(sed -n '/Contents of Main/,/Starting MAC/p' $tmp0 | sed -n '10p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
main_man=$(sed -n '/Contents of Main/,/Starting MAC/p' $tmp0 | sed -n '11p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
main_weekyear=$(sed -n '/Contents of Main/,/Starting MAC/p' $tmp0 | sed -n '12p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
main_seq=$(sed -n '/Contents of Main/,/Starting MAC/p' $tmp0 | sed -n '13p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
main_numMAC=$(sed -n '/Contents of Main/,/Starting MAC/p' $tmp0 | sed -n '14p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
main_startMAC=$(sed -n '/Contents of Main/,/Starting MAC/p' $tmp0 | sed -n '15p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')

#BUILD HOST CPU
host_name=$(sed -n '/Contents of Host/,/Sequence/p' $tmp0 | sed -n '1p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f 3-4)
host_assy=$(sed -n '/Contents of Host/,/Sequence/p' $tmp0 | sed -n '2p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/Assy, //g')
host_part=$(sed -n '/Contents of Host/,/Sequence/p' $tmp0 | sed -n '3p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
host_serial=$(sed -n '/Contents of Host/,/Sequence/p' $tmp0 | sed -n '4p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
host_funct=$(sed -n '/Contents of Host/,/Sequence/p' $tmp0 | sed -n '5p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
host_board=$(sed -n '/Contents of Host/,/Sequence/p' $tmp0 | sed -n '6p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
host_PCB=$(sed -n '/Contents of Host/,/Sequence/p' $tmp0 | sed -n '7p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
host_ID=$(sed -n '/Contents of Host/,/Sequence/p' $tmp0 | sed -n '8p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g' | sed 's/&/and/g')
host_format=$(sed -n '/Contents of Host/,/Sequence/p' $tmp0 | sed -n '9p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
host_options=$(sed -n '/Contents of Host/,/Sequence/p' $tmp0 | sed -n '10p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
host_man=$(sed -n '/Contents of Host/,/Sequence/p' $tmp0 | sed -n '11p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
host_weekyear=$(sed -n '/Contents of Host/,/Sequence/p' $tmp0 | sed -n '12p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
host_seq=$(sed -n '/Contents of Host/,/Sequence/p' $tmp0 | sed -n '13p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')

#BUILD PHY
phy_name=$(sed -n '/Contents of PHY/,/Sequence/p' $tmp0 | sed -n '1p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| cut -d " " -f 3)
phy_assy=$(sed -n '/Contents of PHY/,/Sequence/p' $tmp0 | sed -n '2p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/Assy, //g')
phy_part=$(sed -n '/Contents of PHY/,/Sequence/p' $tmp0 | sed -n '3p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
phy_serial=$(sed -n '/Contents of PHY/,/Sequence/p' $tmp0 | sed -n '4p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
phy_funct=$(sed -n '/Contents of PHY/,/Sequence/p' $tmp0 | sed -n '5p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
phy_board=$(sed -n '/Contents of PHY/,/Sequence/p' $tmp0 | sed -n '6p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
phy_PCB=$(sed -n '/Contents of PHY/,/Sequence/p' $tmp0 | sed -n '7p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
phy_ID=$(sed -n '/Contents of PHY/,/Sequence/p' $tmp0 | sed -n '8p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g' | sed 's/&/and/g')
phy_format=$(sed -n '/Contents of PHY/,/Sequence/p' $tmp0 | sed -n '9p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
phy_options=$(sed -n '/Contents of PHY/,/Sequence/p' $tmp0 | sed -n '10p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
phy_man=$(sed -n '/Contents of PHY/,/Sequence/p' $tmp0 | sed -n '11p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
phy_weekyear=$(sed -n '/Contents of PHY/,/Sequence/p' $tmp0 | sed -n '12p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')
phy_seq=$(sed -n '/Contents of PHY/,/Sequence/p' $tmp0 | sed -n '13p' | sed -e 's/ \+/ /g' -e 's/^ *//g'| sed 's/: /:/g' | sed 's/.*://g')

# BUILD XML
echo "<?xml version=\"1.0\"?>"           > $filename
echo "<SBCAssetInformation>"             >> $filename
echo "<Configuration>"                   >> $filename
echo "<DeviceName>$2</DeviceName>"       >> $filename
echo "<DeviceIP>$1</DeviceIP>"           >> $filename
echo "<Uptime>${time}</Uptime>"          >> $filename
echo "<Version>${ver1}, ${ver2}</Version>"          >> $filename
echo "<Power>${pow1}, ${pow2}</Power>"          >> $filename
echo "</Configuration>"                   >> $filename
echo "<Memory>"                           >> $filename
echo "<CurrentfreeBytes>$CurrentfreeBytes</CurrentfreeBytes>" >> $filename
echo "<CurrentfreeBlocks>$CurrentfreeBlocks</CurrentfreeBlocks>" >> $filename
echo "<CurrentfreeAvgBlock>$CurrentfreeAvgBlock</CurrentfreeAvgBlock>" >> $filename
echo "<CurrentfreeMaxBlock>$CurrentfreeMaxBlock</CurrentfreeMaxBlock>" >> $filename
echo "<CurrentallocBytes>$CurrentallocBytes</CurrentallocBytes>" >> $filename
echo "<CurrentallocBlocks>$CurrentallocBlocks</CurrentallocBlocks>" >> $filename
echo "<CurrentallocAvgBlock>$CurrentallocAvgBlock</CurrentallocAvgBlock>" >> $filename
echo "<CurrentallocMaxBlock>$CurrentallocMaxBlock</CurrentallocMaxBlock>" >> $filename
echo "<CurrentinternalBytes>$CurrentinternalBytes</CurrentinternalBytes>" >> $filename
echo "<CurrentinternalBlocks>$CurrentinternalBlocks</CurrentinternalBlocks>" >> $filename
echo "<CurrentinternalAvgBlock>$CurrentinternalAvgBlock</CurrentinternalAvgBlock>" >> $filename
echo "<CurrentinternalMaxBlock>$CurrentinternalMaxBlock</CurrentinternalMaxBlock>" >> $filename
echo "<CumulativeallocBytes>$CumulativeallocBytes</CumulativeallocBytes>" >> $filename
echo "<CumulativeallocBlocks>$CumulativeallocBlocks</CumulativeallocBlocks>" >> $filename
echo "<CumulativeallocAvgBlock>$CumulativeallocAvgBlock</CumulativeallocAvgBlock>" >> $filename
echo "<CumulativeallocMaxBlock>$CumulativeallocMaxBlock</CumulativeallocMaxBlock>" >> $filename
echo "<PeakallocBytes>$PeakallocBytes</PeakallocBytes>" >> $filename
echo "<PeakallocBlocks>$PeakallocBlocks</PeakallocBlocks>" >> $filename
echo "<PeakallocAvgBlock>$PeakallocAvgBlock</PeakallocAvgBlock>" >> $filename
echo "<PeakallocMaxBlock>$PeakallocMaxBlock</PeakallocMaxBlock>" >> $filename
echo "</Memory>"                           >> $filename
echo "<MainBoard>"                           >> $filename
echo "<Name>$main_name</Name>" >> $filename
echo "<Assy>$main_assy</Assy>" >> $filename
echo "<PartNumber>$main_part</PartNumber>" >> $filename
echo "<SerialNumber>$main_serial</SerialNumber>" >> $filename
echo "<FunctionalRev>$main_funct</FunctionalRev>" >> $filename
echo "<BoardRev>$main_board</BoardRev>" >> $filename
echo "<PCBFamilyType>$main_PCB</PCBFamilyType>" >> $filename
echo "<ID>$main_ID</ID>" >> $filename
echo "<FormatRev>$main_format</FormatRev>" >> $filename
echo "<Options>$main_options</Options>" >> $filename
echo "<Manufacturer>$main_man</Manufacturer>" >> $filename
echo "<WeekYear>$main_weekyear</WeekYear>" >> $filename
echo "<SequenceNumber>$main_seq</SequenceNumber>" >> $filename
echo "<NumberofMACAddresses>$main_numMAC</NumberofMACAddresses>" >> $filename
echo "<StartingMACAddress>$main_startMAC</StartingMACAddress>" >> $filename
echo "</MainBoard>"                           >> $filename
echo "<HostCPU>"                           >> $filename
echo "<Name>$host_name</Name>" >> $filename
echo "<Assy>$host_assy</Assy>" >> $filename
echo "<PartNumber>$host_part</PartNumber>" >> $filename
echo "<SerialNumber>$host_serial</SerialNumber>" >> $filename
echo "<FunctionalRev>$host_funct</FunctionalRev>" >> $filename
echo "<BoardRev>$host_board</BoardRev>" >> $filename
echo "<PCBFamilyType>$host_PCB</PCBFamilyType>" >> $filename
echo "<ID>$host_ID</ID>" >> $filename
echo "<FormatRev>$host_format</FormatRev>" >> $filename
echo "<Options>$host_options</Options>" >> $filename
echo "<Manufacturer>$host_man</Manufacturer>" >> $filename
echo "<WeekYear>$host_weekyear</WeekYear>" >> $filename
echo "<SequenceNumber>$host_seq</SequenceNumber>" >> $filename
echo "</HostCPU>"                           >> $filename
echo "<PHY>"                           >> $filename
echo "<Name>$phy_name</Name>" >> $filename
echo "<Assy>$phy_assy</Assy>" >> $filename
echo "<PartNumber>$phy_part</PartNumber>" >> $filename
echo "<SerialNumber>$phy_serial</SerialNumber>" >> $filename
echo "<FunctionalRev>$phy_funct</FunctionalRev>" >> $filename
echo "<BoardRev>$phy_board</BoardRev>" >> $filename
echo "<PCBFamilyType>$phy_PCB</PCBFamilyType>" >> $filename
echo "<ID>$phy_ID</ID>" >> $filename
echo "<FormatRev>$phy_format</FormatRev>" >> $filename
echo "<Options>$phy_options</Options>" >> $filename
echo "<Manufacturer>$phy_man</Manufacturer>" >> $filename
echo "<WeekYear>$phy_weekyear</WeekYear>" >> $filename
echo "<SequenceNumber>$phy_seq</SequenceNumber>" >> $filename
echo "</PHY>"                           >> $filename
echo "</SBCAssetInformation>"             >> $filename

# cleanup temp files
rm $tmp0
}
uri_name=$(echo $filename | sed 's/\./%2E/g')
uri="http://172.31.63.28/babychefAPI/api/NetworkSBCFileUpload?filename=$uri_name&uploadType=inventory"
curl -F upload=@$filename $uri

done < /home/devops/sbc/list
