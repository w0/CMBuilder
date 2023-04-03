function Requirement.OUValue {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Requirement
    )

    Process {
        $NewCMRequirementRuleOUValue = @{
            InputObject        = (Get-CMGlobalCondition -Name 'Organizational unit (OU)')
            RuleOperator       = $Requirement.RuleOperator
            OrganizationalUnit = foreach ($OrganizationalUnit in $Requirement.OrganizationalUnit) {
                Write-Output ([hashtable] @{
                        OU             = $OrganizationalUnit.OU
                        IsIncludeSubOU = $OrganizationalUnit.IsIncludeSubOU
                    }
                )
            }
        }

        if ($Requirement.DisableWildcardHandling) {
            $NewCMRequirementRuleOUValue.Add('DisableWildcardHandling', $true)
        }

        if ($Requirement.ForceWildcardHandling) {
            $NewCMRequirementRuleOUValue.Add('ForceWildcardHandling', $true)
        }

        Write-Host ('[CMBuilder-Requirement.OUValue] New-CMRequirementRuleOUValue: {0}' -f ($NewCMRequirementRuleOUValue | Out-String))
        $CMRequirementRuleOUValue = New-CMRequirementRuleOUValue @NewCMRequirementRuleOUValue

        Write-Output $CMRequirementRuleOUValue
    }
}