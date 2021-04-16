##Import de modulo e conexão no vCenter
import-module VMware.Vimautomation.core
connect-viserver -Server ain3dv7050.tecban.com  -User administrator@vsphere.local -Password VMwar3!! -AllLinked


$vmName = '*'
$eventTYpes = 'VmCreatedEvent', 'VmClonedEvent', 'VmDeployedEvent', 'VmRegisteredEvent'


Get-VM -Name $vmName |

   ForEach-Object -Process {

   Get-VIEvent -Entity $_ -MaxSamples ([int]::MaxValue) |

   where { $eventTYpes -contains $_.GetType().Name } |

   Sort-Object -Property CreatedTime -Descending |

  Select -First 1 |

   ForEach-Object -Process {

   New-Object PSObject -Property ([ordered]@{

   VM = $_.VM.Name

   CreatedTime = $_.CreatedTime

   User = $_.UserName

   EventType = $_.GetType().Name

   })

   }

   }
