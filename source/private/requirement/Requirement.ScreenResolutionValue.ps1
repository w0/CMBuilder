function Requirement.ScreenResolutionValue {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Requirement
    )

    Process {
        $NewCMRequirementRuleScreenResolutionValue = @{
            InputObject      = (Get-CMGlobalCondition -Name 'Screen resolution')
            ScreenResolution = $Requirement.ScreenResolution
        }

        if ($Requirement.DisableWildcardHandling) {
            $NewCMRequirementRuleScreenResolutionValue.Add('DisableWildcardHandling', $true)
        }

        if ($Requirement.ForceWildcardHandling) {
            $NewCMRequirementRuleScreenResolutionValue.Add('ForceWildcardHandling', $true)
        }

        Write-Host ('[CMBuilder-Requirement.ScreenResolutionValue] New-CMRequirementRuleScreenResolutionValue: {0}' -f ($NewCMRequirementRuleScreenResolutionValue | Out-String))
        $CMRequirementRuleScreenResolutionValue = New-CMRequirementRuleScreenResolutionValue @NewCMRequirementRuleScreenResolutionValue

        Write-Output $CMRequirementRuleScreenResolutionValue
    }
}