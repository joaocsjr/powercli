##Import de modulo e conexão no vCenter
add-pssnapin VMware.Vimautomation.core
connect-viserver -Server server.server.com.br -WarningAction SilentlyContinue 
Remove-Item -Path F:\Scripts\Export\alarms.html -Force 

#$Report = Get-VIEvent -Start (Get-Date).AddDays(-1) -MaxSamples ([int]::MaxValue)

$Report = Get-VIEvent -Start (Get-Date).AddDays(-1) -MaxSamples ([int]::MaxValue)  |
Where {$_ -is [VMware.Vim.AlarmStatusChangedEvent] -and ($_.To -eq "Yellow" -or $_.To -eq "Red") -and $_.To -ne "Gray"} |
Select CreatedTime,FullFormattedMessage,@{N="Entity";E={$_.Entity.Name}},@{N="Host";E={$_.Host.Name}},@{N="Vm";E={$_.Vm.Name}},@{N="Datacenter";E={$_.Datacenter.Name}} | Sort-Object -Property "Datacenter"


$a = "<style>"
$a = $a + "h1, h5, th { text-align: center; }"
$a = $a + "table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }"
$a = $a + "th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }"
$a = $a + "td { font-size: 11px; padding: 5px 20px; color: #000; }"
$a = $a + "tr { background: #b8d1f3; }"
$a = $a + "tr:nth-child(even) { background: #dae5f4; }"
$a = $a + "tr:nth-child(odd) { background: #b8d1f3; }"
$a = $a + "</style>"

$HTMLReport = "F:\Scripts\export\alarms.html"
    $ReportTitle = "Alarmes Report"
# Collect Data
    $ResultSet = $Report | ConvertTo-Html  -Head $a -Title $ReportTitle -Body "<h1>$ReportTitle</h1>`n<h5> <p><b> <i> Wintel & Virtualização </i></b></p> <p> Gerado em:$(Get-Date) </p> </p> Versão completa em CSV disponivel em: \\brslp1vw2pap046\f$\Scripts\export\ </h5>" 
# Write Content to Report.

    Add-Content $HTMLReport $ResultSet  
# Call the results or open the file.
   Invoke-Item $HTMLReport

#$ResultSet = $Report | Select VM,Name,Description,Size,Created | ConvertTo-Html -Head $Header -PreContent "<p><h2>Snapshot Report - $VIServer</h2></p><br>" 


 $Report | Export-Csv -NoTypeInformation -UseCulture -Path  F:\Scripts\export\alarms$((Get-Date).ToString('MM-dd-yyyy')).csv

$recipients = "Joao.castro@br.g.nii.com,anderson.souza2@br.g.nii.com"
$smtpServer = "smtp.server.com.br" 
$MailFrom = "alertavmware@server.com.br" 
#$mailto = "suportevirtualizacao@br.g.nii.com" 
#$mailto = "Joao.castro@br.g.nii.com"
$mailto = $recipients
$msg = new-object Net.Mail.MailMessage  
$smtp = new-object Net.Mail.SmtpClient($smtpServer)  
$msg.From = $MailFrom 
$msg.IsBodyHTML = $true 
$msg.To.Add($Mailto)  
$msg.Subject = "Snapshot Status." 
$MailTextT =  Get-Content  -Path F:\Scripts\Export\alarms.html
$msg.Body = $MailTextT 
$smtp.Send($msg) 



