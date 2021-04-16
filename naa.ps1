


##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
connect-viserver -Server server -WarningAction SilentlyContinue 
connect-viserver -Server server -WarningAction SilentlyContinue 
##############################
#SCRIPT MOVE TO UNITY ######
##############################
$vmlist = Import-CSV "c:\temp\Scripts\unity.csv"
 foreach ($item in $vmlist) {
    $vmname = $item.vmname 
    $ds = $item.ds
    get-datastore -name $ds |Where-Object { $_.extensiondata.info.vmfs.extent.diskname -like “*$diskname*”} | ft


}



