#$esxName = 'brslp1tesx014.nextel.com.br', 'brslp1tesx020.nextel.com.br'
$report= @()
#$esxilist = Get-VMHost -Name $esxName

$esxilist = Get-Cluster -name BRSLP1TESX100_DEV | Get-VMhost
 
foreach( $esxvm in $esxilist){
$esx = Get-VMHost -Name $esxvm
$esxcli = Get-EsxCli -VMHost $esxvm
$hba = Get-VMHostHba -VMHost $esx -Type FibreChannel | Select -ExpandProperty Name
$esxcli.storage.core.path.list() |
Where{$hba -contains $_.Adapter} |
Group-Object -Property Device | %{
     $row = "" | Select ESXihost, Lun, NrPaths
     $row.ESXihost = $esxvm.name
     $row.Lun = $_.Name
     $row.NrPaths = $_.Group.Count
     $report += $row
  }
}
 
$report | Export-Csv esx-lun-path.csv -NoTypeInformation -UseCulture