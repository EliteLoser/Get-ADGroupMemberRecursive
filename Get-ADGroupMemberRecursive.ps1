#requires -version 3
function Get-ADGroupMemberRecursive {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true)]
        [Alias("DistinguishedName", "Name", "SamAccountName")]
        [String]
        $Identity,
        [String[]]
        [Alias("Properties")]
        $Property = @("DistinguishedName", "Name", "SamAccountName", "DisplayName"),
        [Switch] $AsJSON)
    begin {
        Import-Module -Name ActiveDirectory -ErrorAction Stop -Verbose:$false
        $Groups = @{}
        function Get-ADGroupMemberInternal {
            param(
                [String] $Identity)
            foreach ($Member in @(Get-ADGroupMember -Identity $Identity)) {
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
            $GrandParentDN = (Get-ADGroup $Identity -ErrorAction SilentlyContinue).DistinguishedName
        }
        elseif ($_) {
            $GrandParentDN = (Get-ADGroup $_ -ErrorAction SilentlyContinue).DistinguishedName
        }
        $Groups[$GrandParentDN] = @()
        Get-ADGroupMemberInternal -Identity $GrandParentDN
    }
    end {
        if ($AsJson) {
            $Groups.GetEnumerator() | ForEach-Object {
                $Group = $_.Name
                $_.Value | Select-Object -Property @{ Name = "RootGroupDN"; Expression = { $GrandParentDN } }, *
            } | ConvertTo-Json
        }
        else {
            $Groups.GetEnumerator() | ForEach-Object {
                $Group = $_.Name
                $_.Value | Select-Object -Property @{ Name = "RootGroupDN"; Expression = { $GrandParentDN } }, *
            }
        }
        ## DEBUG ##
        Write-Verbose -Message "Exporting main data hash to `$Global:STGroupHashTemp."
        $Global:STGroupHashTemp = $Groups
    }
}
