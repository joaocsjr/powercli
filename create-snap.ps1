##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
connect-viserver -Server brslp1vw2pvc001.nextel.com.br -WarningAction SilentlyContinue 
##############################
#SCRIPT MOVE TO NUTANIX ######
##############################
$cluster = 'BRSLP1HESX000'

#desliga  as vms 
$vmlist = Import-CSV "F:\Scripts\create-snap.csv"
 foreach ($item in $vmlist) {
    $vmname = $item.vmname 
   #get-vm $vmname | new-snapshot -name "j2c" -Description "Projeto j2c" 
       get-vm $vmname | Get-Snapshot 
}
 get-vm BRSLP1VUDAP185|  new-snapshot -name "j2c" -Description "Projeto j2c" 

 New-Snapshot -VM(Get-VM -Name "BRSLP1VUDAP185") -Name BeforePatch1