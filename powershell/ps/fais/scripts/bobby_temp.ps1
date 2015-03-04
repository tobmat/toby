Run this command, output to csv
Get-ADComputer -Filter { ((Name -like "a*nt*") -or (Name -like "a*mf*") -or (name -like "oaint*") -or (name -like "oaimf*") -or (Name -like "b*nt*") -or (Name -like "b*mf*") -or (Name -like "c*nt*") -or (Name -like "d*nt*") -or (Name -like "e*nt*") -or (Name -like "f*nt*") -or (Name -like "m*nt*") -or (Name -like "n*nt*") -or (Name -like "p*nt*") -or (Name -like "p*vm*") -or (Name -like "s*nt*") -or (Name -like "t*nt*")) } -properties name, operatingsystem | sort name | select name | Export-Csv C:\scripts\data\ADlist.csv

Run this script
Run ping_servers_list_output.ps1

# enter this command -> note - need to copy tm_handy module to your pc

Get-PendingReboot -ComputerName (Get-Content C:\scripts\data\ADlist2.txt) | ogv -PassThru | Export-Csv c:\scripts\data\pending_reboot.csv