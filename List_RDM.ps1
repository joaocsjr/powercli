##list rdm 
#Get-VM | Get-HardDisk -DiskType "RawPhysical","RawVirtual" | where { $_.ScsiCanonicalName -eq
#"naa.600601607290250060ae06da248be111"} | Select Parent,Name,DiskType,ScsiCanonicalName,DeviceName | fl

connect-viserver -Server AIN3CT7050 -user "administrator@vsphere.local" -password "VMwar3!!" -WarningAction SilentlyContinue 

 Get-VM  | Get-HardDisk -DiskType "RawPhysical","RawVirtual" | Select-Object-Object Parent,Name,DiskType,ScsiCanonicalName,DeviceName 