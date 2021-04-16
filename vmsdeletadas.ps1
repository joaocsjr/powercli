

##Import de modulo e conexão no vCenter
import-module VMware.Vimautomation.core
connect-viserver -Server brslp1vw2pvc001.nextel.com.br -WarningAction SilentlyContinue 

Get-VIEvent -maxsamples 10000 |where {$_.Gettype().Name-eq "VmCreatedEvent" -or $_.Gettype().Name-eq "VmBeingClonedEvent" -or $_.Gettype().Name-eq "VmBeingDeployedEvent"} |Sort CreatedTime -Descending |Select CreatedTime, UserName,FullformattedMessage -First 10 


Get-VIEvent -maxsamples 10000 -Start (Get-Date).AddDays(–90) |where {$_.Gettype().Name-eq "VmRemovedEvent"} |Sort CreatedTime -Descending |Select CreatedTime, UserName,FullformattedMessage 


Get-VIEvent -maxsamples 10000 |where {$_.Gettype().Name-eq "VmCreatedEvent" -or $_.Gettype().Name-eq "VmBeingClonedEvent" -or $_.Gettype().Name-eq "VmBeingDeployedEvent"} |Sort CreatedTime -Descending |Select CreatedTime, UserName,FullformattedMessage -First 10 




Get-VIEvent -MaxSamples ([int]::MaxValue) -Start (Get-Date).AddDays(-30) | where {$_.Gettype().Name -eq “VmRemovedEvent”} |  %{“{0} Deleted by {1}” -f $_.VM.Name,$_.UserName}