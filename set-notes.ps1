#configurar notes das vms
import-module VMware.Vimautomation.core
connect-viserver -Server brslp1vw2pvc001.nextel.com.br -WarningAction SilentlyContinue 

$vmlist = Import-CSV "F:\Scripts\notes.csv"
foreach ($item in $vmlist) {
    $basevm = $item.basevm
    $notes = $item.notes
    set-vm -vm $basevm -notes  $notes -confirm:$false
      get-vm -name $basevm | select name,notes

  }





