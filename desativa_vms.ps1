#desativar vms

##Import de modulo e conexão no vCenter
imnport-module VMware.Vimautomation.core
connect-viserver -Server brslp1vw2pvc001.nextel.com.br -WarningAction SilentlyContinue 

Import-Csv "F:\Scripts\desativadas.csv"  | %{
remove-vm $_.vmname -DeletePermanently –Confirm:$false 

}