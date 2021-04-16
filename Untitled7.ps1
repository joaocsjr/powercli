#>

#.SYNOPSIS 
#     Create .csv report with Virtual Machine Tag, Category, VMware tools version and VM Hardware details.
#.NOTES
#    Author: Sreejesh Damodaran
 #   Site:    www.pingforinfo.com
#.EXAMPLE
#    PS> get-vmtagandcatefory.ps1
 
#>
 
# Connect to the vCenter
Connect-VIServer vCenter.nextel.com.br
#Create vmInfo object
$vmInfo = @()
    $vmInfoTemp = New-Object "PSCustomObject"
    $vmInfoTemp | Add-Member -MemberType NoteProperty -Name VMName -Value ""
    $vmInfoTemp | Add-Member -MemberType NoteProperty -Name ToolsVersion  -Value ""
    $vmInfoTemp | Add-Member -MemberType NoteProperty -Name HWVersion  -Value ""
    $vmCategories  = Get-TagCategory
    $vmCategories | %{$vmInfoTemp | Add-Member -MemberType NoteProperty -Name $_.Name  -Value "" }
    $vmInfo += $vmInfoTemp
 
get-vm | %{
   $vmInfoTemp = New-Object "PSCustomObject"
   $toolsVersion = Get-VMGuest $_ | select -ExpandProperty ToolsVersion
   $vmInfoTemp | Add-Member -MemberType NoteProperty -Name VMName -Value $_.Name
   $vmInfoTemp | Add-Member -MemberType NoteProperty -Name ToolsVersion  -Value $toolsVersion
   $vmInfoTemp | Add-Member -MemberType NoteProperty -Name HWVersion  -Value $_.Version
   $vmtags = ""
   $vmtags = Get-TagAssignment -Entity $_ 
   if($vmtags){
       $vmCategories | %{ 
           $tempVMtag = ""
            $tempCategroy = $_.Name
            $tempVMtag = $vmtags | Where-Object {$_.tag.category.name -match $tempCategroy}
            if($tempVMtag)
            {
                           $vmInfoTemp | Add-Member -MemberType NoteProperty -Name $tempCategroy -Value $tempVMtag.tag.name
            }else {
                $vmInfoTemp | Add-Member -MemberType NoteProperty -Name $tempCategroy -Value ""
            }
       }
   }else{
       $vmCategories | %{
           $vmInfoTemp | Add-Member -MemberType NoteProperty -Name $_.name -Value ""
        }
   }
    $vmInfo += $vmInfoTemp
}
 
$vmInfo | select * -Skip 1 | Export-Csv c:\temp\tags.csv -NoTypeInformation -UseCulture 