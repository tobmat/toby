        #Download inventory script from IIS server
        $source = "http://85.15.17.29/ServersInventoryAPI/resources/InventoryCollector.txt"
        $destination = "C:\Inventory\InventoryCollector.ps1"
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($source, $destination)
        "download complete!"