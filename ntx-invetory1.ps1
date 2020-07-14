
<#  
.SYNOPSIS  
    inventory nutanix AHV enviroment 
.DESCRIPTION  
    This script get some basics informations 
    about Nutanix AHV enviroment  
.NOTES  

.LINK  #>



#remove old HTML files  
Remove-Item -Path F:\Scripts\export\nutanix.html -Force 

#add powershell nutanix  snapin
add-PSSnapin -Name NutanixCmdletsPSSnapin 
 

#create a secure string to store the password and account // uncomment and run only in the first time 
#$username = "user@domain.com.br"
#$password = "password"
#$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
#$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $user, $secureStringPwd
#$secureStringText = $secureStringPwd | ConvertFrom-SecureString 
#Set-Content "F:\Scripts\cred.txt" $secureStringText

# connecting using the account in encrypt file 
$pwdTxt = Get-Content "F:\Scripts\cred.txt"
$securePwd = $pwdTxt | ConvertTo-SecureString 
$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd
Connect-NTNXCluster -Server nutanix.domain.com.br -UserName $username -Password $securePwd   -AcceptInvalidSSLCerts -ForcedConnection 

#crete a hmtl layout
$a = "<style>"
$a = $a + "h1, h5, th { text-align: center; }"
$a = $a + "table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }"
$a = $a + "th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }"
$a = $a + "td { font-size: 11px; padding: 5px 20px; color: #000; }"
$a = $a + "tr { background: #b8d1f3; }"
$a = $a + "tr:nth-child(even) { background: #dae5f4; }"
$a = $a + "tr:nth-child(odd) { background: #b8d1f3; }"
$a = $a + "</style>"



# collect data about Cluster 
$Report = Get-NTNXClusterInfo | select name,numNodes, version, nccVersion,clusterExternalIPAddress,timezone
# collect data about HA 
$Report = Get-NTNXHA | select failoverEnabled,numHostFailuresToTolerate,haState
$Report = Get-NTNXHost | select name,servicevmexternalip,hypervisorFullName,blockModelName,cpuModel,numCpuSockets,numCpuCores,@{Expression={(($_.memoryCapacityInBytes/1024)/1024)/1024};Label=”Mem(GB)”}
# collect data about vms 
$Report = Get-NTNXVM  | Select @{Expression={$_.vmname};Label=”VMName”},@{Expression={$_.uuid};Label=”UUID”},@{Expression={$_.powerstate};Label=”PowerState”},@{Expression={$_.hypervisorType};Label=”Hypervisor”},@{Expression={$_.hostname};Label=”Hostname”},@{Expression={$_.numVCpus};Label=”vCPUs”},@{Expression={(($_.memoryCapacityInBytes/1024)/1024)/1024};Label=”Mem(GB)”},@{Expression={$_.numNetworkAdapters};Label=”NIC”},@{Name=’ipAddresses’;Expression={[string]::join(“ - ”, ($_.ipAddresses))}},@{Name=’nutanixVirtualDisks’;Expression={[string]::join(“ - ”, ($_.nutanixVirtualDisks))}} 

#$Report = Get-NTNXVM  | Select vmname,uuid,powerstate,hypervisorType,hostname,numVCpus,@{Expression={(($_.memoryCapacityInBytes/1024)/1024)/1024};Label=”Mem(GB)”},@{Expression={$_.numNetworkAdapters};Label=”NIC”},@{Name=’ipAddresses’;Expression={[string]::join(“ - ”, ($_.ipAddresses))}},@{Name=’nutanixVirtualDisks’;Expression={[string]::join(“ - ”, ($_.nutanixVirtualDisks))}} 
#set HTML file path
$HTMLReport = "F:\Scripts\export\nutanix.html"
# set HTML Title
$ReportTitle = "Host Configuration"
# Collect Data
$ResultSet = $Report | ConvertTo-Html  -Head $a -Title $ReportTitle -body "<b> <i><p> Host Configuration</p>  </i></b>"
$ResultSet = $Report | ConvertTo-Html  -Head $a -Title $ReportTitle -Body "<center><img src=`"http://p2v.com.br/wp-content/uploads/2017/04/nutanix-1.jpg`"></center></br> <h1>$ReportTitle  </h1>`n<h5> <p><b> <i> Wintel & Virtualização  </i></b> </p> <p> Gerado em:$(Get-Date) </p> </p> Versão completa em CSV disponivel em:  </h5>" 

# Write Content to Report.
Add-Content $HTMLReport $ResultSet  
#Call the results or open the file.
#Invoke-Item $HTMLReport

#export result in CSV file format
$Report  | Export-Csv -NoTypeInformation -UseCulture -Path  F:\Scripts\export\nutanix$((Get-Date).ToString('MM-dd-yyyy')).csv

#send email with html 
$recipients = "destinationemail@domain.com.br"
#$recipients = "Joao.castro@domain.com.br"
$smtpServer = "smtp.nextel.com.br" 
$MailFrom = "alertavmware@nextel.com.br" 
#$mailto = "suportevirtualizacao@domain.com.br" 
#$mailto = "Joao.castro@domain.com.br"
$mailto = $recipients
$msg = new-object Net.Mail.MailMessage  
$smtp = new-object Net.Mail.SmtpClient($smtpServer)  
$msg.From = $MailFrom 
$msg.IsBodyHTML = $true 
$msg.To.Add($Mailto)  
$msg.Subject = "Nutanix VMs inventory" 
$MailTextT =  Get-Content  -Path F:\Scripts\export\nutanix.html
$msg.Body = $MailTextT
$smtp.Send($msg) 
