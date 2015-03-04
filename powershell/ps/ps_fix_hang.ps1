Try {
    $Result = @() 
    $ErrorActionPreference = “SilentlyContinue” 
    $code = {

              $UpdateSession =New-Object -com Microsoft.Update.Session
              $UpdateSearcher = $UpdateSession.CreateupdateSearcher()	
              $SearchResult =  $UpdateSearcher.Search("IsHidden=0 and IsInstalled=1")	
              #$NeededUpdates = $searchResult.Updates
              $searchResult.Updates
}
$j = Start-Job -ScriptBlock $code

"waiting 25 seconds..."
Get-Job $j.Id | Wait-Job -Timeout 25

$NeededUpdates=get-job $j.Id| Receive-Job

Get-Job $j.Id | Remove-Job -Force

Foreach ($update in $NeededUpdates)
   {
     $Result += New-Object PSObject -Property @{ 
                     Title=$update.Title
                     HotFixID="KB"+$update.KBArticleIDs
                     ReleaseDate= '{0:MM/dd/yyyy}' -f $update.LastDeploymentChangeTime
                     Severity=$update.MsrcSeverity } 
   } 
     #LogEvent 1 "Pending update information successfully collected"
     return $Result
 }
 Catch {
        $Result += New-Object PSObject -Property @{ 
                        Title=$_
                        HotFixID="Error"
                        ReleaseDate= ''
                        Severity='' } 
        return $Result
        #LogEvent 0 "an error occured while trying to collect pending updates information: $_"}
 }