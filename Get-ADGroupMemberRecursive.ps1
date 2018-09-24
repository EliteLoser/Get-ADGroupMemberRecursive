#requires -version 2
function Get-ADGroupMemberRecursive {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true)]
        [Alias("DistinguishedName", "Name", "SamAccountName")]
            [String] $Identity,
        [Alias("Properties")]
            [String[]] $Property = @("DistinguishedName", "Name", "SamAccountName", "DisplayName"),
        $Credential = [System.Management.Automation.PSCredential]::Empty,
        [Switch] $TranslateForeignSecurityPrincipals)
    begin {
        Import-Module -Name ActiveDirectory -ErrorAction Stop -Verbose:$false
        if ($Credential.Username -match '\S') {
            $CredentialSplat = @{
                Credential = $Credential
            }
        }
        else {
            $CredentialSplat = @{}
        }
        $Groups = @{}
        function Get-ADGroupMemberInternal {
            param(
                [String] $Identity)
            # With Get-ADGroupMember there's a limit of 1000-5000 users by default. Worked around with this, supposedly.
            foreach ($Member in @(Get-ADGroup -Identity $Identity -Propert Member @CredentialSplat | 
              Select-Object -ExpandProperty Member | 
              Get-ADObject -Propert $Property @CredentialSplat)) {
                Write-Verbose -Message "[$($Member.DistinguishedName)] Processing ..."
                if ($Member.ObjectClass -eq 'Group') {
                    if ($Groups.ContainsKey($Member.DistinguishedName)) {
                        Write-Verbose -Message "[$($Member.DistinguishedName)] Already processed."
                        continue # explicit..
                    }
                    else {
                        Write-Verbose -Message "[$($Member.DistinguishedName)] Processing group. Parent group: $Identity."
                        $Groups[$Member.DistinguishedName] = @()
                        Get-ADGroupMemberInternal -Identity $Member.DistinguishedName #-ParentGroup $Member.DistinguishedName
                    }
                }
                else {
                    Write-Verbose -Message "[$($Member.DistinguishedName)] Adding non-group element to $Identity array."
                    if ($Groups.ContainsKey($Identity)) {
                        $Groups[$Identity] += @($Member |
                            Add-Member -MemberType NoteProperty -Name DirectParentGroupDN -Value $Identity -PassThru -Force |
                            Select-Object -Property @(@($Property) + @("DirectParentGroupDN")))
                    }
                }
            }
        }
    }
    process {
        if (Get-Variable -Name Identity -ErrorAction SilentlyContinue) {
            $GrandParentDN = (Get-ADGroup $Identity -ErrorAction SilentlyContinue @CredentialSplat).DistinguishedName
        }
        elseif ($_) {
            $GrandParentDN = (Get-ADGroup $_ -ErrorAction SilentlyContinue @CredentialSplat).DistinguishedName
        }
        $Groups[$GrandParentDN] = @()
        Get-ADGroupMemberInternal -Identity $GrandParentDN
    }
    end {
        $Groups.Values | ForEach-Object { # workaround
            if ($TranslateForeignSecurityPrincipals) {
                if ($_.DistinguishedName -like "*,CN=ForeignSecurityPrincipals,DC=*") {
                    $MyEAP = $ErrorActionPreference
                    $ErrorActionPreference = "Stop"
                    try {
                        $SamAccountNameForFSP = (New-Object -TypeName System.Security.Principal.SecurityIdentifier `
                            -ArgumentList $_.Name).Translate([System.Security.Principal.NTAccount]).Value
                    }
                    catch {
                        $SamAccounNameForFSP = ""
                    }
                    $ErrorActionPreference = $MyEAP
                    Add-Member -InputObject $_ -MemberType NoteProperty -Name RootGroupDN -Value $GrandParentDN
                    Add-Member -InputObject $_ -MemberType NoteProperty -Name SamAccountName -Value $SamAccountNameForFSP -Force
                    Add-Member -InputObject $_ -MemberType NoteProperty -Name Name -Value ($SamAccountNameForFSP -split "\\")[-1] -Force
                    $_ | Select-Object -Property *, @{ Name = "IsForeignSecurityPrincipal"; Expression = { $True } }
                }
                else {
                    $_ | Select-Object -Property *,
                        @{ Name = "RootGroupDN"; Expression = { $GrandParentDN } },
                        @{ Name = "IsForeignSecurityPrincipal"; Expression = { $False } }
                }
            }
            else {
                $_ | Select-Object -Property *,
                    @{ Name = "RootGroupDN"; Expression = { $GrandParentDN } },
                    @{ Name = "IsForeignSecurityPrincipal"; Expression = { $Null } } # hm.. three states ;/
            }
        }
        ## DEBUG ##
        #Write-Verbose -Message "Exporting main data hash to `$Global:STGroupHashTemp."
        #$Global:STGroupHashTemp = $Groups
    }
}
