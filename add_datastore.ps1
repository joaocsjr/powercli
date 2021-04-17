


###########################################################################################################################                                                                                                                        #
# script para inclusão de datastores em massa      
#                               
##########################################################################################################################
Install-Module -Name VMware.PowerCLI
Update-Module VMware.PowerCLI
##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
import-module -name  *VMware*
connect-viserver -Server server -User administrator@vpshere.local -WarningAction SilentlyContinue 

#rescan dos discos
$cluster = "SEGURANCA"  
Get-Cluster -name $cluster | Get-VMhost | Get-VMHostStorage –RescanAllHBA
#get-datacenter

#add datastore
$vmlist = Import-CSV "e:\Scripts\add_ds.csv"
foreach ($item in $vmlist) {
    $dsname = $item.dsname
    $naa = $item.naa
    #$host = Get-Cluster $cluster | Get-VMHost -State Connected  | Get-Random
    New-Datastore -vmfs -VMHost inf5dv0417.server.com -Name $dsname -Path $naa 
}

get-vmhost -name inf5dv0417.server.com
#rescan datastore
Get-Cluster -name $cluster | Get-VMhost | Get-VMHostStorage –RescanAllHBA

#get datastore unity
Get-Cluster -name $cluster | Get-VMhost | Get-Datastore -name *UNI* | Select-Object name


import-module -name E:\scripts\SRM-Cmdlets-master\Meadowcroft.Srm.psd1

disconnect-viserver * -confirm:$false



$Env:PSModulePath
$PSHome\Modules 