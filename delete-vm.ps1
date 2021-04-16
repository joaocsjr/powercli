##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
connect-viserver -Server brslp1vw2pvc001.nextel.com.br -WarningAction SilentlyContinue 
##############################
#SCRIPT MOVE TO NUTANIX ######


#desliga  as vms 
$vmlist = Import-CSV "F:\Scripts\delete-vm.csv"
 foreach ($item in $vmlist) {
    $vmname = $item.vmname 
    get-vm -name $vmname  | remove-vm  $vmname -DeletePermanently –Confirm:$false 
   #  stop-vm -Confirm:$false   #| where { $_.PowerState -eq "PoweredOff"}
}



