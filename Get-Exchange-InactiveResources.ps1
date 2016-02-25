#Enter OU path for where your resource mailboxes are located
$OU = "/Customer/Users/Exchange Resource Mailboxes"

#Get a list of all mailboxes in specified OU and mailboxes with Room og Equipment tag in recipientype
$mailboxes = get-mailbox * -resultsize unlimited | where {($_.OrganizationalUnit -eq "$env:USERDNSDOMAIN$OU") -or ($_.RecipientTypeDetails -eq 'RoomMailbox') -or ($_.RecipientTypeDetails -eq 'EquipmentMailbox')}
$date = get-date -format d

foreach ($mb in $mailboxes) {
    $newest = $oldest = $null
    $mb | Get-MailboxFolderStatistics -IncludeOldestAndNewestItems | %{
        if($_.NewestItemReceivedDate -and (!$newest -or $newest -lt $_.NewestItemReceivedDate.tolocaltime())){
            $newest = $_.NewestItemReceivedDate.tolocaltime()}
    }
	$diff = New-TimeSpan -Start $date -End $newest
    $obj = New-Object -TypeName psobject -Property @{
        DisplayName = $mb.displayname
        SMTPAddress = $mb.PrimarySMTPAddress.tostring()
        NewestItem = $newest
		InactiveDays = $diff.Days
		SamAccountName = $mb.SamAccountName
		Office = $mb.Office
		OrganizationalUnit = $mb.OrganizationalUnit
		RecipientTypeDetails = $mb.RecipientTypeDetails
		Alias = $mb.Alias


    } 
    [array]$export += $obj
}  $export | Export-Csv -Delimiter ';' -Encoding Default -path "InactiveResourceMailboxes-$(get-date -format s).csv"
