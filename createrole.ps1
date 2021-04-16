$cvRole = "Splunk Collector"
$cvRolePermFile = "CV_role_ids.txt"
$viserver = "your-vcenter-server-FQDN"
Connect-VIServer -server $viServer
$cvRoleIds = @()
Get-Content $cvRolePermFile | Foreach-Object{
    $cvRoleIds += $_
}
New-VIRole -name $cvRole -Privilege (Get-VIPrivilege -Server $viserver -id $cvRoleIds) -Server $viserver
Set-VIRole -Role $cvRole -AddPrivilege (Get-VIPrivilege -Server $viserver -id $cvRoleIds) -Server $viserver