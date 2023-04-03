function Requirement.FreeDiskSpaceValue {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Requirement
    )

    Process {
        $NewCMRequirementRuleFreeDiskSpaceValue = @{
            InputObject     = (Get-CMGlobalCondition -Name 'Disk Space')
            PartitionOption = $Requirement.PartitionOption
            RuleOperator    = $Requirement.RuleOperator
            Value1          = $Requirement.Value1
        }

        if ($Requirement.DisableWildcardHandling) {
            $NewCMRequirementRuleFreeDiskSpaceValue.Add('DisableWildcardHandling', $true)
        }

        if ($Requirement.DriverLetter) {
            $NewCMRequirementRuleFreeDiskSpaceValue.Add('DriverLetter', $Requirement.DriverLetter)
        }

        if ($Requirement.ForceWildcardHandling) {
            $NewCMRequirementRuleFreeDiskSpaceValue.Add('ForceWildcardHandling', $true)
        }

        if ($Requirement.PartitionOption) {
            $NewCMRequirementRuleFreeDiskSpaceValue.Add('PartitionOption', $Requirement.PartitionOption)
        }

        if ($Requirement.Value2) {
            $NewCMRequirementRuleFreeDiskSpaceValue.Add('Value2', $Requirement.Value2)
        }

        Write-Host ('[CMBuilder-Requirement.FreeDiskSpaceValue] New-CMRequirementRuleFreeDiskSpaceValue: {0}' -f ($NewCMRequirementRuleFreeDiskSpaceValue | Out-String))
        $CMRequirementRuleFreeDiskSpaceValue = New-CMRequirementRuleFreeDiskSpaceValue @NewCMRequirementRuleFreeDiskSpaceValue

        Write-Output $CMRequirementRuleFreeDiskSpaceValue
    }
}
