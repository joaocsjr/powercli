Tim Carman
NAVIGATION
HOME
AS BUILT REPORT
ABOUT
TIM CARMAN
IT Consultant specialising in virtualisation, storage, disaster recovery and cloud.

Based in Melbourne, Australia. 

This is my personal blog sharing my thoughts and experiences about the technology I encounter on a daily basis.
SOCIAL
Twitter
 
LinkedIn
 
GitHub
 
 
Search
PowerCLI: Add & remove VMs from DRS Groups based on datastore location
By Tim Carman in Scripting, VMware
 October 27, 2017  0 Comment
Lately I have been working on a number of virtualization projects which make use of VMware vSphere Metro Storage Clusters (vMSC). With most of these types of implementations, virtual machines must be pinned to a preferred site to minimise impact to virtual machines in the event of a site failure. DRS groups are the most common way to achieve this, however I was wanting to find a way to automate the add/remove of virtual machines based on each VM’s datastore location.

To begin, I configured each of the datastores with a prefix of the site which was its preferred site, e.g. DC1-VMFS-01 or DC2-VMFS-01. I then placed VMs on a datastore which corresponded to their preferred site.

With the help of DRSRule I was then able to create two PowerCLI functions to automate the process to add the VMs to a corresponding DRS VM group based on their datastore location. The function can be used with a datastore name, prefix or suffix.

function Add-DrsVMToDrsVMGroup{
#Requires -Modules VMware.VimAutomation.Core, DRSRule
#region script help
<#
.SYNOPSIS  
    Adds virtual machines to a DRS VM group based on datastore location
.DESCRIPTION
    Adds virtual machines to a DRS VM group based on datastore location
.NOTES
    Version:        1.0
    Author:         Tim Carman
    Twitter:        @tpcarman
    Github:         tpcarman
.LINK
    https://github.com/tpcarman/PowerCLI-Scripts	
.PARAMETER DrsVMGroup
    Specifies the DRS VM Group
    This parameter is mandatory but does not have a default value.
.PARAMETER Cluster
    Specifies the cluster which contains the DRS VM Group
    This parameter is mandatory but does not have a default value.
.PARAMETER Prefix
    Specifies a prefix string for the datastore name
    This parameter is optional and does not have a default value.
.PARAMETER Suffix
    Specifies a suffix string for the datastore name
    This parameter is optional and does not have a default value.
.PARAMETER Datastore
    Specifies a datastore name
    This parameter is optional and does not have a default value.
.EXAMPLE
    Add-DrsVMtoDrsVMGroup -DRSVMGroup 'SiteA-VMs' -Cluster 'Production' -Prefix 'SiteA-'
.EXAMPLE
    Add-DrsVMtoDrsVMGroup -DRSVMGroup 'SiteA-VMs' -Cluster 'Production' -Suffix '-02'
.EXAMPLE
    Add-DrsVMtoDrsVMGroup -DRSVMGroup 'SiteB-VMs' -Cluster 'Production' -Datastore 'VMFS-01'
#>
#endregion script help
#region script parameters
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,HelpMessage='Specify the name of the DRS VM Group')]
    [ValidateNotNullOrEmpty()]
    [String]$DrsVMGroup='',
    [Parameter(Mandatory=$True,HelpMessage='Specify the cluster name')]
    [ValidateNotNullOrEmpty()] 
    [String]$Cluster='',  
    [Parameter(Mandatory=$False,ParameterSetName=’Prefix’,HelpMessage='Specify the prefix string for the datastore name')]
    [ValidateNotNullOrEmpty()]
    [String]$Prefix='',
    [Parameter(Mandatory=$False,ParameterSetName=’Suffix’,HelpMessage='Specify the suffix string for the datastore name')]
    [ValidateNotNullOrEmpty()]
    [String]$Suffix='',      
    [Parameter(Mandatory=$False,ParameterSetName=’Datastore’,HelpMessage='Specify the datastore name')]
    [ValidateNotNullOrEmpty()]
    [String]$Datastore=''
	)
#endregion script parameters
#region script body
if($Prefix){
    $VMs = Get-Datastore | where{($_.name).StartsWith($Prefix)} | Get-VM
    }
if($Datastore){
    $VMs = Get-Datastore | where{($_.name) -eq $Datastore} | Get-VM
    }
if($Suffix){
    $VMs = Get-Datastore | where{($_.name).EndsWith($Suffix)} | Get-VM
    }
$objDrsVMGroup = Get-DrsVMGroup -Name $DrsVMGroup -Cluster $Cluster
foreach($VM in $VMs){
    if(($objDrsVMGroup).VM -notcontains $VM){
    	Write-Host "Adding virtual machine $VM to DRS VM Group $DrsVMGroup"
        try{
            Set-DrsVMGroup -Name $DrsVMGroup -Cluster $Cluster -Append -VM $VM
        }
        catch{
            Write-Error "Error adding virtual machine $VM to DRS VM Group $DrsVMGroup"
        } 
    }
}
#endregion script body
}

This worked perfectly well, but what I soon discovered is that if a user migrated a VM to another datatore then a VM could potentially be a member of two DRS groups. So I created an additional function to remove VMs from DRS groups also.

function Remove-DrsVMFromDrsVMGroup{
#Requires -Modules VMware.VimAutomation.Core, DRSRule
#region script help
<#
.SYNOPSIS  
    Removes virtual machines from a DRS VM group based on datastore location
.DESCRIPTION
    Removes virtual machines from a DRS VM group based on datastore location
.NOTES
    Version:        1.0
    Author:         Tim Carman
    Twitter:        @tpcarman
    Github:         tpcarman
.LINK
    https://github.com/tpcarman/PowerCLI-Scripts	
.PARAMETER DrsVMGroup
    Specifies the DRS VM Group
    This parameter is mandatory but does not have a default value.
.PARAMETER Cluster
    Specifies the cluster which contains the DRS VM Group
    This parameter is mandatory but does not have a default value.
.PARAMETER Prefix
    Specifies a prefix string for the datastore name
    This parameter is optional and does not have a default value.
.PARAMETER Suffix
    Specifies a suffix string for the datastore name
    This parameter is optional and does not have a default value.
.PARAMETER Datastore
    Specifies a datastore name
    This parameter is optional and does not have a default value.
.EXAMPLE
    Remove-DrsVMFromDrsVMGroup -DRSVMGroup 'SiteA-VMs' -Cluster 'Production' -Prefix 'SiteA-' 
.EXAMPLE
    Remove-DrsVMFromDrsVMGroup -DRSVMGroup 'SiteA-VMs' -Cluster 'Production' -Suffix '-02' 
.EXAMPLE
    Remove-DrsVMFromDrsVMGroup -DRSVMGroup 'SiteB-VMs' -Cluster 'Production' -Datastore 'VMFS-01' 
#>
#endregion script help
#region script parameters
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,HelpMessage='Specify the name of the DRS VM Group')]
    [ValidateNotNullOrEmpty()]
    [String]$DrsVMGroup='',
    [Parameter(Mandatory=$True,HelpMessage='Specify the cluster name')]
    [ValidateNotNullOrEmpty()] 
    [String]$Cluster='',  
    [Parameter(Mandatory=$False,ParameterSetName=’Prefix’,HelpMessage='Specify the prefix string for the datastore name')]
    [ValidateNotNullOrEmpty()]
    [String]$Prefix='',
    [Parameter(Mandatory=$False,ParameterSetName=’Suffix’,HelpMessage='Specify the suffix string for the datastore name')]
    [ValidateNotNullOrEmpty()]
    [String]$Suffix='',       
    [Parameter(Mandatory=$False,ParameterSetName=’Datastore’,HelpMessage='Specify the datastore name')]
    [ValidateNotNullOrEmpty()]
    [String]$Datastore=''
	)
#endregion script parameters
#region script body
if($Prefix){
    $VMs = Get-Datastore | where{($_.name).StartsWith($Prefix)} | Get-VM | sort Name
        }
if($Datastore){
    $VMs = Get-Datastore | where{($_.name) -eq $Datastore} | Get-VM | sort Name
    }
if($Suffix){
    $VMs = Get-Datastore | where{($_.name).EndsWith($Suffix)} | Get-VM | sort Name
    }
$objDrsVMGroup = Get-DrsVMGroup -Name $DrsVMGroup -Cluster $Cluster
foreach($VM in $VMs){
    if(($objDrsVMGroup).VM -contains $VM){
    	Write-Host "Removing virtual machine $VM from DRS VM Group $DrsVMGroup"
        try{
            Set-DrsVMGroup -Name $DrsVMGroup -Cluster $Cluster -RemoveVM $VM
        }
        catch{
            Write-Error "Error removing virtual machine $VM from DRS VM Group $DrsVMGroup"
        } 
    }
}
#endregion script body
}
Now using each function I can now add and remove VMs from pre-existing DRS Groups based on their datastore location.

#Import script modules
Import-Module VMware.VimAutomation.Core, DrsRule

# Connect to vCenter Server
Connect-VIServer -Server $vcenter -Credential $creds
# Add DC1 VMs to DC1 DRS VM Group
Add-DrsVMtoDrsVMGroup -DrsVMGroup 'DC1_VMs' -Cluster 'Production' -Prefix 'DC1-'
# Remove DC2 VMs from DC1 DRS VM Group
Remove-DrsVMFromDrsVMGroup -DrsVMGroup 'DC2_VMs' -Cluster 'Production' -Prefix 'DC1-'
# Add DC2 VMs to DC2 DRS VM Group
Add-DrsVMtoDrsVMGroup -DrsVMGroup 'DC2_VMs' -Cluster 'Production' -Prefix 'DC2-'
# Remove DC1 VMs from DC2 DRS VM Group
Remove-DrsVMFromDrsVMGroup -DrsVMGroup 'DC1_VMs' -Cluster 'Production' -Prefix 'DC2-'
# Disconnect from vCenter Server
Disconnect-VIServer -Server $vcenter -Confirm:$false
Share this:
Click to email this to a friend (Opens in new window)Click to share on Twitter (Opens in new window)Click to share on LinkedIn (Opens in new window)Click to share on Pocket (Opens in new window)1Click to share on Facebook (Opens in new window)1
Related
EMC VPLEX Virtual Edition - Part 1 - Prerequisites
August 25, 2015
In “EMC”
VMware Converter: "The operation experienced a network error"
July 20, 2015
In “Troubleshooting”
VMworld 2018 - The Highs and Lows - Part Two
September 11, 2018
In “General”
TAGS DRSPowerCLIPowerShellScriptingvMSCVMware
VMware Update Manager is not displayed in the vSphere 6.0 U1 Web ClientVMworld US 2018 – This year will be one like no other
RELATED ARTICLES.
As Built Report – Documenting Your Datacentre Infrastructure with PowerShell20 Aug, 2018
VMware Update Manager is not displayed in the vSphere 6.0 U1 Web Client23 Sep, 2015
EMC VPLEX Virtual Edition – Part 1 – Prerequisites25 Aug, 2015
LEAVE A COMMENT.
Comment

Name *

Email *

Website

 Notify me of follow-up comments by email.

 Notify me of new posts by email.

This site uses Akismet to reduce spam. Learn how your comment data is processed.

SEARCH
Search …
RECENT POSTS
VMworld 2018 – The Highs and Lows – Part Two
VMworld 2018 – The Highs & Lows – Part One
As Built Report – Documenting Your Datacentre Infrastructure with PowerShell
VMworld US 2018 – This year will be one like no other
PowerCLI: Add & remove VMs from DRS Groups based on datastore location
TAGS
As Built Report Community Conferences Documentation DRS EMC Hackathon Hyper-V PowerCLI PowerShell Scripting Storage Troubleshooting Update Manager vMSC VMware VMware Converter VMware ESXi VMword VMworld VPLEX/VE VPLEX Virtual Edition vSphere Web Client
ARCHIVES
September 2018
August 2018
June 2018
October 2017
September 2015
August 2015
July 2015
Copyright © 2015 · Tim Carman · All Rights Reserved 