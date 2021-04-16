# - SnapReminder V1.0 By Virtu-Al - http://virtu-al.net
#
# Please use the below variables to define your settings before use
#
$smtpServer = "mysmtpserver.mydomain.com"
$MailFrom = "me@mydomain.com"
$VISRV = "MYVISERVER"
 
function Find-User ($username){
   if ($username -ne $null)
   {
      $usr = (($username.split("\"))[1])
      $root = [ADSI]""
      $filter = ("(&(objectCategory=user)(samAccountName=$Usr))")
      $ds = new-object system.DirectoryServices.DirectorySearcher($root,$filter)
      $ds.PageSize = 1000
      $ds.FindOne()
   }
}
 
function Get-SnapshotTree{
   param($tree, $target)
    
   $found = $null
   foreach($elem in $tree){
      if($elem.Snapshot.Value -eq $target.Value){
         $found = $elem
         continue
      }
   }
   if($found -eq $null -and $elem.ChildSnapshotList -ne $null){
      $found = Get-SnapshotTree $elem.ChildSnapshotList $target
   }
    
   return $found
}
 
function Get-SnapshotExtra ($snap){
   $guestName = $snap.VM   # The name of the guest
 
   $tasknumber = 999    # Windowsize of the Task collector
    
   $taskMgr = Get-View TaskManager
    
   # Create hash table. Each entry is a create snapshot task
   $report = @{}
    
   $filter = New-Object VMware.Vim.TaskFilterSpec
   $filter.Time = New-Object VMware.Vim.TaskFilterSpecByTime
   $filter.Time.beginTime = (($snap.Created).AddSeconds(-5))
   $filter.Time.timeType = "startedTime"
    
   $collectionImpl = Get-View ($taskMgr.CreateCollectorForTasks($filter))
    
   $dummy = $collectionImpl.RewindCollector
   $collection = $collectionImpl.ReadNextTasks($tasknumber)
   while($collection -ne $null){
      $collection | where {$_.DescriptionId -eq "VirtualMachine.createSnapshot" -and $_.State -eq "success" -and $_.EntityName -eq $guestName} | %{
         $row = New-Object PsObject
         $row | Add-Member -MemberType NoteProperty -Name User -Value $_.Reason.UserName
         $vm = Get-View $_.Entity
         $snapshot = Get-SnapshotTree $vm.Snapshot.RootSnapshotList $_.Result
         $key = $_.EntityName + "&" + ($snapshot.CreateTime.ToString())
         $report[$key] = $row
      }
      $collection = $collectionImpl.ReadNextTasks($tasknumber)
   }
   $collectionImpl.DestroyCollector()
    
   # Get the guest's snapshots and add the user
   $snapshotsExtra = $snap | % {
      $key = $_.vm.Name + "&" + ($_.Created.ToString())
      if($report.ContainsKey($key)){
         $_ | Add-Member -MemberType NoteProperty -Name Creator -Value $report[$key].User
      }
      $_
   }
   $snapshotsExtra
}
 
Function SnapMail ($Mailto, $snapshot)
{
   $msg = new-object Net.Mail.MailMessage
   $smtp = new-object Net.Mail.SmtpClient($smtpServer)
   $msg.From = $MailFrom
   $msg.To.Add($Mailto)
 
   $msg.Subject = "Snapshot Reminder"
 
$MailText = @"
This is a reminder that you have a snapshot active on $($snapshot.VM) which was taken on $($snapshot.Created).
 
Name: $($snapshot.Name)
 
Description: $($snapshot.Description)
"@ 
 
   $msg.Body = $MailText
   $smtp.Send($msg)
}
 
Connect-VIServer $VISRV
 
foreach ($snap in (Get-VM | Get-Snapshot | Where {$_.Created -lt ((Get-Date).AddDays(-14))})){
   $SnapshotInfo = Get-SnapshotExtra $snap
   $mailto = ((Find-User $SnapshotInfo.Creator).Properties.mail)
   SnapMail $mailto $SnapshotInfo
}