############################################################
###
### Get all thick provisioned disks v2
### Version 1
### 17.5.2013
###
##############################################################
###
### CONFIGURATION
###
$login_user = ""
$login_pwd = ""
$login_host = "Enter your vCenter Server here"
##############################################################
### END
##############################################################
###Prepare variables
$vmlist = @()

###Check if we are connected to vCenter Server(s)
if($global:DefaultVIServers.Count -lt 1)
{
	echo "We need to connect first"
	#To connect using predefined username-password
	#Connect-VIServer $login_host -User $login_user -Password $login_pwd -AllLinked:$true

	#To connect using PowerCLI credential store
	Connect-VIServer $login_host -AllLinked:$true
}
else
{
	echo "Already connected"
}

get-view -ViewType VirtualMachine -Property Name, "Config.Hardware.Device" | %{
	$vmName = $_.name
	$_.Config.Hardware.Device | where {$_.GetType().Name -eq "VirtualDisk"} | %{
		if(!$_.Backing.ThinProvisioned){
			$sizeInGb = [Math]::Round(($_.CapacityInKB / 1MB),2)
			$type = if ($_.Backing.ThinProvisioned) { “THIN” } else { "THICK" }
			$label = $_.DeviceInfo.Label
			$vmlist += "" | Select-Object @{n="VmName";e={$vmName}},@{n="DiskLabel";e={$label}},@{n="Backing";e={$type}},@{n="SizeInGB";e={$sizeInGb}}
		}
	}
}
#Print out our table
$vmlist | format-table -autosize >> C:\temp\thick.txt