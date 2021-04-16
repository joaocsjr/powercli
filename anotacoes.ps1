
##Import de modulo e conexão no vCenter
import-module VMware.Vimautomation.core

#lista todos os paremtros
Get-help Set-PowerCLIConfiguration -parameters *

#conecta em multiplos vcenters
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple

#ignora os warning de certicado
Set-PowerCLIConfiguration –InvalidCertificateAction Ignore

#conecta em vcenter
Connect-VIServer ain3dv7050 –Credential (Get-Credential)

#lista de menu
Connect-VIServer -menu
#lista os comandos disponiveis
Get-Command -Module VMWare* | Out-GridView

#listado maquinas com filtro de estado
get-cluster "CORPORATIVO" | Get-VM | where PowerState -eq "poweredon" | select name,Folder,notes

#pegar informação 
get-command -name get*portgroup* -Module vmware.*


function helloworld {
    param ($whoareyou)
        Write-Host "hello $whoareyou"
    
}


function convert-dstocanonical {
    param(
    [parameter(mandatory=$true,valuefrompipeline=$True )]
    [VMware.VimAutomation.ViCore.Impl.V1.DatastoreManagement.DatastoreFileImpl[]]
    $datastore
    )
}

Get-Datastore  
