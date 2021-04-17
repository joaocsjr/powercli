#########################################################################################
# The script lists information about CD-ROM, Floppy, Parallel Ports and Seriel Ports   	#
#  										      									       	#
# 	 	     	                     		#
#########################################################################################
#Add-PSSnapin VMware.VimAutomation.Core
##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
#Remove-Item -Path e:\Scripts\Export\Snapshot.html -Force 
#Write-Host "Enter vCenter Credentials" 
$username = "administrator@vsphere.local" 
#Read-Host "Enter Password" -AsSecureString | ConvertFrom-SecureString | Out-File E:\scripts\cred.txt
$password = Get-Content E:\scripts\cred.txt | ConvertTo-SecureString 
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password

#get-vm -name ain3ct5353.server.com | Get-Snapshot | select   @{Label="uid";E={( $_.uid | %{$_.split(':')[0]} | %{$_.split('@')}|%{$_.split('/')} |%{$_.split('\')[0]} |%{$_.split('=')[0]} )}}


Connect-VIServer -Server server -Protocol https -AllLinked -Credential $cred
$Report = get-vm | Where-Object { $_ | get-cddrive | Where-Object { $_.ConnectionState.Connected -eq "true" -and $_.ISOPath -like "*.ISO*"} } | select Name, @{Name=".ISO Path";Expression={(Get-CDDrive $_).isopath }}


$a = "<style>"
$a = $a + "h1, h5, th { text-align: center; }"
$a = $a + "table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }"
$a = $a + "th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }"
$a = $a + "td { font-size: 11px; padding: 5px 20px; color: #000; }"
$a = $a + "tr { background: #b8d1f3; }"
$a = $a + "tr:nth-child(even) { background: #dae5f4; }"
$a = $a + "tr:nth-child(odd) { background: #b8d1f3; }"
$a = $a + "</style>"

$HTMLReport = "e:\Scripts\export\iso.html"
    $ReportTitle = "VMs com ISO Montadas Report"
# Collect Data
    $ResultSet = $Report | ConvertTo-Html  -Head $a -Title $ReportTitle -Body "<h1>$ReportTitle</h1>`n<h5> <p><b> <i>  </i></b></p> <p> Gerado em:$(Get-Date) </p> </p> </h5>" 
# Write Content to Report.

    Add-Content $HTMLReport $ResultSet  
# Call the results or open the file.
   Invoke-Item $HTMLReport

  $Report | Export-Csv -NoTypeInformation -UseCulture -Path  F:\Scripts\export\isos$((Get-Date).ToString('MM-dd-yyyy')).csv





  
$recipients = "suportevirtualizacao@domain.com"
#$recipients = "Joao.castro@domain.com,anderson.souza2@domain.com"
$smtpServer = "smtp.server.com.br" 
$MailFrom = "alertavmware@server.com.br" 
#$mailto = "suportevirtualizacao@domain.com" 
#$mailto = "Joao.castro@domain.com"
$mailto = $recipients
$msg = new-object Net.Mail.MailMessage  
$smtp = new-object Net.Mail.SmtpClient($smtpServer)  
$msg.From = $MailFrom 
$msg.IsBodyHTML = $true 
$msg.To.Add($Mailto)  
$msg.Subject = "ISOs Montadas Status." 
$MailTextT =  Get-Content  -Path F:\Scripts\Export\iso.html
$msg.Body = $MailTextT 
$smtp.Send($msg) 