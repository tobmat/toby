$rtn = $null

$nopingarray = $null
$nopingarray =@() 

$pingarray = $null
$pingarray =@() 

$csv=Import-Csv U:\scripts\input\ah-caas.csv

foreach ($record in $csv) {
  
   #$record.Server
   # Get results of connection test   
   $rtn = Test-Connection -CN $record.Server -Count 1 -BufferSize 16 -Quiet
   IF($rtn -match 'True') { write-host -ForegroundColor green $record.Server 

        $pingarray +=$record
     }
     ### if not true write server name in red
     ELSE { Write-host -ForegroundColor red $record.Server 

        $nopingarray +=$record

     } 
}

$pingarray  | Export-Csv U:\scripts\output\ah-caas-ping.csv -NoTypeInformation
$nopingarray  | Export-Csv U:\scripts\output\ah-caas-noping.csv -NoTypeInformation
