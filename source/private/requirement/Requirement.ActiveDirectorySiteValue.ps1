function Requirement.ActiveDirectorySiteValue {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Requirement
    )

    Process {
        $NewCMRequirementRuleActiveDirectorySiteValue = @{
            InputObject  = (Get-CMGlobalCondition -Name 'Active Directory site')
            Site         = $Requirement.Site
            RuleOperator = $Requirement.RuleOperator
        }

        if ($Requirement.DisableWildcardHandling) {
            $NewCMRequirementRuleActiveDirectorySiteValue.Add('DisableWildcardHandling', $true)
        }

        if ($Requirement.ForceWildcardHandling) {
            $NewCMRequirementRuleActiveDirectorySiteValue.Add('ForceWildcardHandling', $true)
        }

        Write-Host ('[CMBuilder-Requirement.ActiveDirectorySiteValue] New-CMRequirementRuleActiveDirectorySiteValue: {0}' -f ($NewCMRequirementRuleActiveDirectorySiteValue | Out-String))
        $CMRequirementRuleActiveDirectorySiteValue = New-CMRequirementRuleActiveDirectorySiteValue @NewCMRequirementRuleActiveDirectorySiteValue

        Write-Output $CMRequirementRuleActiveDirectorySiteValue
    }
}
