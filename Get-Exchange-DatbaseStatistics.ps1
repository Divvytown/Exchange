function Get-DatabaseStatistics {
    $Databases = Get-MailboxDatabase -Status
    foreach($Database in $Databases) {
        $DBSize = $Database.DatabaseSize
        $MBCount = @(Get-MailboxStatistics -Database $Database.Name).Count
        
        $MBAvg = Get-MailboxStatistics -Database $Database.Name | 
          %{$_.TotalItemSize.value.ToMb()} | 
            Measure-Object -Average            

        New-Object PSObject -Property @{
            Server = $Database.Server.Name
            DatabaseName = $Database.Name
            LastFullBackup = $Database.LastFullBackup
            MailboxCount = $MBCount
            "DatabaseSize (GB)" = $DBSize.ToGB()
            "AverageMailboxSize (MB)" = $MBAvg.Average
            "WhiteSpace (MB)" = $Database.AvailableNewMailboxSpace.ToMb()
        }
    }
}

<#
$statistics = Get-DatabaseStatistics
$mbxCountTreshold = 50

#check if any mdb has too many mailboxes compared to other databases
$mbxStat = $statistics | where {$_.databasename -like "DB*"}
foreach ($mbx in $mbxStat){ [int]$avgMBX += $($mbx.mailboxcount)/4 }
$mostMBX = $mbxStat | Sort-Object mailboxcount -Descending | select -first 1
if ($mostMBX.mailboxcount -gt ($avMBX + $mbxCountTreshold)){}


#check if any archive mdb has too many mailboxes compared to other databases
$archiveStat = $statistics | where {$_.databasename -like "ADB*"}

#>