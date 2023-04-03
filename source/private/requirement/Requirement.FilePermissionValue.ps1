function Requirement.FilePermissionValue {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Requirement
    )

    Process {
        $NewCMRequirementRuleFilePermissionValue = @{
            InputObject  = (Get-CMGlobalCondition -Name $Requirement.GlobalCondition)
            ControlEntry = foreach ($Entry in $Requirement.ControlEntry) {
                $NewCMFileSystemAccessControlEntry = @{
                    GroupOrUserName = $Entry.GroupOrUserName
                    AccessOption    = $Entry.AccessOption
                    Permission      = $Entry.Permission
                }
                New-CMFileSystemAccessControlEntry @NewCMFileSystemAccessControlEntry
            }
        }

        if ($Requirement.DisableWildcardHandling) {
            $NewCMRequirementRuleFilePermissionValue.Add('DisableWildcardHandling', $true)
        }

        if ($Requirement.Exclusive) {
            $NewCMRequirementRuleFilePermissionValue.Add('Exclusive', $true)
        }

        if ($Requirement.ForceWildcardHandling) {
            $NewCMRequirementRuleFilePermissionValue.Add('ForceWildcardHandling', $true)
        }

        Write-Host ('[CMBuilder-Requirement.FilePermissionValue] New-CMRequirementRuleFilePermissionValue: {0}' -f ($NewCMRequirementRuleFilePermissionValue | Out-String))
        $CMRequirementRuleFilePermissionValue = New-CMRequirementRuleFilePermissionValue @NewCMRequirementRuleFilePermissionValue

        Write-Output $CMRequirementRuleFilePermissionValue
    }
}
