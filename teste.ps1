##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
Get-NetAdapter
connect-viserver -Server ain3ct7050 -WarningAction Silentl