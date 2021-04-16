##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
connect-viserver -Server brslp1vw2pvc001.nextel.com.br -WarningAction SilentlyContinue 
Remove-Item -Path F:\Scripts\Export\thick.txt -Force 



$a = "<style>"
$a = $a + "h1, h5, th { text-align: center; }"
$a = $a + "table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }"
$a = $a + "th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }"
$a = $a + "td { font-size: 11px; padding: 5px 20px; color: #000; }"
$a = $a + "tr { background: #b8d1f3; }"
$a = $a + "tr:nth-child(even) { background: #dae5f4; }"
$a = $a + "tr:nth-child(odd) { background: #b8d1f3; }"
$a = $a + "</style>"


$Report = Get-Datacenter -name Belem | Get-Datastore  | Get-VM  | Get-HardDisk | Where {$_.storageformat -eq "Thick" } | Select Parent, Name, CapacityGB, storageformat, Filename,DiskType | Select-Object   Parent, Name, CapacityGB, storageformat, Filename,DiskType | ft
$Report >> F:\Scripts\Export\thick.txt






$HTMLReport = "F:\Scripts\export\Snapshot.html"
    $ReportTitle = "Snapshot Report"
# Collect Data
    $ResultSet = $Report | ConvertTo-Html  -Head $a -Title $ReportTitle -Body "<h1>$ReportTitle</h1>`n<h5> <p><b> <i> Wintel & Virtualização </i></b></p> <p> Gerado em:$(Get-Date) </p> </p> Versão completa em CSV disponivel em: \\brslp1vw2pap046\f$\Scripts\export\ </h5>" 
# Write Content to Report.

    Add-Content $HTMLReport $ResultSet  
# Call the results or open the file.

Invoke-Item $HTMLReport

 $html = Get-item -Path F:\Scripts\Export\thick.txt






disconnect-viserver * -confirm:$false
