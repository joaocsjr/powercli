##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
connect-viserver -Server ain3dv7050 -WarningAction SilentlyContinue 
connect-viserver -Server ain3vi7050 -WarningAction SilentlyContinue 


##############################
#SCRIPT MOVE TO NUTANIX ######
##############################
$cluster = 'SEGURANCA'

#desliga  as vms 
$vmlist = Import-CSV "c:\temp\Scripts\move.csv"
 foreach ($item in $vmlist) {
    $vmname = $item.vmname 
   Get-VM $vmname |    shutdown-vmguest -Confirm:$false 
    
    
}

$vmlist = Import-CSV "E:\scripts\vmax\vmax.csv"
 foreach ($item in $vmlist) {
      $vmname = $item.vmname 
      Get-Datastore -vm $vmname | Select-Object Name, vmname
   
   
     
}




#migra as vms
$vmlist = Import-CSV "E:\scripts\tbdeploy\tbdeploy.csv"
 foreach ($item in $vmlist) {
    $vmname = $item.vmname 
    #$ds= $item.ds
     #$networkAdapter = Get-NetworkAdapter -VM  $vmname 
    $destination = Get-Cluster $cluster | Get-VMHost -State Connected | Get-Random
    #$destinationPortGroup = Get-VDPortgroup -VDSwitch DSwitch_LACP -Name $networkAdapter.NetworkName
    $destinationDatastore =     Get-DatastoreCluster -name CL_DS_SEG_VIVO | Get-Datastore | Get-Random

    #$destinationDatastore = Get-Datastore -name DS_UNITY443_* | Get-Random
    #Move-VM -VM  $vmname -Destination $destination -NetworkAdapter $networkAdapter -PortGroup $destinationPortGroup -Datastore $destinationDatastore -DiskStorageFormat Thin    -RunAsync
   # $destinationDatastore = $ds
    Move-VM -VM  $vmname -Destination $destination  -Datastore $destinationDatastore  -DiskStorageFormat Thin -RunAsync

    }
#checa se o disco é thin
    $vmlist = Import-CSV "E:\scripts\tbdeploy\tbdeploy.csv"
    foreach ($item in $vmlist) {
       $vmname = $item.vmname 
       Get-Datastore -VM $vmname
       get-vm -name $vmname  | Get-HardDisk| Select-Object filename,StorageFormat

    }

Get-HardDisk -vm SEG2DV0112 

get-vm -name SEG2DV0112 | Get-HardDisk| fl Select-Object StorageFormat

    Get-DatastoreCluster  -name *CORP*   | get-vm | Select-Object name







 foreach ($item in $vmlist) {
    $vmname = $item.vmname 
    $networkAdapter = Get-NetworkAdapter -VM  $vmname 
    $destination = Get-Cluster $cluster | Get-VMHost -State Connected | Get-Random
    $destinationPortGroup = Get-VDPortgroup -VDSwitch DSwitch_LACP -Name $networkAdapter.NetworkName
    $destinationDatastore =  get-cluster -name  'BRSLP1HESX100' | Get-Datastore  -name *PROD* | Get-Random  
    Move-VM -VM  $vmname -Destination $destination -Datastore $destinationDatastore -DiskStorageFormat Thin -PortGroup $destinationPortGroup -RunAsync

    
}
#ligar as vms 
get-cluster -name $cluster | get-vm | where { $_.PowerState -eq "PoweredOff"} | start-vm -Confirm:$false 


    



#veerifica se a vm esta ligada
$vmlist = Import-CSV "F:\Scripts\move_nutella.csv"
 foreach ($item in $vmlist) {
      $vmname = $item.vmname 
      get-vm $vmname 
      #get-vm  $vmname| where { $_.PowerState -eq "PoweredOff"} | start-vm -confirm:$false
    
}






#veerifica se a vm esta ligada
$vmlist = Import-CSV "F:\Scripts\move_nutella.csv"
 foreach ($item in $vmlist) {
      $vmname = $item.vmname 
      #$newname = $item.newname
      get-vm  -name $vmname 
      #set-vm $vmname -name $newname  -confirm:$false
      
    
}



#list vms no datastore
Get-datastore | Where {$_.name -like '*1590*' } | Get-VM





