



##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
connect-viserver -Server server.server.com.br -WarningAction SilentlyContinue 


# Get the OS CustomizationSpec trocar

$OSCustomizationSpec = Get-OSCustomizationSpec -Name 'Linux EL 32/64bits com rede' 


Import-Csv C:\Scripts\clone_2.csv | 
  
 Foreach-Object {  
  
#$datastore = Get-Datastore -Name "Datastore1" 
$VMHost = Get-Cluster BRSLP1TESX200_DEV | Get-VMHost -State Connected |Get-Random
# Determine the capacity requirements of this VM 
$CapacityKB = Get-HardDisk -vm $_.basevm |
Select-Object -ExpandProperty CapacityKB |    Measure-Object -Sum |
Select-Object -ExpandProperty Sum 
# Find a datastore with enough room
 $Datastore = Get-Datastore -VMHost $VMHost |    
?{($_.FreeSpaceMB * 1mb) -gt (($CapacityKB * 1kb) * 1.1 )} |   Select-Object -First 1 
$Datastore
 New-VM -Name $_.vmname `    
 -vm $_.vmbase
 -Host $VMhost ` 
 -Datastore $Datastore `
# -NumCpu $_.CPU `       
# -MemoryGB $_.Memory ` 
# -DiskGB $_.HardDisk ` 
 -Portgroup (Get-VDPortgroup -Name $_.nic) } 











