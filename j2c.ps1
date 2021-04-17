#rename vm

$vmlist = Import-CSV "F:\Scripts\j2c.csv"
 foreach ($item in $vmlist) {
      $vmname = $item.vmname 
     # get-vm $vmname | get-vmhost
      get-vm  $vmname| where { $_.PowerState -eq "PoweredOn"} | stop-vm -Confirm:$false 
    
}



#veerifica se a vm esta ligada
$vmlist = Import-CSV "F:\Scripts\j2c.csv"
 foreach ($item in $vmlist) {
      $vmname = $item.vmname 
      $newname = $item.newname
      #get-vm  -name $vmname | get-vmhost
      set-vm $vmname -name $newname  -confirm:$false
      
    
}






