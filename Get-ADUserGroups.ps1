<#
.SYNOPSIS
"Get-ADUserGroups" gets a user's group membership from a Windows Server 2003 Active Directory environment. 

.DESCRIPTION
"Get-ADUserGroups" gets a user's group membership from a Windows Server 2003 Active Directory environment. 

.PARAMETER UserName
Must be the SamAccountName.

.PARAMETER Clipboard
Boolean to put the output in the clipboard.

.EXAMPLE
Get-ADUserGroups -UserName "doe"

Finds a user whose SamAccountName is "doe".

==================================
         John Doe (jdoe)
==================================

 GroupScope name
 ---------- ----
DomainLocal Administrators
     Global Domain Users
  Universal ad
  Universal webabuse
  Universal notifications
  Universal Backups


.EXAMPLE
Get-ADUserGroups -UserName "doe" -ShowIdentity $True

Find a user whose SamAccountName is "doe" and show the DistinguishedName property, making locating the user in dsa.msc easier.

CN=jdoe,CN=Users,DC=ad,DC=example,DC=com

==================================
         John Doe (jdoe)
==================================

 GroupScope name
 ---------- ----
DomainLocal Administrators
     Global Domain Users
  Universal ad
  Universal webabuse
  Universal notifications
  Universal Backups

.NOTES

Tested from a Windows 10 powershell being run on a restricted user's session launched as domain admin.

.INPUTS

$Username

The complete SamAccountName.

$Clipboard

Boolean value to place the output in the clipboard.

.OUTPUTS

A generic shared account:

CN=sampleshared,CN=Users,DC=ad,DC=example,DC=com

======================================================
              sampleshared (sampleshared)             
======================================================

 GroupScope name
 ---------- ----
DomainLocal dlg_sampledept
     Global Domain Users



Domain Admin:

CN=dadmin,CN=Users,DC=ad,DC=example,DC=com

============================================
           Administrator (dadmin)
============================================

 GroupScope name
 ---------- ----
DomainLocal Administrators
     Global Domain Admins
     Global Domain Users
     Global Group Policy Creator Owners
  Universal Enterprise Admins


#>

[CmdletBinding()]
param (
	[Parameter(Mandatory=$True)]
	[Alias('NamePart')]
	[string]$UserName,
	
	[Parameter(Mandatory=$False)]
	[Alias('Identity')]
	[bool]$ShowIdentity = $False,

	[Parameter(Mandatory=$False)]
	[Alias('Clip')]
	[bool]$Clipboard = $True

)

$Data = ''
$BG='black'
$OK='green'
$ERROR='red'


# Get the user's fully qualified identity from a/the domain server.
$Identity = Get-ADUser -Properties "*" -Filter "SamAccountName -like '${UserName}'" #; $Identity

# If $ShowIdentity is true, echo the DistinguishedName property so it can be found in dsa.msc
if ($ShowIdentity) {
	# Write-Host $Identity.DistinguishedName
	$Data += "`n" + $Identity.DistinguishedName + "`n"
}

# Generate a "friendly" name field with the human name and SAM/user name.
$FriendlyDisplayName = $Identity.name + " (" + $Identity.SamAccountName + ")"

# Generate a header for the output.
$Data += `
	"`n" + "=" * $FriendlyDisplayName.length * 2 + "`n" + `
	" " * ($FriendlyDisplayName.length / 2) + $FriendlyDisplayName + " " * ($FriendlyDisplayName.length / 2) + "`n" + `
	"_" * $FriendlyDisplayName.length * 2 + "`n";

# Get the user's group membership, sorted by the group type (distribution group vs. security group, etc.)
$Data += `
	Get-ADPrincipalGroupMembership -Identity $Identity | `
		Select-Object -Property GroupScope, name | `
			Sort-Object -Property GroupScope, name | `
				ft | `
					Out-String

$Data += "`n" + "=" * $FriendlyDisplayName.length * 2 + "`n";
$Data

if($Clipboard) {
	$Data | Set-Clipboard
}