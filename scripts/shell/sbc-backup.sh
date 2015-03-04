#!/bin/bash
#!/usr/bin/expect

#------------------------------------------------- #
d=`date +%Y%m%d-%H%M%S`

while read line; do
IFS=","
set -- $line
{
# create backup
/usr/bin/expect << EOF
 spawn ssh user@$1
 expect "password: "
 send "acme\n"
 expect ">"
 send "en\n"
 expect "Password:"
 send "packet\n"
 expect "#"
 send "backup-config $2_$d\n"
 expect "task done"
 send  "exit\n"
 expect ">"
 send "exit\n"

# copy back locally
 spawn ftp $1
 expect "Name ($1:devops): "
 send "user\n"
 expect "Password:"
 send "acme\n"
 expect "ftp> "
 send "cd /code/bkups\n"
 expect "ftp>"
 send "get $2_$d.gz\n"
 expect "ftp>"
 send "delete $2_$d.gz\n"
 expect "250 DELE command successful."
 send "gye\n"
 send "\n"

EOF
}
done < /home/devops/sbc/list


#Upload backups to adminhub
files=(*.gz)
for f in "${files[@]}"
do
  fn=$(echo $f |cut -d'_' -f1)
  uri_name=$(echo $fn | sed 's/\./%2E/g')
  uri="http://172.31.63.28/babychefAPI/api/NetworkSBCFileUpload?filename=$uri_name&uploadType=backup"
  curl -F upload=@$f $uri
done
rm *.gz
