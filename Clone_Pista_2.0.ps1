

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
$OSCustomizationSpec = Get-OSCustomizationSpec -Name 'Linux-IP'
#$OSCustomizationSpec = Get-OSCustomizationSpec -Name 'Windows 2008/2012 R2 STD\ENT x64 com rede'

# Pega algum host disponivel que esteja conectado
$vmhost = Get-Cluster $cluster | Get-VMHost -State Connected | Get-Random




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

    #Get the Specification and set the Nic Mapping (Apply 2 DNS/WINS if 2 are present)
    If ($Varable) {
        Get-OSCustomizationSpec $OSCustomizationSpec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $ipaddr -SubnetMask $subnet -DefaultGateway $gateway -Dns $pdns,$sdns -Wins $pwins,$swins
    } else {
        Get-OSCustomizationSpec $OSCustomizationSpec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $ipaddr -SubnetMask $subnet -DefaultGateway $gateway -Dns $pdns -Wins $pwins
    }
 
    #Clone the BaseVM with the adjusted Customization Specification
    New-VM -Name $vmname -VM $basevm -Datastore $Cdatasore -VMHost $vmhost | Set-VM -OSCustomizationSpec $OSCustomizationSpec -Confirm:$false
 
    #Set the Network Name (I often match PortGroup names with the VLAN name)
    #Get-VM -Name $vmname | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $vlan -Confirm:$false
 
    #Remove the NicMapping (Don't like to leave things unkept)
    Get-OSCustomizationSpec $OSCustomizationSpec | Get-OSCustomizationNicMapping | Remove-OSCustomizationNicMapping -Confirm:$false
}


