$csv=Import-Csv E:\scripts\ah-caas.csv

foreach ($record in $csv) {
   
   $server=$record.Server
   $path = "\\" + $server + "\" + "c$" + "\" + "inventory"
   $logpath = "$path" + "\" + "log.log"
   $logpath

   #$record.Server

  $log=get-content -tail 1 $logpath -ErrorAction SilentlyContinue

  if ($error.Count -gt 0) {
   $error >> E:\Scripts\bc_error.txt
 } else {
    
   $record.Server + ": " + $log >> E:\Scripts\bc_info.txt
 }
 $error.clear()
} 
 