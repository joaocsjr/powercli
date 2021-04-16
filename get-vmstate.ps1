##Import de modulo e conexão no vCenter
import-module VMware.Vimautomation.core
connect-viserver -Server ain3ct7050  -WarningAction SilentlyContinue 
connect-viserver -Server ain3dv7050  -WarningAction SilentlyContinue 

$vmlist = Import-CSV "E:\Scripts\state.csv"
  foreach ($item in $vmlist) {
     $vmname = $item.vmname
     get-vm $vmname
  }



$vmlist = Import-CSV "F:\Scripts\portgroup.csv"
  foreach ($item in $vmlist) {
     $basevm = $item.basevm
    $vm = Get-Cluster -name BRSLP1PESX100_DMZ | get-vm -name $basevm 
    $vm | Get-VirtualPortGroup | fl

  }


  


