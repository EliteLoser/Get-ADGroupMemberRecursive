# Get-ADGroupMemberRecursive
Get AD group members recursively, tagged with root group DN and direct parent group DN.
Not completely polished, but most of the basics are here.

```powershell
PS C:\temp> Get-ADGroup 'TestGroupB' | Get-ADGroupMemberRecursive

RootGroupDN         : CN=TestGroupB,OU=Groups,OU=TestOU,DC=whatever,DC=local
DistinguishedName   : CN=testuser0300,OU=TestUsers,OU=TestOU,DC=whatever,DC=local
Name                : testuser0300
SamAccountName      : testuser0300
DisplayName         : 
DirectParentGroupDN : CN=TestGroupB,OU=Groups,OU=TestOU,DC=whatever,DC=local

RootGroupDN         : CN=TestGroupB,OU=Groups,OU=TestOU,DC=whatever,DC=local
DistinguishedName   : CN=testuser0301,OU=TestUsers,OU=TestOU,DC=whatever,DC=local
Name                : testuser0301
SamAccountName      : testuser0301
DisplayName         : 
DirectParentGroupDN : CN=TestGroupB,OU=Groups,OU=TestOU,DC=whatever,DC=local


PS C:\temp> 'TestGroupB' | Get-ADGroupMemberRecursive


RootGroupDN         : CN=TestGroupB,OU=Groups,OU=TestOU,DC=whatever,DC=local
DistinguishedName   : CN=testuser0300,OU=TestUsers,OU=TestOU,DC=whatever,DC=local
Name                : testuser0300
SamAccountName      : testuser0300
DisplayName         : 
DirectParentGroupDN : CN=TestGroupB,OU=Groups,OU=TestOU,DC=whatever,DC=local

RootGroupDN         : CN=TestGroupB,OU=Groups,OU=TestOU,DC=whatever,DC=local
DistinguishedName   : CN=testuser0301,OU=TestUsers,OU=TestOU,DC=whatever,DC=local
Name                : testuser0301
SamAccountName      : testuser0301
DisplayName         : 
DirectParentGroupDN : CN=TestGroupB,OU=Groups,OU=TestOU,DC=whatever,DC=local
```

Example with nested groups.

```powershell
PS C:\temp> Get-ADGroupMemberRecursive -Identity TestGroupA


RootGroupDN         : CN=TestGroupA,OU=Groups,OU=TestOU,DC=whatever,DC=local
DistinguishedName   : CN=testuser0001,OU=TestUsers,OU=TestOU,DC=whatever,DC=local
Name                : testuser0001
SamAccountName      : testuser0001
DisplayName         : 
DirectParentGroupDN : CN=TestGroupE,OU=Groups,OU=TestOU,DC=whatever,DC=local

RootGroupDN         : CN=TestGroupA,OU=Groups,OU=TestOU,DC=whatever,DC=local
DistinguishedName   : CN=testuser0002,OU=TestUsers,OU=TestOU,DC=whatever,DC=local
Name                : testuser0002
SamAccountName      : testuser0002
DisplayName         : 
DirectParentGroupDN : CN=TestGroupE,OU=Groups,OU=TestOU,DC=whatever,DC=local

RootGroupDN         : CN=TestGroupA,OU=Groups,OU=TestOU,DC=whatever,DC=local
DistinguishedName   : CN=testuser0300,OU=TestUsers,OU=TestOU,DC=whatever,DC=local
Name                : testuser0300
SamAccountName      : testuser0300
DisplayName         : 
DirectParentGroupDN : CN=TestGroupB,OU=Groups,OU=TestOU,DC=whatever,DC=local

RootGroupDN         : CN=TestGroupA,OU=Groups,OU=TestOU,DC=whatever,DC=local
DistinguishedName   : CN=testuser0301,OU=TestUsers,OU=TestOU,DC=whatever,DC=local
Name                : testuser0301
SamAccountName      : testuser0301
DisplayName         : 
DirectParentGroupDN : CN=TestGroupB,OU=Groups,OU=TestOU,DC=whatever,DC=local

RootGroupDN         : CN=TestGroupA,OU=Groups,OU=TestOU,DC=whatever,DC=local
DistinguishedName   : CN=testuser0100,OU=TestUsers,OU=TestOU,DC=whatever,DC=local
Name                : testuser0100
SamAccountName      : testuser0100
DisplayName         : 
DirectParentGroupDN : CN=TestGroupA,OU=Groups,OU=TestOU,DC=whatever,DC=local

RootGroupDN         : CN=TestGroupA,OU=Groups,OU=TestOU,DC=whatever,DC=local
DistinguishedName   : CN=testuser0101,OU=TestUsers,OU=TestOU,DC=whatever,DC=local
Name                : testuser0101
SamAccountName      : testuser0101
DisplayName         : 
DirectParentGroupDN : CN=TestGroupA,OU=Groups,OU=TestOU,DC=whatever,DC=local

RootGroupDN         : CN=TestGroupA,OU=Groups,OU=TestOU,DC=whatever,DC=local
DistinguishedName   : CN=testuser0200,OU=TestUsers,OU=TestOU,DC=whatever,DC=local
Name                : testuser0200
SamAccountName      : testuser0200
DisplayName         : 
DirectParentGroupDN : CN=TestGroupC,OU=Groups,OU=TestOU,DC=whatever,DC=local

RootGroupDN         : CN=TestGroupA,OU=Groups,OU=TestOU,DC=whatever,DC=local
DistinguishedName   : CN=testuser0201,OU=TestUsers,OU=TestOU,DC=whatever,DC=local
Name                : testuser0201
SamAccountName      : testuser0201
DisplayName         : 
DirectParentGroupDN : CN=TestGroupC,OU=Groups,OU=TestOU,DC=whatever,DC=local
```

