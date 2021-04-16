

##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
connect-viserver -Server server.server.com.br -WarningAction SilentlyContinue 





Get-Cluster "BRSLP1PESX600_VDI" | Get-VM | Where {$_.Name -like "CTX-ACC-*" } |Get-NetworkAdapter | Where {$_.NetworkName -eq "dvPG_VLAN616_VDI_EXTERNO" } |Set-NetworkAdapter -NetworkName "dvPG_VLAN617_VDI_CORPORATIVO" -Confirm:$false