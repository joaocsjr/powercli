

Import-Module VMware.Vimautomation.core

connect-viserver -Server ain3dv7050 -User administrator@vpshere.local -WarningAction SilentlyContinue 
$vmlist = @()
get-view -ViewType VirtualMachine -Property Name, "Config.Hardware.Device" | ForEach-Object{
	$vmName = $_.name
	$_.Config.Hardware.Device | Where-Object {$_.GetType().Name -eq "VirtualDisk"} | ForEach-Object{
		if(!$_.Backing.ThinProvisioned){
			$sizeInGb = [Math]::Round(($_.CapacityInKB / 1MB),2)
			$type = if ($_.Backing.ThinProvisioned) { “THIN” } else { "THICK" }
			$label = $_.DeviceInfo.Label
			$vmlist += "" | Select-Object @{n="VmName";e={$vmName}},@{n="DiskLabel";e={$label}},@{n="Backing";e={$type}},@{n="SizeInGB";e={$sizeInGb}}
		}
	}
}
#Print out our table
$vmlist | fl format-table -autosize >> C:\temp\thick.txt


Get-View -ViewType VirtualMachine -Filter @{"Name" = "GNU3PR0250"}