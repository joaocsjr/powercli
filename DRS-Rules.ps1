##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
Import-Module C:\temp\DRSRule-master\DRSRule-master\DRSRule
connect-viserver -Server server -WarningAction SilentlyContinue 
##############################
#SCRIPT ADD VM TO AFFINITY RULE ######
##############################
#pega o cluster e add as vms no grupo RHEL
$Report = foreach ($clusterlist in $cluster) {
    $vmlist = get-cluster -name $clusterlist|  get-vm | where {$_.name -like “*teste*”}

foreach ($item in $vmlist) {
    Set-DrsVMGroup -Name RHEL-VM -AddVM $vmlist -Cluster $clusterlist
    $Report = get-vm -name $vmlist | select Name 
     
}
    }






