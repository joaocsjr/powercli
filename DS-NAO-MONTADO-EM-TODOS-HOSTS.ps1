#Datastore Host Compliance v1.0
#9/25/2018 Matt Bradford @VMSpot www.VMSpot.com
#This script will look at all datastores and make sure it's presented to all ESXi hosts in a cluster. Data is output to a CSV file which will show what ESXi hosts in the cluster are not able to see the datastore.
#Usage - This script requires the user to enter a vCenter server to connect to. Example .\ClusterDatastores.PS1 -vcenter VC1.VMSPOT.LAN

[cmdletbinding()] Param([Parameter(ValuefromPipeline=$true,Mandatory=$true)][string]$vcenter) #Require a vCenter switch from the console and dump it to the variable $vcenter

Connect-VIServer ain3vi7050 -user administrator@vsphere.local   -AllLinked

function Get-DatastoreCompliance {
    $objReport = @() 

$datastores = Get-Datastore #Gather all Datastores for this vCenter

foreach ($datastore in $datastores){
 
 
    $hostclusters = Get-Datastore $datastore | Get-VMHost | Get-Cluster #Get each cluster this datastore is presented to

    foreach ($hostcluster in $hostclusters){

        $obj = @() #Create one time use array
        $obj = "" | Select-Object Datastore,Cluster,Missinghosts #Create the array headers

        $dshosts = Get-Datastore $datastore | Get-VMHost | ?{$_.Parent -eq $hostcluster} #Get each host in the cluster this datastore is presented to
        $clusterhosts = Get-Cluster $hostcluster | Get-VMHost #Get all hosts in the cluster
        $missinghosts = Compare-Object -ReferenceObject $clusterhosts -DifferenceObject $dshosts -PassThru #Compare all hosts in the cluster to the hosts the datastore is presented to
        $missinghosts = $missinghosts -join ';' #If there are several missing hosts, the output of Compare-Object will be an array which isn't CSV friendly. This just breaks the array apart and delimits with a semicolon
        if(!$missinghosts){
            $missinghosts = "None"
        } #If no hosts are missing, enter "None" instead of a blank value

        $obj.Datastore = $datastore #Add the datastore name to the array
        $obj.Cluster = $hostcluster #Add the ESXi Cluster name to the array
        $obj.Missinghosts = $missinghosts #Add the missing hosts to the array

        $objReport += $obj #Add values from one time use array to the function's output array
    }
}
$objReport #Output the final array
}

Get-DatastoreCompliance | Export-CSV -notype datastorecompliance_$vcenter.csv #Output the function to a CSV