function Requirement.CommonValue {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Requirement
    )

    Process {
        $NewCMRequirementRuleCommonValue = @{
            InputObject  = (Get-CMGlobalCondition -Name $Requirement.GlobalCondition)
            Value1       = $Requirement.Value1
            RuleOperator = $Requirement.RuleOperator
        }

        if ($Requirement.DisableWildcardHandling) {
            $NewCMRequirementRuleCommonValue.Add('DisableWildcardHandling', $true)
        }

        if ($Requirement.ForceWildcardHandling) {
            $NewCMRequirementRuleCommonValue.Add('ForceWildcardHandling', $true)
        }

        if ($Requirement.PropertyForAssembly) {
            $NewCMRequirementRuleCommonValue.Add('PropertyForAssembly', $Requirement.PropertyForAssembly)
        }

        if ($Requirement.PropertyForFileFolder) {
            $NewCMRequirementRuleCommonValue.Add('PropertyForFileFolder', $Requirement.PropertyForFileFolder)
        }

        if ($Requirement.Value2) {
            $NewCMRequirementRuleCommonValue.Add('Value2', $Requirement.Value2)
        }

        Write-Host ('[CMBuilder-Requirement.CommonValue] New-CMRequirementRuleCommonValue: {0}' -f ($NewCMRequirementRuleCommonValue | Out-String))
        $CMRequirementRuleCommonValue = New-CMRequirementRuleCommonValue @NewCMRequirementRuleCommonValue

        Write-Output $CMRequirementRuleCommonValue
    }
}
