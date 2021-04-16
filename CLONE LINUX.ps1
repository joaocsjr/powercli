

##Import de modulo e conexão no vCenter
add-pssnapin VMware.Vimautomation.core
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
$cluster = 'Nprod'
#resource pool aonde as vms serão instaladas
$rpool = 'D6'
#Folder aonde as vms serão instaladas
$folder = 'D6'
#Datastore Clutser aonde as vms serão instaladas
#$Cdatasore = 'Belem.DEV.StorageDRS-VNX-1810'

$Cdatasore = 'DEV-VNX-1810-VMStore41'
#Define qual guest customization deve ser usado
#$OSCustomizationSpec = Get-OSCustomizationSpec -Name 'Linux-IP'
#$OSCustomizationSpec = Get-OSCustomizationSpec -Name 'Windows 2008/2012 R2 STD\ENT x64 com rede'

# Pega algum host disponivel que esteja conectado
$vmhost = Get-Cluster $cluster | Get-VMHost -State Connected | Get-Random



### Realiza o clone das vms 
$vmlist = Import-CSV "F:\Scripts\clone_2.csv"
 
foreach ($item in $vmlist) {
 
    # I like to map out my variables
    $basevm = $item.basevm
    $vmname = $item.vmname
    $ipaddr = $item.ipaddress
    $subnet = $item.subnet
    $gateway = $item.gateway
    $pdns = $item.pdnswins
    #$pwins = $item.pdnswins
    $sdns = $item.sdnswins
    #$swins = $item.sdnswins

    # Update Spec with our desired IP information
#Get-OSCustomizationSpec -Name 'Linux-IP' |
#Get-OSCustomizationNicMapping |
#Set-OSCustomizationNicMapping -IPmode UseStaticIP `
#-IpAddress $ipaddr `
#-SubnetMask $subnet `
#-DefaultGateway $gateway `
#-Dns $pdns `
# Get updated Spec Object
#$Spec = Get-OSCustomizationSpec -Name 'Linux-IP'
 
New-VM -Name $vmname -VM $basevm -Datastore $Cdatasore -DiskStorageFormat Thin -VMHost $vmhost -RunAsync


}



#configura interface de rede
$vmlist = Import-CSV "F:\Scripts\clone_2.csv"
 
foreach ($item in $vmlist) {
 
    # I like to map out my variables
    $basevm = $item.basevm
    $vmname = $item.vmname
    $ipaddr = $item.ipaddress
    $subnet = $item.subnet
    $gateway = $item.gateway
    $pdns = $item.pdnswins
    #$pwins = $item.pdnswins
    $sdns = $item.sdnswins
    #$swins = $item.sdnswins

#$linuxSpec = get-OSCustomizationSpec –Name LinuxCustom –Domain server.com.br –DnsServer “192.168.0.10”, “192.168.0.20” –NamingScheme VM –OSType Linux
#$linuxSpec = get-OSCustomizationSpec –Name LinuxCustom
$linuxSpec = get-OSCustomizationSpec –Name LinuxCustom 
$specClone = New-OSCustomizationSpec –Spec $linuxSpec –Type NonPersistent
$nicMapping = Get-OSCustomizationNicMapping –OSCustomizationSpec $specClone
# Apply the customization
$nicMapping | Set-OSCustomizationNicMapping –IpMode UseStaticIP –IpAddress $ipaddr –SubnetMask $subnet –DefaultGateway $gateway
get-cluster nprod | get-vm -name $vmname |Set-VM –OSCustomizationSpec $specClone –Confirm:$false
Get-OSCustomizationSpec $specClone | Get-OSCustomizationNicMapping | Remove-OSCustomizationNicMapping -Confirm:$false

}


$linuxSpec = get-OSCustomizationSpec –Name LinuxCustom 
Get-OSCustomizationSpec linuxCustom | Get-OSCustomizationNicMapping | Remove-OSCustomizationNicMapping -Confirm:$false