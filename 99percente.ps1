#########################################################################################
# script para restart de VMS a cada X dias    	                                        #
#  										      									       	#
# 	 	     	                     		                                            #
#########################################################################################
#Add-PSSnapin VMware.VimAutomation.Core
Import-Module VMware.VimAutomation.Core
connect-viserver -Server server -WarningAction SilentlyContinue 


Write-Output "$(Get-date) -  Iniciando verificação 99% ..." | Out-file F:\Scripts\Logs\log$((Get-Date).ToString('MM-dd-yyyy')).txt -append


$vmlist = Import-CSV "f:\Scripts\99.csv"
foreach ($item in $vmlist) { 
$vmname = $item.vmname
$Date = Get-Date
$verificadia =180
$vmrestart = get-vm -name $vmname | Get-VIEvent -maxsamples 100000 -Start ($Date).AddDays(-$verificadia) -type info | Where {$_.FullFormattedMessage -match "Guest OS reboot"} |select CreatedTime,FullFormattedMessage |sort CreatedTime -Descending
$datarestart = $vmrestart.CreatedTime.ToShortDateString() 



#valida a quantidade de eventos encontrados no vcenter e considera apenas o ultimo
if ($vmrestart.CreatedTime.Date.count  -gt 1){
    $StartDate = $datarestart[1]
    #$StartDate
    $dt = NEW-TIMESPAN –Start $StartDate –End $Date 
    $dia = $dt.Days 
     Write-Output "$(Get-date -Format g) -  $vmname - Existe mais de um evento de Reboot, o ultimo evento será considerado  $StartDate " | Out-file F:\Scripts\Logs\log$((Get-Date).ToString('MM-dd-yyyy')).txt -append
}
elseif  ($vmrestart.CreatedTime.Date.count  -like 1){
    $StartDate = $datarestart
    #$StartDate
    $dt = NEW-TIMESPAN –Start $StartDate –End $Date 
    $dia = $dt.Days 
    Write-Output "$(Get-date) -  $vmname -Apenas um evento de Reboot, o ultimo evento será considerado  $StartDate " | Out-file F:\Scripts\Logs\log$((Get-Date).ToString('MM-dd-yyyy')).txt -append
}



if ($dia -le 4 ){
  Write-Output "$(Get-date) -  $vmname - Não será reiniciada - Qtd de dias do Ultimo Reboot $dia " | Out-file F:\Scripts\Logs\log$((Get-Date).ToString('MM-dd-yyyy')).txt -append
 
  }
  elseif ($dia -gt 4 ) {
    Write-Output "$(Get-date) -  $vmname - Reiniciando servidor - Qtd de dias do Ultimo Reboot $dia " | Out-file F:\Scripts\Logs\log$((Get-Date).ToString('MM-dd-yyyy')).txt -append
    get-vm -name $vmname | Restart-VMGuest     
  }

  

  }







 
 







