##Import de modulo e conex�o no vCenter
Import-Module VMware.Vimautomation.core
connect-viserver -Server server -user "administrator@vsphere.local" -password "VMwar3!!" -WarningAction SilentlyContinue  -AllLinked
connect-viserver -Server server -user "administrator@vsphere.local" -password "VMwar3!!" -WarningAction SilentlyContinue 
Remove-Item -Path e:\Scripts\Export\Snapshot.html -Force 

$vcenter = "server"

$a = "<style>"
$a = $a + "h1, h5, th { text-align: center; }"
$a = $a + "table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }"
$a = $a + "th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }"
$a = $a + "td { font-size: 11px; padding: 5px 20px; color: #000; }"
$a = $a + "tr { background: #b8d1f3; }"
$a = $a + "tr:nth-child(even) { background: #dae5f4; }"
$a = $a + "tr:nth-child(odd) { background: #b8d1f3; }"
$a = $a + "</style>"


$Report = Get-VM | Where-Object {$_.Name -notlike '*replica*' -and $_.Name -notlike '*VDI*' } | Get-Snapshot   | Select VM,Name,Description,@{Label="Size";Expression={"{0:N2} GB" -f ($_.SizeGB)}},@{Label="DaysOld";E={((Get-Date) - $_.Created).Days; }} |  Sort-Object -Property "DaysOld"
If (-not $Report)
{  $Report = New-Object PSObject -Property @{
      VM = "No snapshots found on any VM's controlled by $VIServer"
      Name = ""
      Description = ""
      Size = ""
      Created = ""
      DaysOld = ""
   }

   
}
  #@{N="Percent Free"; E={ $pf= [Math]::Round(($_.Summary.FreeSpace/$_.Summary.Capacity)*100); if( $pf -lt 10) { "#color"+$pf+"color#" }  else { $pf }    }},







$HTMLReport = "E:\Scripts\export\Snapshot.html"
    $ReportTitle = "Snapshot Report"
# Collect Data
    $ResultSet = $Report | ConvertTo-Html  -Head $a -Title $ReportTitle -Body "<h1>$ReportTitle</h1>`n<h5> <p><b> <i> Snaps > $vcenter </i></b></p> <p><b> <i> Wintel & Virtualiza��o </i></b></p> <p> Gerado em:$(Get-Date) </p> </p> Vers�o completa em CSV disponivel em: \\brslp1vw2pap046\f$\Scripts\export\ </h5>" 
# Write Content to Report.

    Add-Content $HTMLReport $ResultSet  
# Call the results or open the file.
   #Invoke-Item $HTMLReport

#$ResultSet = $Report | Select VM,Name,Description,Size,Created | ConvertTo-Html -Head $Header -PreContent "<p><h2>Snapshot Report - $VIServer</h2></p><br>" 


 $Report | Export-Csv -NoTypeInformation -UseCulture -Path  F:\Scripts\export\Snapshot$((Get-Date).ToString('MM-dd-yyyy')).csv

$recipients = "joao.souza@server.com"
#$recipients = "Joao.castro@br.g.nii.com,anderson.souza2@br.g.nii.com"
$smtpServer = "ain2pr0202.server.com" 
$MailFrom = "alertavmware@server.com" 
#$mailto = "suportevirtualizacao@br.g.nii.com" 
#$mailto = "Joao.castro@br.g.nii.com"
$mailto = $recipients
$msg = new-object Net.Mail.MailMessage  
$smtp = new-object Net.Mail.SmtpClient($smtpServer)  
$msg.From = $MailFrom 
$msg.IsBodyHTML = $true 
$msg.To.Add($Mailto)  
$msg.Subject = "Snapshot Status." 
$MailTextT =  Get-Content  -Path e:\Scripts\Export\Snapshot.html
$msg.Body = $MailTextT 
$smtp.Send($msg) 





  
   
get-datacenter  -Name Belem |   get-vm  | Get-Snapshot |   Where-Object {$_.Name -notlike '*replica*' -and $_.Name -notlike '*snapshot*' -and $_.Name -notlike '*VDI*' -and $_.Name -notlike '*Windows*' -and $_.Name -notlike '*W7*'-and $_.Name -notlike '*CTX*'-and $_.Created -lt (Get-Date).AddDays(-3) } |   Remove-Snapshot -confirm:$false 

disconnect-viserver * -confirm:$false



### Realiza o clone das vms 
$vmlist = Import-CSV "C:\temp\scripts\snap.csv"
 
foreach ($item in $vmlist) {
 
     $vmname = $item.vmname
     Get-Snapshot -vm $vmname | Remove-Snapshot -Confirm:$false

}


