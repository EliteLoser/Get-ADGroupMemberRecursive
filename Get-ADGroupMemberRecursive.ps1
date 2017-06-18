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
        $Credential = [System.Management.Automation.PSCredential]::Empty)
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
            foreach ($Member in @(Get-ADGroup -Identity $Identity -Propert Member @CredentialSplat | Select-Object -ExpandProperty Member | Get-ADObject -Propert $Property @CredentialSplat)) {
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
        $Groups.Values | ForEach-Object {
            $_ | Select-Object -Property *, @{ Name = "RootGroupDN"; Expression = { $GrandParentDN } }
        }
        ## DEBUG ##
        Write-Verbose -Message "Exporting main data hash to `$Global:STGroupHashTemp."
        $Global:STGroupHashTemp = $Groups
    }
}
