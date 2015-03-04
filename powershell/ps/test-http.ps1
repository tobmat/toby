Function Test-HTTPport
{
    $test = $false
    $computer = "85.15.17.29"
    $port = 80
    $tcpobject = new-Object system.Net.Sockets.TcpClient 
    #Connect to remote machine's port               
    $connect = $tcpobject.BeginConnect($computer,$port,$null,$null) 
    #Configure a timeout before quitting - time in milliseconds 
    $wait = $connect.AsyncWaitHandle.WaitOne(1000,$false) 
 
    If (-Not $Wait) 
        {
            $test= $false
        } 
    Else 
        {
            $error.clear()
            $tcpobject.EndConnect($connect) | out-Null 
            If ($Error[0]) 
                {
                    LogEvent 0 "an error occurred while trying to connect to 85.15.17.29:80. Error: $error[0].Exception.Message"
                    "an error occurred while trying to connect to 85.15.17.29:80. Error: $error[0].Exception.Message"
                } 
            Else 
                {
                   $test=$true
                   "worked fine!"
                }
    }
    return $test
}

#-----------Script Core -----------------
Test-HTTPport