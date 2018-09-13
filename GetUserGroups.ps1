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

==================================
         John Doe (jdoe)
==================================

 GroupScope name
 ---------- ----
DomainLocal Administrators
     Global Domain Users
     Global standin
  Universal staff
  Universal webabuse
  Universal notifications
  Universal Backups

.EXAMPLE
GetUserGroups -NamePart "John Doe"

Finds a user whose name contains "*John Doe*", which is more specific.

==================================
         John Doe (jdoe)
==================================

 GroupScope name
 ---------- ----
DomainLocal Administrators
     Global Domain Users
     Global standin
  Universal staff
  Universal webabuse
  Universal notifications
  Universal Backups

.EXAMPLE
GetUserGroups -NamePart "John Doe" -ShowIdentity $True

Find a user whose name contains "*John Doe*" and show the DistinguishedName property, making locating the user in dsa.msc easier.

CN=jdoe,CN=Users,DC=staff,DC=example,DC=com

==================================
         John Doe (jdoe)
==================================

 GroupScope name
 ---------- ----
DomainLocal Administrators
     Global Domain Users
     Global standin
  Universal staff
  Universal webabuse
  Universal notifications
  Universal Backups

.NOTES

Tested from a Windows 10 powershell being run on a restricted user's session launched as domain admin.

.INPUTS

A full name or name part. Must be uniqie enough to resolve to one AD account.

.OUTPUTS

A generic shared account:

CN=sampleshared,CN=Users,DC=staff,DC=example,DC=com

======================================================
              sampleshared (sampleshared)             
======================================================

 GroupScope name
 ---------- ----
DomainLocal dlg_sampledept
     Global Domain Users



Domain Admin:

CN=dadmin,CN=Users,DC=staff,DC=example,DC=com

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
	[Alias('UserName')]
	[string]$NamePart,
	
	[Parameter(Mandatory=$False)]
	[Alias('Identity')]
	[bool]$ShowIdentity = $False
)

# Get the user's fully qualified identity from a/the domain server.
$Identity = Get-ADUser -Filter "Name -like '*$NamePart*'" -Properties * 

# If $ShowIdentity is true, echo the DistinguishedName property so it can be found in dsa.msc
if ($ShowIdentity) {
	Write-Host $Identity.DistinguishedName
}

# Generate a "friendly" name field with the human name and SAM/user name.
$FriendlyDisplayName = $Identity.name + " (" + $Identity.SamAccountName + ")"

# Generate a header for the output.
"`n" + "=" * $FriendlyDisplayName.length * 2 + "`n" + `
	" " * ($FriendlyDisplayName.length / 2) + $FriendlyDisplayName + " " * ($FriendlyDisplayName.length / 2) + "`n" + `
	"=" * $FriendlyDisplayName.length * 2 ;

# Get the user's group membership, sorted by the group type (distribution group vs. security group, etc.)
Get-ADPrincipalGroupMembership -Identity $Identity | `
	Select-Object -Property GroupScope, name | `
		Sort-Object -Property GroupScope, name

