function Requirement.OperatingSystemValue {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Requirement
    )

    Process {
        $NewCMRequirementRuleOperatingSystemValue = @{
            InputObject  = (Get-CMGlobalCondition -Name 'Operating System' | Where-Object PlatformType -EQ $Requirement.PlatformType)
            RuleOperator = $Requirement.RuleOperator
        }

        if ($Requirement.DisableWildcardHandling) {
            $NewCMRequirementRuleOperatingSystemValue.Add('DisableWildcardHandling', $true)
        }

        if ($Requirement.ForceWildcardHandling) {
            $NewCMRequirementRuleOperatingSystemValue.Add('ForceWildcardHandling', $true)
        }

        if ($Requirement.Platform) {
            $NewCMRequirementRuleOperatingSystemValue.Add('Platform', $Requirement.Platform)
        }

        if ($Requirement.PlatformString) {
            $NewCMRequirementRuleOperatingSystemValue.Add('PlatformString', $Requirement.Platform)
        }

        if ($Requirement.SelectFullPlatform) {
            $NewCMRequirementRuleOperatingSystemValue.Add('SelectFullPlatform', $Requirement.Platform)
        }

        Write-Host ('[CMBuilder-Requirement.OperatingSystemValue] New-CMRequirementRuleOperatingSystemValue: {0}' -f ($NewCMRequirementRuleOperatingSystemValue | Out-String))
        $CMRequirementRuleOperatingSystemValue = New-CMRequirementRuleOperatingSystemValue @NewCMRequirementRuleOperatingSystemValue

        Write-Output $CMRequirementRuleOperatingSystemValue
    }
}
