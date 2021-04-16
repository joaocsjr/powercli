##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
Get-NetAdapter
connect-viserver -Server server -WarningAction Silentl