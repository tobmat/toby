<#
.Synopsis
   Connect to Cisco VPN.
.DESCRIPTION
   Long description
.EXAMPLE
   Connect-Cisco -Connect vpn
#>
function Connect-Cisco
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Connect help description
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Connect
    )

 if (! $Connect) {
   "You will connect to inin...if you need to connect to admin hub use the -connect flag:"
   "connect-cisco -connect admin"
 }
 & 'C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe' 'disconnect'
 if ($Connect -eq "admin") {
    $connection_string='vpn.admin.hosted-inin.com'
    & 'C:\Program Files (x86)\RSA SecurID Software Token\SecurID.exe'
    & 'C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe' 'connect' vpn.admin.hosted-inin.com
 } else {
    & 'C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe'
 }

}