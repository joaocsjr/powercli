#vms desligadas 
import-module VMware.Vimautomation.core
connect-viserver -Server brslp1vw2pvc001.nextel.com.br -WarningAction SilentlyContinue 



 
$Report = @()
 
$VMs = get-vm |Where-object {$_.powerstate -eq "poweredoff"}
$vmdesligadas = Get-VIEvent -Entity $VMs -MaxSamples ([int]::MaxValue) | where {$_ -is [VMware.Vim.VmPoweredOffEvent]} |Group-Object -Property {$_.Vm.Name} | %{

  $lastPO = $_.Group | Sort-Object -Property CreatedTime -Descending | Select -First 1
  $vm = Get-VM -Name $_.Name
  $row = '' | select VMName,Powerstate,OS,Host,Cluster,NumCPU,MemMb,PowerOFF
    $row.VMName = $vm.Name
    $row.Powerstate = $vm.Powerstate
    $row.OS = $vm.Guest.OSFullName
    $row.Host = $vm.VMHost.name
    $row.Cluster = $vm.VMHost.Parent.Name
    $row.NumCPU = $vm.NumCPU
    $row.MemMb = $vm.MemoryMB
    $row.PowerOFF = $lastPO.CreatedTime
    $report += $row
}




$vmdesligadas
 
$report | Sort Name | Export-Csv -NoTypeInformation -UseCulture -Path  F:\Scripts\export\vmsdesligadas$((Get-Date).ToString('MM-dd-yyyy')).csv
 
disconnect-viserver * -confirm:$false