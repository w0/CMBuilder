function Requirement.Expression {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Requirement
    )

    Process {
        $GlobalCondition = Get-CMGlobalCondition -AsDcmSdkObject -Name $Requirement.Name

        if (-not ($GlobalCondition)) {
            Throw ('[CMBuilder-Requirement.Expression] GlobalCondition {0} not found! This should match the name displayname in the admin console.' -f $Requirement.Name)
        }

        if ($GlobalCondition.Rules) {
            Write-Host ('[CMBuilder-Requirement.Expression] Adding rules from {0}' -f $GlobalCondition.Name)
            Write-Output $GlobalCondition.Rules

        } else {
            Write-Host ('[CMBuilder-Requirement.Expression] Rules not found in "{0}". Verify this is an expression!' -f $GlobalCondition.Name)
        }
    }
}