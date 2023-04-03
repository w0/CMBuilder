function Requirement.Existential {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Requirement
    )

    Process {
        $NewCMRequirementRuleExistential = @{
            InputObject = (Get-CMGlobalCondition -Name $Requirement.GlobalCondition)
            Existential = $Requirement.Existential
        }

        if ($Requirement.DisableWildcardHandling) {
            $NewCMRequirementRuleExistential.Add('DisableWildcardHandling', $true)
        }

        if ($Requirement.ForceWildcardHandling) {
            $NewCMRequirementRuleExistential.Add('ForceWildcardHandling', $true)
        }

        Write-Host ('[CMBuilder-Requirement.Existential] New-CMRequirementRuleExistential: {0}' -f ($NewCMRequirementRuleExistential | Out-String))
        $CMRequirementRuleExistential = New-CMRequirementRuleExistential @NewCMRequirementRuleExistential

        Write-Output $CMRequirementRuleExistential
    }
}
