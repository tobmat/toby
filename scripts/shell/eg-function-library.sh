 
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# script:           eg-function-library.sh
# author:           toby matherly (x15)
# purpose:          contains various functions available to us via the command line
# restrictions:     use care when updating, changes are widespread
# output:           depends on function that you call
# used by:          activated by .kshrc files for each login
# input:            depends on function that you call
# syntax:           not intended to be run manually
# example:          not intended to be run manually
# status:           completed, changes made as new function ideas occur
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
 
#trap '/bin/rm $tmp1' 1 2 3 15
 
# global alias
# alias grep='zgrep'
alias egh='/envx/scripts/eg-history.sh'
 
# function: xcd: purpose:  change directory shortcuts
# function: xcd: syntax:   xcd <env> <filename>
# function: xcd: examples: xcd tsta runtime - moves you to the runtime monk_scripts/common directory # function: xcd: examples: xcd tsta sandbox - moves you to the sandbox monk_scripts/common directory
# function: xcd: examples: xcd tsta logs    - moves you to the tsta log directory
# function: xcd: examples: xcd tsta autocip - moves you to the tsta autocip directory xcd () {
env=$1
path=$2
if [[ $(echo $1 | cut -c 1-3) = "env" ]]; then
   schema=sch_${env}_live
else
   schema=sch_${env}_test
fi   
if [[ $2 = "logs" ]]; then
  cd /${env}/egate/client/logs/
elif [[ $2 = "runtime" ]]; then
  cd /opt/egate/server/registry/repository/${schema}/runtime/monk_scripts/common
elif [[ $2 = "sandbox" ]]; then
  cd /opt/egate/server/registry/repository/${schema}/sandbox/dg_${env}/monk_scripts/common
elif [[ $2 = "autocip" ]]; then
  cd /envx/data/eg-watcher/${env}/autocip
fi
}
 
# function: listbiggies: purpose:  report record number and length of large messages in a file
# function: listbiggies: syntax:   listbiggies [then recall command from history and modify xxx (first is record size, second is file name)]
listbiggies () {
 print -n "# awk '{ if (length(\$0) > xxx ) printf (\"record #%6d length=%8d\\\n\", NR, length(\$0)) }' xxxx\0\0" >> $HISTFILE
 noop=1
}
 
# function: bigj: purpose:  report large journal files
# function: bigj: syntax:   bigj 
bigj () {
 setvar
 if [[ $mysys = oairsega01 ]]; then
    find /${schemashort}?/journal -size +10000000c -ls | sed 's/^[ ]*//g' | cut -d ' ' -f 3-  else
    find /${schemashort}?/journal -size +50000000c -ls | sed 's/^[ ]*//g' | cut -d ' ' -f 3-  fi }
 
# function: zless: purpose: does a less on a zipped file # function: zless: syntax:  zless <filename> zless () { /usr/local/bin/zcat $1 | less }
 
# function: zview: purpose: changes <CR> to <LF> for zipped files # function: zview: syntax:  zview <filename> zview () {  /usr/local/bin/zcat $1 | sed 's/,MSH/@MSH/g' | sed 's/$/@/g' | tr '\r' '\n' | tr '@' '\n' | less }
 
# function: findq: purpose:  find IQM for given iq
# function: findq: syntax:   findq <env> <iqname>
# function: findq: examples: findq a iq_i_any_afnt findq () {  setvar
 env=$1
 value=$2
 # grep "$2" /envx/data/misc/eg-iq-uuid-xref-${env}-$schematype-sch_${schemashort}${env}_$schematype.db | cut -d ":" -f 1,3 | tr ':' '\t'
 #
 # let's make this function "real-time" (as current as the most recent -c schema audit vs. waiting until the old xref file is updated (once a week))  #  grep "${2}," /envx/data/eg-watcher/${schemashort}${env}/autocip/a-*iq* | grep "iqname-service-iqmgr:" | tr ':' ',' | cut -d \, -f 2,4 | tr ',' ' '
}
 
# function: qfind: purpose:  quick find (shortcut for find command)
# function: qfind: syntax:   qfind <string>
# function: qfind: examples: qfind toby
qfind () {
 find . -name $1
}
 
# function: epicnum: purpose:  convert epic interface number to eGate component name 
# function: epicnum: syntax:   epicnum <epic interface number>
# function: epicnum: examples: epicnum 966701 epicnum () {  epic_eway=$(grep -l "$1" /envx/data/eg-watcher/common/cip/kbfiles/*ep* | cut -d "/" -f 8 | cut -d "." -f 1)  echo  echo "epic number: $1"
 echo "epic eway  : $epic_eway"
 echo
}
 
# function: tableu: purpose:  run table update for analyst and user updated tables
# function: tableu: syntax:   tableu
tableu () {
 if [[ "$mysys" = "oairsega01" ]]; then   # do extra stuff in test
  if [[ $USER = "egate" ]]; then
   current_user="envx"
  else
   current_user=$(echo $USER | cut -d "_" -f 2)
  fi
  /envx/scripts/eg-process-table-file2.sh
  /envx/scripts/eg-process-table-file.sh /$current_user/scripts/table_update.db
 else
  /envx/scripts/eg-process-table-file2.sh
 fi
}
 
# function: zhead: purpose: use head command on zip files # function: zhead: syntax:  zhead <filename> #zhead () { # if [[ -n ${1} ]]; then
#   zcat $1 | head
# fi
#}
# function: short: purpose:  list shortcut functions in .profile
# function: short: syntax:   short
short () {
 /envx/scripts/eg-shortcuts.sh
 echo
 echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 echo "all functions can be found in the /envx/scripts/eg-function-library.sh script" 
 echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}
 
# function: volume: purpose:  list number of messages every minute for given component
# function: volume: syntax:   volume <journal file> [ <alternate search string> ]
volume () {
 if [[ -n ${2} ]]; then
   zgrep ${2} ${1} | cut -c 0-12 | sed 's/....$/ &/g;s/..$/:&/g' | uniq -c | sort +1  else
   zgrep "," ${1} | cut -c 0-12 | sed 's/....$/ &/g;s/..$/:&/g' | uniq -c | sort +1  fi }
 
# function: hvolume: purpose:  list number of messages summarized by hour for given component
# function: hvolume: syntax:   hvolume <journal file> [ <alternate search string> ]
hvolume () {
 echo
 echo "Transaction volume by hour: $1 ($(date))"
 echo
 if [[ -n ${2} ]]; then
    zgrep ${2} ${1} | cut -c 0-10 | sed 's/..$/ &/g' | uniq -c | sort +1 | \
       awk 'BEGIN {min=999999; total=0; count=0; \
             printf " Trans.   Date   Hour RunTotal\n";
             printf "------- -------- ---- --------\n"} \
            {if (($1) < min) min=$1; if (($1) > max) max=$1; total=total+$1; printf "%7s %-8s  %-2s %8s\n", $1, $2, $3, total; count=count+1} \
       END   {printf "\nmaximum=%s, minimum=%s, total=%s, average=%s\n", max, min, total, (total/count)}'
 else
   zgrep "," ${1} | cut -c 0-10 | sed 's/..$/ &/g' | uniq -c | sort +1 | \
      awk 'BEGIN {min=999999; total=0; count=0; \
             printf " Trans.   Date   Hour RunTotal\n";
             printf "------- -------- ---- --------\n"} \
            {if (($1) < min) min=$1; if (($1) > max) max=$1; total=total+$1; printf "%7s %-8s  %-2s %8s\n", $1, $2, $3, total; count=count+1} \
      END   {printf "\nmaximum=%s, minimum=%s, total=%s, average=%s\n", max, min, total, (total/count)}'
 fi
}
 
# function: jcut: purpose:  remove the header from journal messages
# function: jcut: syntax:   jcut <journal file>
jcut () {
 if [[ -n ${1} ]]; then
   cut -d "," -f 10- ${1}
 else
  while read data
  do
   cut -d "," -f 10-
  done
 fi
}
 
# function: zjcut: purpose:  remove the header from compressed journal files
# function: zjcut: syntax:   zjcut <journal file>
zjcut () {
 /usr/local/bin/zcat ${1} | jcut
}
 
# function: downstream: purpose:  get downstream systems for a given inbound
# function: downstream: syntax:   downstream <envid> <inbound eWay>
downstream () {
 setvar
 grep ^${2}, /envx/data/eg-system-check/sch_${schemashort}${1}_$schematype-xref.txt | cut -d , -f 1,4,7 | sort -u }
 
# function: upstream: purpose:  get upstream systems for a given outbound
# function: upstream: syntax:   uptream <envid> <outbound eWay>
upstream () {
 setvar
 grep ${2}, /envx/data/eg-system-check/sch_${schemashort}${1}_$schematype-xref.txt | cut -d , -f 7,1,2,4 | sort -u | sed 's/\(.*\),\(.*\),\(.*\),\(.*\)/\4 -- \1,\2,\3/g'
}
 
 
mstream () {
 setvar
 first="$1"
 if [[ "$first" = @(all|ALL|All) ]]; then
  if [[ "$mysys" = "oairsega01" ]]; then
   first=$(/envx/scripts/eg-valid-schema-envs.sh -t)
  fi
  if [[ "$mysys" = "oairsega02" ]]; then
   first=$(/envx/scripts/eg-valid-schema-envs.sh -l)
  fi
 fi
 
 if [[ "${#first}" != "1" ]]; then
  let count=0
  for env in $(echo "$first" | sed 's/ */ /g')
  do
   let count=count+1
   if (( count == 1 )); then
             stream $env $2        | xargs -I {} echo "$env: {}" | sed 's/^.. Source System/   Source System/g;s/^.: -------/   -------/g'
    output=$(stream $env $2 nohead | xargs -I {} echo "$env: {}" )
   else
             stream $env $2 nohead | xargs -I {} echo "$env: {}" | sed 's/^.. Source System/   Source System/g;s/^.: -------/   -------/g'
    output=$(stream $env $2 nohead | xargs -I {} echo "$env: {}")
   fi
   if [[ "$output" != "" ]]; then
    echo
   fi
  done
 else
  stream $1 $2
 fi
}
 
 
# function: stream: purpose:  get upstream or downstream systems for a given component
# function: stream: syntax:   stream <envid> <eWay>
stream () {
 setvar
 if [[ "$2" = ew_o_* ]]; then
  if [[ "$3" != "nohead" ]]; then
   echo
   echo "  Destination          Source System        Message Type            mm_x component"
   echo "  ------------------   -----------------    ---------------------   ------------------"
  fi
 
  grep ${2}, /envx/data/eg-system-check/sch_${schemashort}${1}_$schematype-xref.txt | cut -d , -f 7,1,2,4 | sort -u | sed 's/\(.*\),\(.*\),\(.*\),\(.*\)/\4,\1,\2,\3/g' |  awk -F "," '{ printf "  %-20s %-20s %-23s %-20s\n", $1, $2, $3, $4}'
  if [[ "$3" != "nohead" ]]; then
   echo
  fi
 elif [[ "$2" = mm_* ]]; then
  if [[ "$3" != "nohead" ]]; then
   echo
   echo "  mm_x component       Source System        Message Type            Destination"
   echo "  ------------------   -----------------    ---------------------   ------------------"
  fi
 
  grep ${2}, /envx/data/eg-system-check/sch_${schemashort}${1}_$schematype-xref.txt | cut -d , -f 7,1,2,4 | sort -u | sed 's/\(.*\),\(.*\),\(.*\),\(.*\)/\3,\1,\2,\4/g' |  awk -F "," '{ printf "  %-20s %-20s %-23s %-20s\n", $1, $2, $3, $4}'
  if [[ "$3" != "nohead" ]]; then
   echo
  fi
 else
  if [[ "$3" != "nohead" ]]; then
   echo
   echo "  Source System        Destination          Message Type            mm_x component"
   echo "  ------------------   -----------------    ---------------------   ------------------"
  fi
 
  grep ${2}, /envx/data/eg-system-check/sch_${schemashort}${1}_$schematype-xref.txt | cut -d , -f 1,2,4,7 | sort -u | sed 's/\(.*\),\(.*\),\(.*\),\(.*\)/\1,\4,\2,\3/g' |  awk -F "," '{ printf "  %-20s %-20s %-23s %-20s\n", $1, $2, $3, $4}' | sort
  if [[ "$3" != "nohead" ]]; then
   echo
  fi
 fi
}
# function: updatet: purpose:  shortcut for update templates
# function: updatet: syntax:   updatet <envid> <eGate file>
updatet () {
 setvar
 suffix=$(echo "$2" | cut -d \. -f 2)
 prefix=$(echo "$2" | cut -d \. -f 1)
 
 /envx/scripts/eg-update-templates.sh -X -f $2 -s sch_${schemashort}${1}_$schematype -m ${schemashort}
 
 if [[ $suffix = "cfg" ]]; then
   /envx/scripts/eg-update-templates.sh -X -f $prefix.sc -s sch_${schemashort}${1}_$schematype -m ${schemashort}  fi  if [[ $suffix = "sc" ]]; then
   /envx/scripts/eg-update-templates.sh -X -f $prefix.cfg -s sch_${schemashort}${1}_$schematype -m ${schemashort}  fi }
 
# function: promote: purpose: shortcut to promote to runtime # function: promote: syntax:  promote <envid> <file> promote () {  setvar  if [[ ${schemashort} = "tst" ]]; then
 
   suffix=$(echo "$2" | cut -d \. -f 2)
   prefix=$(echo "$2" | cut -d \. -f 1)
 
   /envx/scripts/eg-promote-to-runtime.sh -x -e $1 -m ${schemashort} -f $2
   if [[ $suffix = "cfg" ]]; then
      /envx/scripts/eg-promote-to-runtime.sh -x -e $1 -m ${schemashort} -f $prefix.sc
   fi
   if [[ $suffix = "sc" ]]; then
      /envx/scripts/eg-promote-to-runtime.sh -x -e $1 -m ${schemashort} -f $prefix.cfg
   fi
 else
   echo " Not currently supported in production... "
 fi
}
 
# function: helpt: purpose: no one really knows... :) # function: helpt: syntax:  helpt <text> helpt () {
  echo "/home/x15/doc/toby_notes.db"
  grep "$1" /home/x15/doc/toby_notes.db
}
 
# function: home: purpose:  setup for home
# function: home: syntax:   home
home () {
   echo "Setting columns to 110 for home PC"
   export COLUMNS=110
}
# function: vport: purpose: display saved eg-port-manager.txt output # function: vport: syntax:  vport vport () {
  less /envx/data/dr/eg-port-manager.txt }
 
# function: segcmd: purpose: super egcmd # function: segcmd: syntax:  segcmd <env> <command> <list of components space delimited> segcmd () { command="egcmd -K -q $1 $2 "
shift
shift
while [[ $# -gt 0 ]]; do
  echo $command $1 | sh
  shift
done
}
 
# function: defcheck: purpose: check ais-local-defs for errors # function: defcheck: syntax:  defcheck <must be logged into environment> defcheck () {  setvar  env=$(echo $HOME | cut -c 5)  if [[ $env = @($valid_schemas) ]]; then
   stctrans -md -mi $HOME/egate/client/monk_library/ais-standard-defs.monk $HOME/scripts/ais-local-defs.monk  else
   echo "You must be logged into environment of the ais-local-def you want to check!"
 fi
}
 
# function: kbcheck: purpose:  run ifcheck to test kb format
# function: kbcheck: syntax:   kbcheck <envid> <eGate component>
# function: kbcheck: examples: kbcheck a ew_i_afnt kbcheck () {
 env=$1
 component=$2
 /envx/scripts/eg-ifcheck.sh -e $env -c $component -a 104Sd010 -zprior_alert_count=2 }
 
setvar () {
 
 mysys=$(hostname -s)      # my system name
 
 if [[ $mysys = oairsega01 ]]; then
    schematype=test
    schemashort=tst
    valid_schemas=$(/envx/scripts/eg-valid-schema-envs.sh -t | tr ' ' '|')  else
    schematype=live
    schemashort=env
    valid_schemas=$(/envx/scripts/eg-valid-schema-envs.sh -l | tr ' ' '|')  fi
 
}
