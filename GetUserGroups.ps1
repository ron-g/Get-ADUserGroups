<#
.SYNOPSIS
"GetUserGroups" gets a user's group membership from a Windows Server 2003 Active Directory environment. 

.DESCRIPTION
"GetUserGroups" gets a user's group membership from a Windows Server 2003 Active Directory environment. 

.PARAMETER NamePart
Can be the full name or part of the name. The Get-ADUser call uses the Filter arg with "Name -like ...".

.EXAMPLE
GetUserGroups -NamePart "doe"

Finds a user whose name contains "*Doe*"

.EXAMPLE
GetUserGroups -NamePart "John Doe"

Finds a user whose name contains "*John Doe*", which is more specific.

.NOTES

Tested from a Windows 10 powershell being run on a restricted user's session launched as domain admin.
#>

[CmdletBinding()]
param (
	[Parameter(Mandatory=$True)]
	[Alias('UserName')]
	[string]$NamePart
)

# Get the user's fully qualified identity from a/the domain server.
$Identity = Get-ADUser -Filter "Name -like '*$NamePart*'" -Properties * #; $Identity

# Generate a "friendly" name field with the human name and SAM/user name.
$FriendlyDisplayName = $Identity.name + " (" + $Identity.SamAccountName + ")"

# Generate a header for the output.
"`n" ; "=" * $FriendlyDisplayName.length * 2 ; " " * ($FriendlyDisplayName.length / 2) + $FriendlyDisplayName + " " * ($FriendlyDisplayName.length / 2) ; "=" * $FriendlyDisplayName.length * 2 ;

# Get the user's group membership, sorted by the group type (distribution group vs. security group, etc.)
Get-ADPrincipalGroupMembership -Identity $Identity | `
	Select-Object -Property GroupScope, name | `
		Sort-Object -Property GroupScope, name