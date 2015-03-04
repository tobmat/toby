

Invoke-Command -ComputerName (Get-Content C:\scripts\data\sccmshort.txt) -ScriptBlock { 
    $a = $env:COMPUTERNAME
    #$wmi=gwmi win32_operatingsystem -computername $a
    #"$a Last Reboot         : " + $wmi.ConvertToDateTime($wmi.LastBootUpTime)
    $TotalGB = @{Name="Capacity(GB)";expression={[math]::round(($_.Capacity/ 1073741824),2)}}
    $FreeGB = @{Name="FreeSpace(GB)";expression={[math]::round(($_.FreeSpace / 1073741824),2)}}
    $FreePerc = @{Name="Free(%)";expression={[math]::round(((($_.FreeSpace / 1073741824)/($_.Capacity / 1073741824)) * 100),0)}}
   
    $volumes = Get-WmiObject win32_volume | Where-object {$_.Name -eq "C:\"}
    $volumes | Select SystemName, Name, Label, $TotalGB, $FreeGB, $FreePerc #| Format-Table -AutoSize
    
    
} -SessionOption (New-PSSessionOption -NoMachineProfile) | ogv