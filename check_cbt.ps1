# Check and Add the PowerCli Snaping if not already present
#if(-not(Get-PSSnapin -Registered -Name "VMware.VimAutomation.Core"){
#    Add-PSSnapin -Name VMware.VimAutomation.Core}

# Connect to my Vcenter
#Connect-VIServer -Server vcenter.fx.lab

#Here is aRunning the script on TESTSERVER04 to enable CBT
#$vmtest = Get-vm TESTSERVER04 | get-view
#$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
#$vmConfigSpec.changeTrackingEnabled = $true
#$vmtest.reconfigVM($vmConfigSpec)









##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
#add-pssnapin VMware.Vimautomation.core
connect-viserver -Server brslp1vw2pvc001.nextel.com.br -WarningAction SilentlyContinue 


Remove-Item -Path F:\Scripts\Export\cbt.html -Force 

#$Report = get-datacenter -name  Belem | Get-VM| Where-Object{ $_.Name -notlike '*CTX*' -AND $_.Name -notlike '*DAP*'}

$Report = get-datacenter -name  Belem | Get-VM|Where-Object{ $_.Name -notlike '*CTX*' -and $_.Name -notlike '*replica*' -and $_.VMhost -notlike '*tesx*' -and $_.VMhost -notlike '*GOLDEN*'}| Where-Object{$_.ExtensionData.Config.ChangeTrackingEnabled -eq $false} | select name,PowerState,Notes,VMHost


$a = "<style>"
$a = $a + "h1, h5, th { text-align: center; }"
$a = $a + "table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }"
$a = $a + "th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }"
$a = $a + "td { font-size: 11px; padding: 5px 20px; color: #000; }"
$a = $a + "tr { background: #b8d1f3; }"
$a = $a + "tr:nth-child(even) { background: #dae5f4; }"
$a = $a + "tr:nth-child(odd) { background: #b8d1f3; }"
$a = $a + "</style>"


$HTMLReport = "F:\Scripts\export\cbt.html"
    $ReportTitle = "VMs com CBT Desabilitado"
# Collect Data
    $ResultSet = $Report | ConvertTo-Html  -Head $a -Title $ReportTitle -Body "<h1>$ReportTitle</h1>`n<h5> <p><b> <i> Wintel & Virtualização </i></b></p> <p> Gerado em:$(Get-Date) </p> </p> Versão completa em CSV disponivel em: \\brslp1vw2pap046\f$\Scripts\export\ </h5>" 
# Write Content to Report.

    Add-Content $HTMLReport $ResultSet  
# Call the results or open the file.
   Invoke-Item $HTMLReport

  $Report | Export-Csv -NoTypeInformation -UseCulture -Path  F:\Scripts\export\cbt$((Get-Date).ToString('MM-dd-yyyy')).csv


  
  
$recipients = "suportevirtualizacao@br.g.nii.com,suportebackup@nextel.com.b"
#$recipients = "Joao.castro@br.g.nii.com,anderson.souza2@br.g.nii.com"
$smtpServer = "smtp.nextel.com.br" 
$MailFrom = "alertavmware@nextel.com.br" 
#$mailto = "suportevirtualizacao@br.g.nii.com" 
#$mailto = "Joao.castro@br.g.nii.com"
$mailto = $recipients
$msg = new-object Net.Mail.MailMessage  
$smtp = new-object Net.Mail.SmtpClient($smtpServer)  
$msg.From = $MailFrom 
$msg.IsBodyHTML = $true 
$msg.To.Add($Mailto)  
$msg.Subject = "CBT Status." 
$MailTextT =  Get-Content  -Path F:\Scripts\Export\cbt.html
$msg.Body = $MailTextT 
$smtp.Send($msg) 







