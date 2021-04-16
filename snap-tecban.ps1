##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
Remove-Item -Path e:\Scripts\Export\Snapshot.html -Force 
#Write-Host "Enter vCenter Credentials" 
$username = "administrator@vsphere.local" 
#Read-Host "Enter Password" -AsSecureString | ConvertFrom-SecureString | Out-File E:\scripts\cred.txt
$password = Get-Content E:\scripts\cred.txt | ConvertTo-SecureString 
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password

#get-vm -name ain3ct5353.tecban.com | Get-Snapshot | select   @{Label="uid";E={( $_.uid | %{$_.split(':')[0]} | %{$_.split('@')}|%{$_.split('/')} |%{$_.split('\')[0]} |%{$_.split('=')[0]} )}}


Connect-VIServer -Server ain3ct7050 -Protocol https -AllLinked -Credential $cred


$a = "<style>"
$a = $a + "h1, h5, th { text-align: center; }"
$a = $a + "table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }"
$a = $a + "th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }"
$a = $a + "td { font-size: 11px; padding: 5px 20px; color: #000; }"
$a = $a + "tr { background: #b8d1f3; }"
$a = $a + "tr:nth-child(even) { background: #dae5f4; }"
$a = $a + "tr:nth-child(odd) { background: #b8d1f3; }"
$a = $a + "</style>"


$Report = Get-VM | Where-Object {$_.Name -notlike '*replica*' -and $_.Name -notlike '*VDI*' } | Get-Snapshot   | Select @{Label="DaysOld";E={((Get-Date) - $_.Created).Days; }},VM,Name,Description,@{Label="Size";Expression={"{0:N2} GB" -f ($_.SizeGB)}},created,@{Label="VCenter";E={( $_.uid | %{$_.split(':')[0]} | %{$_.split('@')}|%{$_.split('/')} |%{$_.split('\')[0]} |%{$_.split('=')[0]} )}} |  Sort-Object -Property "DaysOld"
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







$HTMLReport = "e:\Scripts\export\Snapshot.html"
    $ReportTitle = "Snapshot Report"
# Collect Data
    $ResultSet = $Report | ConvertTo-Html  -Head $a -Title $ReportTitle -Body "<h1>$ReportTitle </h1>`n<h5> <p><b> <i> Snapshots do ambiente novo VMWare </i></b></p> <p><b> <i> Projetos de Infraestrutura </i></b></p> <p> Gerado em:$(Get-Date) </p> </p> Versão completa em CSV disponivel </h5>" 
# Write Content to Report.

    Add-Content $HTMLReport $ResultSet  
# Call the results or open the file.
   Invoke-Item $HTMLReport

#$ResultSet = $Report | Select VM,Name,Description,Size,Created | ConvertTo-Html -Head $Header -PreContent "<p><h2>Snapshot Report - $VIServer</h2></p><br>" 






 $Report | Export-Csv -NoTypeInformation -UseCulture -Path  e:\Scripts\export\Snapshot$((Get-Date).ToString('MM-dd-yyyy')).csv

 $recipients = "joao.souza@tecban.com"
 #$recipients = "Joao.castro@br.g.nii.com,anderson.souza2@br.g.nii.com"
 $smtpServer = "ain2pr0202.tecban.com" 
 $MailFrom = "alertavmware@tecban.com" 
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
 



get-datacenter -name VIVO | Get-VMHost |Get-Datastore |fl
  
   

disconnect-viserver * -confirm:$false




get-vm -name AIN2PR5915 | Get-VMHostNetwork

Get-VirtualPortGroup -vm AIN2PR5915 | Format-List