# Script to automatically update DRS Rules
# Magnus Andersson, RTS 2013-07-03
# DRS update function developed by Niklas Åkerlund, http://vniklas.djungeln.se/2012/06/28/vsphere-cluster-host-vm-rule-affinity-with-powercli
#
#--------------------------------------------------------------------------
# Customer specific script parameter section starts here
#--------------------------------------------------------------------------
#
# vCenter Server specification
$vCenter = "vc-demo01.home.local"
$vCenteruser ="home\magnus"
$vCenterUserPasswd="not secret"
#
# Cluster specification
$cluster1="SiteA"
$cluster2="SiteB"
#
# DRS rule specification
$Cluster1Rule="VM-License-Linux"
$Cluster2Rule="VM-License-Linux"
#
# SMTP information
$sendFrom = "vc-demo01@home.local"
$sendTo = "magnus@home.local"
$smtp = “smtp.honme.local“
#--------------------------------------------------------------------------
# Customer specific script parameter section ends here
#--------------------------------------------------------------------------
#
"add-pssnapin VMware.VimAutomation.Core"
#
Write-Output "Stand by, connecting to $vcenter…."
#
Connect-VIServer -Server $vCenter -user $vCenterUser -password $vCenterUserPasswd
#
# Define the Update DRS rule function
#
function DRSrule {
param (
    $cluster,
    $VMs,
    $groupVMName)
    $cluster = Get-Cluster $cluster
    $spec = New-Object VMware.Vim.ClusterConfigSpecEx
    $groupVM = New-Object VMware.Vim.ClusterGroupSpec
    $groupVM.operation = "edit"
    $groupVM.Info = New-Object VMware.Vim.ClusterVmGroup
    $groupVM.Info.Name = $groupVMName
    Get-VM $VMs | %{
$groupVM.Info.VM += $_.Extensiondata.MoRef
                                 }
                                 $spec.GroupSpec += $groupVM
                                 #Apply the settings to the cluster
                                 $cluster.ExtensionData.ReconfigureComputeResource($spec,$true)
                             }
#--------------------------------------------
# Customer specific VM selection starts here
#--------------------------------------------
$VMcluster1=Get-Cluster $cluster1 |Get-vm | where {($_.extensiondata.config.Guestfullname  -like "*Linux*")}
$VMcluster2=Get-Cluster $cluster2 |Get-vm | where {($_.extensiondata.config.Guestfullname  -like "*Linux*")}
#
#------------------------------------------
# Customer specific VM selection ends here
#------------------------------------------
#
# Update the DRS rules - add one line per vSphere cluster where you want to run the script.
DRSrule -cluster $cluster1 -VMs $VMcluster1 -groupVMName $Cluster1Rule
DRSrule -cluster $cluster2 -VMs $VMcluster2 -groupVMName $Cluster2Rule
#
#
# Create e-mail body and send e-mail information about what VMs are included in what DRS rule.
$VMbody1=$VMcluster1 | select -ExpandProperty name | out-string
$VMbody2=$VMcluster2 | select -ExpandProperty name | out-string
$s1 = "The following Virtual Machine DRS Group:`n$Cluster1Rule`nRunning in the vSphere Cluster:`n$Cluster1`nContains the following virtual machines:`n"
$s1 += "$VMbody1`n`n"
$s1 += "The following DRS Rule: $Cluster2Rule`nRunning in the vSphere Cluster: $Cluster2`nContains the following virtual machines:`n"
$s1 += "$VMbody2"
#
#
send-mailmessage -to $sendTo -from $sendFrom -Subject “$vCenter DRS rule report” -smtpserver $smtp -body $s1
#
# Disconnect from vCenter Server
Write-Output "Stand by, finishing the DRS group update and disconnection from $vCenter"
Disconnect-VIServer $vCenter -Confirm:$False