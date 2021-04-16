



$vmlist = Import-CSV 

### Realiza o clone das vms 
$vmlist = Import-CSV "F:\Scripts\export\iso.csv"
 
foreach ($item in $vmlist) {
 
  $name = $item.Name
  
   
   Get-VM $name | Where-Object {$_.PowerState –eq “PoweredOn”} | Get-CDDrive | Set-CDDrive -NoMedia -Confirm:$False


}
