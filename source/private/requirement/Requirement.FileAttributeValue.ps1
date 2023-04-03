function Requirement.FileAttributeValue {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Requirement
    )

    Process {
        $NewCMRequirementRuleFileAttributeValue = @{
            InputObject = (Get-CMGlobalCondition -Name $Requirement.GlobalCondition)
        }

        if ($Requirement.DisableWildcardHandling) {
            $NewCMRequirementRuleFileAttributeValue.Add('DisableWildcardHandling', $true)
        }

        if ($Requirement.FileArchive) {
            $NewCMRequirementRuleFileAttributeValue.Add('FileArchive', $true)
        }

        if ($Requirement.FileCompressed) {
            $NewCMRequirementRuleFileAttributeValue.Add('FileCompressed', $true)
        }

        if ($Requirement.FileEncrypted) {
            $NewCMRequirementRuleFileAttributeValue.Add('FileEncrypted', $true)
        }

        if ($Requirement.FileHidden) {
            $NewCMRequirementRuleFileAttributeValue.Add('FileHidden', $true)
        }

        if ($Requirement.FileReadOnly) {
            $NewCMRequirementRuleFileAttributeValue.Add('FileReadOnly', $true)
        }

        if ($Requirement.FileSystem) {
            $NewCMRequirementRuleFileAttributeValue.Add('FileSystem', $true)
        }

        if ($Requirement.ForceWildcardHandling) {
            $NewCMRequirementRuleFileAttributeValue.Add('ForceWildcardHandling', $true)
        }

        Write-Host ('[CMBuilder-Requirement.FileAttributeValue] New-CMRequirementRuleFileAttributeValue: {0}' -f ($NewCMRequirementRuleFileAttributeValue | Out-String))
        $CMRequirementRuleFileAttributeValue = New-CMRequirementRuleFileAttributeValue @NewCMRequirementRuleFileAttributeValue

        Write-Output $CMRequirementRuleFileAttributeValue
    }
}
