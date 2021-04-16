

##Import de modulo e conexão no vCenter
Import-Module VMware.Vimautomation.core
connect-viserver -Server brslp1vw2pvc001.nextel.com.br -WarningAction SilentlyContinue 



#$a = "<style>"
#$a = $a + "h1, h5, th { text-align: center; }"
#$a = $a + "table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }"
#$a = $a + "th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }"
#$a = $a + "td { font-size: 11px; padding: 5px 20px; color: #000; }"
$a = $a + "tr { background: #b8d1f3; }"
$a = $a + "tr:nth-child(even) { background: #dae5f4; }"
$a = $a + "tr:nth-child(odd) { background: #b8d1f3; }"
$a = $a + "</style>"



#$vmlist = Import-CSV "F:\Scripts\removesnap.csv"
 
#$Report = foreach ($item in $vmlist) {
 

 #   $basevm = $item.basevm
  #  Get-VM  -name $basevm  | `
 # Get-Snapshot |  `
 # Where-Object { $_.Created -lt (Get-Date).AddDays(-7) } | `
 # Remove-Snapshot -confirm:$false 


  #}

  
   
get-datacenter  -Name Belem |   get-vm  | Get-Snapshot |   Where-Object {$_.Name -notlike '*replica*' -and $_.Name -notlike '*snapshot*' -and $_.Name -notlike '*VDI*' -and $_.Name -notlike '*Windows*' -and $_.Name -notlike '*W7*'-and $_.Name -notlike '*CTX*'-and $_.Created -lt (Get-Date).AddDays(-7) } |   Remove-Snapshot -confirm:$false 