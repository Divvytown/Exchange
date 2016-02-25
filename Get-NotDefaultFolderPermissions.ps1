#get mailboxes
$mbx = Get-Mailbox -resultsize unlimited




#############################
#Identify mailboxes that have delegation or mailbox sharing
$mbxPermission = $mbx | Get-MailboxPermission | where {$_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false} | Select Identity,User,@{Name='Access Rights';Expression={[string]::join(', ', $_.AccessRights)}}
    #$calendarPermission = $mbx | Get-CalendarProcessing | select Identity,@{Name='ResourceDelegates';Expression={[string]::join(', ', $_.resourcedelegates)}}

$mbxpermission | export-csv -Encoding Default -Delimiter ';' -Path c:\temp\mbxPerm.csv -NoTypeInformation
    #$calendarPermission | export-csv -Encoding Default -Delimiter ';' -Path c:\temp\calPerm.csv -NoTypeInformation






#############################################
#get all folder permissions that are not default
$folderPermissions = @()
foreach ($user in $mbx) {

$MBXFolders = @()
$MBXFoldersCorr = New-Object System.Collections.ArrayList
$Permissions = @()
$MBX_tocheck = [string]$($user.SamAccountName)
$MBXFolders = Get-MailboxFolderStatistics $MBX_tocheck | select folderpath
foreach ($item in $MBXFolders) {
 $temp = $item.FolderPath
 $temp = $Temp.Replace("/","\")
 $MBXFoldersCorr.Add($temp) | out-null
}
foreach ($item in $MBXFoldersCorr) {
Try {
 $MailboxFolder = $MBX_tocheck + ":" + $item
 $Permissions += $(Get-MailboxFolderPermission $MailboxFolder -ErrorAction Stop | where {($_.user.displayname -ne 'Default') -and ($_.user.displayname -ne 'Anonymous') -and ($_.user.displayname -notlike '*S-1-5-21*') -and ($_.user.displayname -ne $($user.displayname))} | Select-Object FolderName,User,@{Name='Access Rights';Expression={[string]::join(', ', $_.AccessRights)}},@{Name='Identity';Expression={[string]$MBX_tocheck}})
 }
Catch {
 <#
 $ReturnedObj = New-Object PSObject
 $ReturnedObj | Add-Member NoteProperty -Name "FolderName" -Value $item
 $ReturnedObj | Add-Member NoteProperty -Name "User" -Value "*Not Applicable*"
 $ReturnedObj | Add-Member NoteProperty -Name "AccessRights" -Value "*Not Applicable*"
 $ReturnedObj | Add-Member NoteProperty -Name "Identity" -Value $MBX_tocheck
 $Permissions += $ReturnedObj
 #>
 Write-Verbose "Not applicable.."
 Continue
 }
}

$folderPermissions += $Permissions
}
$folderPermissions | export-csv -Encoding Default -Delimiter ';' -Path c:\temp\folderpermissions.csv -NoTypeInformation





########################################
#compare smtp,sip,upn
$export = @()
foreach ($user in $mbx){
$strSIP = $null
$user.emailaddresses | foreach {if($_.PrefixString -eq 'SIP'){$strSIP = $_.addressstring}}
$export += $user | select displayname,samaccountname, userprincipalname, primarysmtpaddress,@{Name='SIP';Expression={$strSIP}}
}
$export | export-csv -Encoding Default -Delimiter ';' -Path c:\temp\sipsmtpupn.csv -NoTypeInformation
