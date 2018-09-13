# Get-User-Groups
Windows Server 2003 domain, get a user's group membership
This is a quick tool to get a user's group membership. I have a Windows Server 2003 Active Directory environment.

The required argument, "$NamePart" can be a last name. If there are more than one matching identites, the script fails.

The $ShowIdentity" arg is a boolean value that, when $True, shows the DistinguishedName property, which resolves to the full OU path in Active Directory.
