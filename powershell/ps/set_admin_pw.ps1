
 # Set Administrator Password #
 $strPassword = "Interactive2014"
 $strComputer = "."
 $objUser = [ADSI]("WinNT://$strComputer/Administrator, user")
 $objUser.psbase.invoke("SetPassword",$strPassword)