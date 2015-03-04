if (test-path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\")
 {
   "Look for chef uninstall in Wow6432Node!"
   $ustring=(Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object displayname, uninstallstring |Where-Object {$_.DisplayName -like "chef*"}).uninstallstring
   if ($ustring) 
    { 
     $ustring=$ustring.Replace("/I","/X")
     $ustring + " /silent /log c:/chef_uninstall.log"  
    } 
   elseif (test-path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\")
    {
      "Look for chef uninstall in old place!"
      $ustring=(Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object displayname, uninstallstring |Where-Object {$_.DisplayName -like "chef*"}).uninstallstring
      if ($ustring) 
      { 
       $ustring=$ustring.Replace("/I","/X")
       $ustring + " /silent /log c:/chef_uninstall.log"  
      }
      else { "Chef not found in either location..." } 

    }
    else { "Couldn't find Chef in either registry location..." }
 }
elseif (test-path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\")
 {
   "Must be a 2003 machine!"
   $ustring=(Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object displayname, uninstallstring |Where-Object {$_.DisplayName -like "chef*"}).uninstallstring
   if ($ustring) 
     { 
      $ustring=$ustring.Replace("/I","/X")
      $ustring + " /silent /log c:/chef_uninstall.log"  
     } 
   else { "Couldn't find Chef installed on 2003..." }
 }
else { "Neither known registry path exists!!!" }

if ($ustring)
 {
   #Invoke-Command -ScriptBlock { & cmd /c "msiexec.exe /i c:\download\LanSchool\Student.msi" /qn ADVANCED_OPTIONS=1 CHANNEL=100}
   #Invoke-Command -ScriptBlock { param ($TargetMSI) & "$TargetMSI /silent /passive /log c:\chef_uninstall.log" } -ArgumentList $ustring
   $id=$ustring.Split("X")[1]
   MsiExec.exe /X "$id" /qn /log c:\chef_uninstall.log
    While ((Get-Process "msiexec" -ErrorAction SilentlyContinue))
    {
     "Wait until uninstall is completed to delete folder"
     Start-Sleep -Seconds 5
    }
   "delete folder" 
   Remove-Item C:\chef -Recurse -force 
 } 
 else
 {
  "Chef program not found in the registry...."
 }
 