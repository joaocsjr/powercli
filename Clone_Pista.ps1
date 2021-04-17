##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
connect-viserver -Server server.server.com.br -WarningAction SilentlyContinue 

###########################################################################################################################
#                                                                                                                         #
#  Para utitlizar o script de clone é necessário configurar um arquivo CSV que contenha o nome da maquina que sera        #
#  clonada e  o nome da nova maquina, usar o exemplo dispinivel em F:\Scripts\clone.csv.                                  #
#  A coluna NewVM -- deve conter o nome da nova maquina                                                                   #
#  A coluna SourceVM  -- deve conter o nome da maquina que será clonada                                                   #
#                                                                                                                         #
##########################################################################################################################


###Definição de variaveis
#cluster Esxi que sera usado
$cluster = 'VDI'
#resource pool aonde as vms serão instaladas
$rpool = 'E1'
#Folder aonde as vms serão instaladas
$folder = 'E1'
#Datastore Clutser aonde as vms serão instaladas
#$Cdatasore = 'DEV-VNX-1810-VMStore41'
#$Cdatasore = 'Belem.DEV.StorageDRS-VNX-1810'
$Cdatasore = 'VDI.XtremIO-VMStore07'
#Define qual guest customization deve ser usado

$OSCustomizationSpec = Get-OSCustomizationSpec -Name 'Windows 2008/2012 R2 STD\ENT x64 com rede'
# Pega algum host disponivel que esteja conectado
$vmhost = Get-Cluster $cluster | Get-VMHost -State Connected | Get-Random





$vmlist = Import-CSV "F:\Scripts\clone.csv"
 
foreach ($item in $vmlist) {
 
    # I like to map out my variables
    $basevm = $item.basevm
    $vmname = $item.vmname
    
New-VM -Name $vmname -VM $basevm -Datastore $Cdatasore -DiskStorageFormat Thin -VMHost $vmhost -Location $folder -OSCustomizationSpec $OSCustomizationSpec



    }




#Import-Csv "F:\Scripts\clone.csv" | %{ New-VM -vmhost -Name $_.newVM -VM $_.SourceVM  -Location  $folder -Datastore $Cdatasore -DiskStorageFormat Thin -ResourcePool $rpool -OSCustomizationSpec $OSCustomizationSpec}



#clone com as especificações informadas nos parametros acima e liga no final do deploy
ForEach-Object {
New-VM -Name $newVM -VM $basevm  `
-Location  $folder `
-Datastore $Cdatasore -DiskStorageFormat Thin `
-ResourcePool $rpool `
-OSCustomizationSpec $OSCustomizationSpec}

#Power on nas vms quando finalizar o clone
#ForEach-Object{
#get-cluster -Name $cluster | get-vm -name $NewVM | Start-VM}





##$vmlist = Import-CSV "F:\Scripts\clone.csv"
#foreach ($item in $vmlist) {
 
    # I like to map out my variables
 #   $basevm = $item.basevm
 #   $vmname = $item.vmname
  #  $ipaddr = $item.ipaddress
   # $subnet = $item.subnet
    #$gateway = $item.gateway
 #   $pdns = $item.pdnswins
    #$pwins = $item.pdnswins
  #  $sdns = $item.sdnswins
    #$swins = $item.sdnswins

 #   New-VM -vmhost $vmhost -Name $vmname -VM $basevm  -Location  $folder -Datastore $Cdatasore -DiskStorageFormat Thin -ResourcePool $rpool -OSCustomizationSpec $OSCustomizationSpec
#}
