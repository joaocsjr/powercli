$vmtools_stable_version = 10249
 
$report = @()
 
Add-PSSnapin VMware.VimAutomation.Core
#Connect to vCenter Server 
Write-Host "Entre com o FQDN do vCenter: " -ForegroundColor Yellow -NoNewline
$vCenter  = Read-Host
connect-viserver $vCenter
 
#Import vm name from csv file 
Write-Host "Entre com o Path e nome do Arquivo(TXT) a importar: " -ForegroundColor Yellow -NoNewline
$addfile  = Read-Host
 
Write-Host "Entre com o nome do Cluster: " -ForegroundColor Yellow -NoNewline
$Cluster  = Read-Host
 
gc $addfile | % {
    $strNewVMName = $_
      
    # retrieve vmtools version
    $vmtools_version = (Get-Cluster $Cluster | Get-VM $strNewVMName | Get-View).Config.Tools.ToolsVersion
 
    #Update VMtools without reboot 
 
    if ($vmtools_version -ne $vmtools_stable_version){
        Get-Cluster $Cluster | Get-VM $strNewVMName | Update-Tools –NoReboot -RunAsync
        write-host "Updating VMWareTools on Cluster: $Cluster, VM: $strNewVMName " -NoNewline -ForegroundColor Yellow
        while ((Get-Task | ? Name -eq 'UpgradeTools_Task').State -eq 'Running'){
            sleep 1
            write-host "." -NoNewline -ForegroundColor Yellow
        }
        Write-Output "Updated $strNewVMName ------ "
    }
    elseif ($vmtools_version -eq $vmtools_stable_version){
        "$strNewVMName already has stable version of VMWareTools"
    }
          
    $report += $strNewVMName 
} 
Write-Output "Gerando Relatorio..."  
$report |Export-Csv C:\report_vmTools.txt
Write-Output "o Arquivo esta em Z:\Temp\report_vmTools.txt"
 
Write-Output "Apresentando na Tela o Resultado..."
$report
exit
 
 