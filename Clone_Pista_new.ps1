##Import de modulo e conexão no vCenter
add-pssnapin VMware.Vimautomation.core
connect-viserver -Server brslp1vw2pvc001.nextel.com.br -WarningAction SilentlyContinue 

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
$cluster = 'BRSLP1TESX200_DEV'
#resource pool aonde as vms serão instaladas
$rpool = 'E1'
#Folder aonde as vms serão instaladas
$folder = 'E1'
#Datastore Clutser aonde as vms serão instaladas
#$Cdatasore = 'Belem.DEV.StorageDRS-VNX-1810'

$Cdatasore = 'Belem.DEV.StorageDRS-VNX-1590'
#Define qual guest customization deve ser usado
$OSCustomizationSpec = Get-OSCustomizationSpec -Name 'Linux EL 32/64bits com rede'
#$OSCustomizationSpec = Get-OSCustomizationSpec -Name 'Windows 2008/2012 R2 STD\ENT x64 com rede'

# Pega algum host disponivel que esteja conectado
$vmhost = Get-Cluster $cluster | Get-VMHost -State Connected | Get-Random


Import-Csv "F:\Scripts\clone.csv"  | %{
New-VM -Name $_.vmname -VM $_.basevm  `
-Location  $folder `
-Datastore $Cdatasore -DiskStorageFormat Thin `
-ResourcePool $rpool `
-OSCustomizationSpec $OSCustomizationSpec
}



#mapeamento de variaveis  
#$vmlist = Import-Csv "F:\Scripts\clone.csv" 
#foreach ($item in $vmlist) {
 
 #   $basevm = $item.SourceVM
#    $newVM  = $item.NewVM
 
#    }
    #Power on nas vms quando finalizar o clone
#ForEach-Object{
#get-cluster -Name $cluster | get-vm -name $NewVM | Start-VM}

