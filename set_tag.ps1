##Import de modulo e conexão no vCenter
add-pssnapin VMware.Vimautomation.core
connect-viserver -Server  -WarningAction SilentlyContinue 

$vmlist = Import-CSV "F:\Scripts\tag.csv"
 
foreach ($item in $vmlist) {
 
   $vmname = $item.vmname
   $tag1 = $item.tag1
   $tag2 = $item.tag2
   $tag3 = $item.tag3 
   $vm = Get-Cluster -name BRSLP1TESX*  | get-vm -Name  $vmname 
   #remove-TagAssignment -Tag $tag1  -Entity $vm 
   new-TagAssignment -Tag $tag1  -Entity $vm
   #remove-TagAssignment -TagAssignment $tag1  -Entity $vm 
   #remove-TagAssignment -TagAssignment $tag2  -Entity $vm  
   New-TagAssignment -Tag $tag2  -Entity $vm 
   New-TagAssignment -Tag $tag3  -Entity $vm 
   
} 




