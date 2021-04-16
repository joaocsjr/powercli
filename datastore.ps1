##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
connect-viserver -Server vcenter.nextel.com.br -WarningAction SilentlyContinue 
##############################
#SCRIPT MOVE TO NUTANIX ######
##############################
$cluster = 'BRSLP1HESX000'



Get-vm |?{($_.extensiondata.config.datastoreurl|%{$_.name}) -contains "1590"}

$vms = Get-datastore | Where {$_.name -like '*1590*' } | Get-VM |    select name, powerstate > c:\temp\maquinas.txt


 Get-datastore | Where {$_.name -like '*1590*' -and $_.state -like '*Maint*'  }



#migra as vms
$vmlist = Import-CSV "F:\Scripts\move_nutellaoff.csv"
 foreach ($item in $vmlist) {
    $vmname = $item.vmname 
    $networkAdapter = Get-NetworkAdapter -VM  $vmname 
    $destination = Get-Cluster $cluster | Get-VMHost -State Connected | Get-Random
    $destinationPortGroup = Get-VDPortgroup -VDSwitch dvSwitch_DEV_NTX -Name $networkAdapter.NetworkName
    $destinationDatastore =  get-cluster -name  'BRSLP1HESX000' | Get-Datastore  -name *DEV* | Get-Random  
    Move-VM -VM  $vmname -Destination $destination -Datastore $destinationDatastore -DiskStorageFormat Thin -PortGroup $destinationPortGroup -RunAsync

    
}



get-vm BRSLP1VW3DDB001 |Get-HardDisk | Select Parent,Name,DiskType,ScsiCanonicalName,DeviceName | fl