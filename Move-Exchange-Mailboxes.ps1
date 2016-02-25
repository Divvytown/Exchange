#Make sure that there is enough space on log and database disks before running the script..

#Find smallest DB's by storage space
$smallestADB = Get-MailboxDatabase -Status | where {$_.name -like "adb0*"} | sort-object databasesize  | select -expandproperty name -first 1
$smallestMDB = Get-MailboxDatabase -Status | where {$_.name -like "db00*"} | sort-object databasesize  | select -expandproperty name -first 1

#Get all mailboxes
$MBX = Get-Mailbox -ResultSize Unlimited


#Old archive databases (scheduled for removal, pending IAM test)
$oldMove = $MBX | where {$_.archivedatabase -like "arkdb0*"} | select -expandproperty samaccountname
#Archive mailboxes located in normal mailbox databases
$archiveMove = $MBX| where {$_.archivedatabase -like "db00*"} | select -expandproperty samaccountname
#Normal mailboxes located in archive mailbox databases
$normalMove = $MBX| where {$_.database -like "adb0*"} | select -expandproperty samaccountname

#Move mailboxes and archive mailboxes
foreach ($mailbox in $oldMove) {Get-Mailbox $mailbox | New-MoveRequest -ArchiveOnly -ArchiveTargetDatabase $smallestADB}
foreach ($mailbox in $archiveMove) {Get-Mailbox $mailbox | New-MoveRequest -ArchiveOnly -ArchiveTargetDatabase $smallestADB}
foreach ($mailbox in $normalMove) {Get-Mailbox $mailbox | New-MoveRequest -PrimaryOnly -TargetDatabase $smallestMDB}