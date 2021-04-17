Get-ADGroupMember -Identity "VDI_DESENVOLVEDORES" -Recursive | 
Get-ADUser -Properties SamAccountName | 
Select-Object Name,SamAccountName | 
Export-CSV -Path C:\temp\file.csv -NoTypeInformation



Get-ADUser jjuni57 -Properties Mail