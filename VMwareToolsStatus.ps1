##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
#add-pssnapin VMware.Vimautomation.core
connect-viserver -Server server.server.com.br -WarningAction SilentlyContinue 



Remove-Item -Path F:\Scripts\Export\VMtools.html -Force 


#Remove-Item -Path F:\Scripts\Export\VMToolsStatus.csv -Force 


function Get-VMToolsStatus
    {
        [CmdletBinding()] 
        Param (
            [ValidateSet('NeedUpgrade','NotInstalled','Unsupported')][string]$Filter
            )

    $VMs = Get-View  -ViewType VirtualMachine -Property name,guest,config.version,runtime.PowerState,Guest.GuestFullName,Config.Annotation
    $report = @()
    $progress = 1
    foreach ($VM in $VMs) {
        Write-Progress -Activity "Checking vmware tools status" -Status "Working on $($VM.Name)" -PercentComplete ($progress/$VMs.count*100) -ErrorAction SilentlyContinue
        $object = New-Object PSObject
        Add-Member -InputObject $object NoteProperty VM $VM.Name
         Add-Member -InputObject $object NoteProperty "SO" $VM.Guest.GuestId

        if ($VM.runtime.powerstate -eq "PoweredOff") {Add-Member -InputObject $object NoteProperty ToolsStatus "$($VM.guest.ToolsStatus) (PoweredOff)"}
        else {Add-Member -InputObject $object NoteProperty ToolsStatus $VM.guest.ToolsStatus}
        Add-Member -InputObject $object NoteProperty ToolsVersionStatus ($VM.Guest.ToolsVersionStatus).Substring(10)
        Add-Member -InputObject $object NoteProperty SupportState ($VM.Guest.ToolsVersionStatus2).Substring(10)
        if ($object.ToolsStatus -eq "NotInstalled") {Add-Member -InputObject $object NoteProperty Version ""}
        else {Add-Member -InputObject $object NoteProperty Version $VM.Guest.ToolsVersion}
        Add-Member -InputObject $object NoteProperty "HW Version" $VM.config.version
     
        #Add-Member -InputObject $object NoteProperty "Notes" $VM.VMHost.Name
        Add-Member -InputObject $object NoteProperty "Notes" $VM.Config.Annotation

        $report += $object
        $progress++
        }
    Write-Progress -Activity "Checking vmware tools" -Status "All done" -Completed -ErrorAction SilentlyContinue
 
    if ($Filter -eq 'NeedUpgrade') {
        $report | Sort-Object vm | Where-Object {$_.ToolsVersionStatus -eq "NeedUpgrade"}
        }
    elseif ($Filter -eq 'NotInstalled') {
        $report | Sort-Object vm | Where-Object {$_.ToolsVersionStatus -eq "NotInstalled"}
        }
    elseif ($Filter -eq 'Unsupported') {
        $report | Sort-Object vm | Where-Object {($_.SupportState -eq "Blacklisted") -or ($_.SupportState -eq "TooNew") -or ($_.SupportState -eq "TooOld") -or ($_.SupportState -eq "Unmanaged")}
        }
    else {$report | Sort-Object vm}
 
<#
  Filters the list based on if the VMware tools "NeedUpgrade", is "NotInstalled" or if they are "Unsupported"
 .Example
  Get-VMToolsStatus
  List vm tools status for all VMs
 .Example
  Get-VMToolsStatus -Filter NeedUpgrade

 #>
}

$a = "<style>"
$a = $a + "h1, h5, th { text-align: center; }"
$a = $a + "table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }"
$a = $a + "th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }"
$a = $a + "td { font-size: 11px; padding: 5px 20px; color: #000; }"
$a = $a + "tr { background: #b8d1f3; }"
$a = $a + "tr:nth-child(even) { background: #dae5f4; }"
$a = $a + "tr:nth-child(odd) { background: #b8d1f3; }"
$a = $a + "</style>"


$HTMLReport = "F:\Scripts\export\VMtools.html"
    $ReportTitle = "VMware Tools Report"
# Collect Data
    $ResultSet = Get-VMToolsStatus -Filter NotInstalled | ConvertTo-Html  -Head $a -Title $ReportTitle -Body "<h1>$ReportTitle</h1>`n<h5> <p><b> <i> Wintel & Virtualização </i></b></p> <p> Gerado em:$(Get-Date) </p> Versão completa em CSV disponivel em: \\brslp1vw2pap046\f$\Scripts\export </h5>" 
# Write Content to Report.
    Add-Content $HTMLReport $ResultSet
# Call the results or open the file.
   # Invoke-Item $HTMLReport

    
Get-VMToolsStatus | Export-Csv -NoTypeInformation -UseCulture -Path  F:\Scripts\export\VMToolsStatus$((Get-Date).ToString('MM-dd-yyyy')).csv


$recipients = "Joao.castro@br.g.nii.com"
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
$msg.Subject = "VMware Tools Status." 
$MailTextT =  Get-Content  -Path F:\Scripts\Export\VMtools.html
$msg.Body = $MailTextT 
$smtp.Send($msg) 









