function Requirement.OperatingSystemLanguageValue {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Requirement
    )

    Process {
        $NewCMRequirementRuleOperatingSystemLanguageValue = @{
            InputObject  = (Get-CMGlobalCondition -Name 'Operating system language' | Where-Object PlatformType -eq $Requirement.PlatformType)
            RuleOperator = $Requirement.RuleOperator
            Culture      = foreach ($Culture in $Requirement.Culture) {
                [System.Globalization.CultureInfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures) | Where-Object Name -eq $Culture
            }
        }

        if ($Requirement.DisableWildcardHandling) {
            $NewCMRequirementRuleOperatingSystemLanguageValue.Add('DisableWildcardHandling', $true)
        }

        if ($Requirement.ForceWildcardHandling) {
            $NewCMRequirementRuleOperatingSystemLanguageValue.Add('ForceWildcardHandling', $true)
        }

        if ($Requirement.IsMobile) {
            $NewCMRequirementRuleOperatingSystemLanguageValue.Add('IsMobile', $true)
        }

        Write-Host ('[CMBuilder-Requirement.OperatingSystemLanguageValue] New-CMRequirementRuleOperatingSystemLanguageValue: {0}' -f ($NewCMRequirementRuleOperatingSystemLanguageValue | Out-String))
        $CMRequirementRuleOperatingSystemLanguageValue = New-CMRequirementRuleOperatingSystemLanguageValue @NewCMRequirementRuleOperatingSystemLanguageValue

        Write-Output $CMRequirementRuleOperatingSystemLanguageValue
    }
}