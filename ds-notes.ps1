##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core

Get-ViPermission –Entity *inventory object*
connect-viserver -Server ain3dv7050 -user administrator@vpshere.local  -WarningAction SilentlyContinue  -AllLinked


Get-Datastore -tag "*replicated*"  | select Name


#dump permission
Get-VIPermission | where {$_.Role -eq "Admin"} | select role,entity,uid


Get-VIPermission | where {$_.VIAccount  -eq "Administrator"} 

$dc = Get-Datacenter -name CETEM
Get-VIPermission -Entity $dc | Format-Table -AutoSize

Get-Datastore -name *VMAX027*

#conta vm em datastore
Get-Datastore  -name *UNITY* | Select Name,CapacityGB, @{N="NumVM";E={@($_ | Get-VM).Count}} | Sort NumVM | Export-Csv -Path C:\temp\unity.csv

Get-Datastore -tag "*replicated*"  |Select Name,CapacityGB, @{N="NumVM";E={@($_ | Get-VM).Count}} | Sort NumVM | Export-Csv -Path C:\temp\replicado.csv


