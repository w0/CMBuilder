function Requirement.DeviceOwnershipValue {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Requirement
    )

    Process {
        $NewCMRequirementRuleDeviceOwnershipValue = @{
            InputObject     = (Get-CMGlobalCondition -Name 'Ownership' | Where-Object CI_UniqueID -Match "Device_Ownership$($Requirement.DeviceType)`$")
            OwnershipOption = $Requirement.OwnershipOption
            RuleOperator    = $Requirement.RuleOperator
        }

        if ($Requirement.DisableWildcardHandling) {
            $NewCMRequirementRuleDeviceOwnershipValue.Add('DisableWildcardHandling', $true)
        }

        if ($Requirement.ForceWildcardHandling) {
            $NewCMRequirementRuleDeviceOwnershipValue.Add('ForceWildcardHandling', $true)
        }

        Write-Host ('[CMBuilder-Requirement.DeviceOwnershipValue] New-CMRequirementRuleDeviceOwnershipValue: {0}' -f ($NewCMRequirementRuleDeviceOwnershipValue | Out-String))
        $CMRequirementRuleDeviceOwnershipValue = New-CMRequirementRuleDeviceOwnershipValue @NewCMRequirementRuleDeviceOwnershipValue

        Write-Output $CMRequirementRuleDeviceOwnershipValue
    }
}