function Distribute {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlResultObject]
        $CMApplication
    )

    foreach ($DistributionPoint in $DistributionPoints) {
        $StartCMContentDistribution = @{
            InputObject           = $CMApplication
            DistributionPointName = $DistributionPoint
        }

        Write-Host ('[CMBuilder-Distribute] Start-CMContentDistribution: {0}' -f ($StartCMContentDistribution | Out-String))
        Start-CMContentDistribution @StartCMContentDistribution
    }

    foreach ($DistributionPointGroup in $DistributionPointGroups) {
        $StartCMContentDistribution = @{
            InputObject                = $CMApplication
            DistributionPointGroupName = $DistributionPointGroup
        }

        Write-Host ('[CMBuilder-Distribute] Start-CMContentDistribution: {0}' -f ($StartCMContentDistribution | Out-String))

        Start-CMContentDistribution @StartCMContentDistribution
    }
}
