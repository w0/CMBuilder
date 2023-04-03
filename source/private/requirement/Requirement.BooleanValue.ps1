function Requirement.BooleanValue {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Requirement
    )

    Process {
        $NewCMRequirementRuleBooleanValue = @{
            InputObject = (Get-CMGlobalCondition -Name $Requirement.GlobalCondition)
            Value       = $Requirement.Value
        }

        Write-Host ('[CMBuilder-Requirement.BooleanValue] New-CMRequirementRuleBooleanValue: {0}' -f ($NewCMRequirementRuleBooleanValue | Out-String))
        $CMRequirementRuleBooleanValue = New-CMRequirementRuleBooleanValue @NewCMRequirementRuleBooleanValue

        Write-Output $CMRequirementRuleBooleanValue
    }

}