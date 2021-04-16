##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
#connect-viserver -Server ain3dv7050 -WarningAction SilentlyContinue 

#
#get-cluster -name "CORPORATIVO"

#check ssh service	
#Get-VMHost | Get-VMHostService | Where { $_.Key -eq "TSM-SSH" } |select VMHost, Label, Running

#enable ssh service
#Get-VMHost | Foreach {Start-VMHostService -HostService ($_ | Get-VMHostService | Where { $_.Key -eq "TSM-SSH"} )}


#create a local user
$vmlist = Import-CSV "C:\Users\tbn01925\Desktop\host.csv"
foreach ($item in $vmlist) {
$vmhost = $item.vmhost 
connect-viserver  -Server $vmhost -user "root" -Password "VMwar3!!" -WarningAction SilentlyContinue 
Get-VMHost -name $vmhost | Foreach {Start-VMHostService -HostService ($_ | Get-VMHostService | Where { $_.Key -eq "TSM-SSH"} )}
New-VMHostAccount -server $vmhost -id  admseg  -Password "Tecban@2020" -Description "usuario senha segura"
New-VMHostAccount -server $vmhost -id  _apl_mt4 -Password "Tecban@2020" -Description "usuario senha segura"
New-VIPermission  -Entity $vmhost -Principal admseg -Role Admin -Propagate:$true
New-VIPermission  -Entity $vmhost -Principal _apl_mt4 -Role Admin -Propagate:$true
}
