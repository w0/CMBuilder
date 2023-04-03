function Requirement.InputTypeValue {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Requirement
    )

    Process {
        $NewCMRequirementRuleInputTypeValue = @{
            InputObject = (Get-CMGlobalCondition -Name 'Input Type')
            IsTouch     = $Requirement.IsTouch
        }

        Write-Host ('[CMBuilder-Requirement.InputTypeValue] New-CMRequirementRuleInputTypeValue: {0}' -f ($NewCMRequirementRuleInputTypeValue | Out-String))
        $CMRequirementRuleInputTypeValue = New-CMRequirementRuleInputTypeValue @NewCMRequirementRuleInputTypeValue

        Write-Output $CMRequirementRuleInputTypeValue
    }
}
