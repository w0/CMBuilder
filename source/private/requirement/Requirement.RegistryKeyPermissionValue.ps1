function Requirement.RegistryKeyPermissionValue {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Requirement
    )

    Process {
        $NewCMRequirementRuleRegistryKeyPermissionValue = @{
            InputObject  = (Get-CMGlobalCondition -Name $Requirement.GlobalCondition)
            ControlEntry = foreach ($Entry in $Requirement.ControlEntry) {
                $NewCMRegistryAccessControlEntry = @{
                    GroupOrUserName = $Entry.GroupOrUserName
                    AccessOption    = $Entry.AccessOption
                    Permission      = $Entry.Permission
                }
                New-CMRegistryAccessControlEntry @NewCMRegistryAccessControlEntry
            }
        }

        if ($Requirement.DisableWildcardHandling) {
            $NewCMRequirementRuleRegistryKeyPermissionValue.Add('DisableWildcardHandling', $true)
        }

        if ($Requirement.Exclusive) {
            $NewCMRequirementRuleRegistryKeyPermissionValue.Add('Exclusive', $true)
        }

        if ($Requirement.ForceWildcardHandling) {
            $NewCMRequirementRuleRegistryKeyPermissionValue.Add('ForceWildcardHandling', $true)
        }

        Write-Host ('[CMBuilder-Requirement.RegistryKeyPermissionValue] New-NewCMRequirementRuleRegistryKeyPermissionValue: {0}' -f ($NewCMRequirementRuleRegistryKeyPermissionValue | Out-String))
        $CMRequirementRuleRegistryKeyPermissionValue = New-CMRequirementRuleRegistryKeyPermissionValue @NewCMRequirementRuleRegistryKeyPermissionValue

        Write-Output $CMRequirementRuleRegistryKeyPermissionValue
    }
}