Import-Module VMware.Vimautomation.core
Import-Module E:\temp\DRSRule-master\DRSRule-master\DRSRule
connect-viserver -Server server  -user 'administrator@vsphere.local' -Password 'VMwar3!!'-WarningAction SilentlyContinue -AllLinked
#Connect-VIServer -Server $vCenter -user $vCenterUser -password $vCenterUserPasswd
#$password = Get-Content E:\scripts\cred.txt | ConvertTo-SecureString 
#$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password
#$vCenter = 'server.server.com'
#$vCenteruser ='administrator@vsphere.local'
#$vCenterUserPasswd='not secret'
#
#--------------------------------------------
# DEFINICAO DOS CLUSTERS QUE SERÃO MONITORADOS
#--------------------------------------------
$cluster1='ARS'
$cluster2='CORPORATIVO'
$cluster3='SEGURANCA'
#
#--------------------------------------------
# DEFINICAO DO GRUPO DRS
#--------------------------------------------
$ClusterRule='RHEL-VM'

#--------------------------------------------
# FILTRANDO AS VMS LINUX
#--------------------------------------------
$VMcluster1=get-cluster $cluster1 |get-vm | Where-Object {$_.Guest.OSFullName -like '*Red Hat Enterprise*'} 
$VMcluster2=Get-Cluster $cluster2 |get-vm | Where-Object {$_.Guest.OSFullName -like '*Red Hat Enterprise*'} 
$VMcluster3=Get-Cluster $cluster3 |get-vm | Where-Object {$_.Guest.OSFullName -like '*Red Hat Enterprise*'} 

#------------------------------------------
# ADD VMS NOS GRUPOS DE DRS
#------------------------------------------
#
Set-DrsVMGroup -Name $ClusterRule -AddVM $VMcluster1 -Cluster $cluster1
Set-DrsVMGroup -Name $ClusterRule -AddVM $VMcluster2 -Cluster $cluster2
Set-DrsVMGroup -Name $ClusterRule -AddVM $VMcluster2 -Cluster $cluster3
#
#
#------------------------------------------
# MONTANDO EMAIL PARA ENVIO
#------------------------------------------
$VMbody1=$VMcluster1 | Select-Object -ExpandProperty name | out-string
$VMbody2=$VMcluster2 | Select-Object -ExpandProperty name | out-string
$VMbody3=$VMcluster3 | Select-Object -ExpandProperty name | out-string
$vmcount1 =$VMcluster1.Count
$vmcount2 =$VMcluster2.Count
$vmcount3 =$VMcluster3.Count


$sendFrom = 'joao.souza@server.com.br'
$sendTo = 'joao.souza@server.com.br'
$smtp = 'smtp.server.com'

$s1 = "`n$vcenter`n As seguintes Virtual Machine fazem parte do DRS Group:`n$ClusterRule`n No Cluster:`n$Cluster1`nContem as seguintes virtual machines:`n"
$s1 += "$VMbody1`n"
$s1 =  "n$vmcount1`n QTd de VMs no grupo `n$ClusterRule`n"



$s1 += " `n$vcenter`n The following DRS Rule:`n$ClusterRule`nRunning in the vSphere Cluster: `n$Cluster2`nContains the following virtual machines:`n"
$s1+= "$VMbody2"
$s1 =  "n$vmcount2`n QTd de VMs no grupo `n$ClusterRule`n"

$s1 += " `n$vcenter`n The following DRS Rule:`n$ClusterRule`nRunning in the vSphere Cluster: `n$Cluster3`nContains the following virtual machines:`n"
$s1+= "$VMbody3"
$s1 =  "n$vmcount3`n QTd de VMs no grupo `n$ClusterRule`n"
#------------------------------------------
# ENVIO DE EMAIL
#------------------------------------------
send-mailmessage -to $sendTo -from $sendFrom -Subject "$vCenter DRS rule report" -smtpserver $smtp -body $s1

Disconnect-VIServer *  -Confirm:$False
