function Requirement.CMSiteValue {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Requirement
    )

    Process {
        $NewCMRequirementRuleCMSiteValue = @{
            InputObject  = (Get-CMGlobalCondition -Name 'Configuration Manager site')
            Site         = $Requirement.Site
            RuleOperator = $Requirement.RuleOperator
        }

        if ($Requirement.DisableWildcardHandling) {
            $NewCMRequirementRuleCMSiteValue.Add('DisableWildcardHandling', $true)
        }

        if ($Requirement.ForceWildcardHandling) {
            $NewCMRequirementRuleCMSiteValue.Add('ForceWildcardHandling', $true)
        }

        Write-Host ('[CMBuilder-Requirement.CMSiteValue] New-CMRequirementRuleCMSiteValue: {0}' -f ($NewCMRequirementRuleCMSiteValue | Out-String))
        $CMRequirementRuleCMSiteValue = New-CMRequirementRuleCMSiteValue @NewCMRequirementRuleCMSiteValue

        Write-Output $CMRequirementRuleCMSiteValue
    }
}