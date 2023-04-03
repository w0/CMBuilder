function Deploy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        $NewCMApplication,

        [Parameter(Position = 1)]
        $OldCMApplication
    )

    Process {

        if (($OldCMApplication) -and ($CopyDeployment)) {
            # Filter out disabled and collections defined in the Configuration
            $CurrentDeployments = Get-CMApplicationDeployment -InputObject $OldCMApplication | Where-Object { ($_.Enabled -eq $true) -and ($_.CollectionName -notin $Configuration.Deploy.CollectionName) }

            if ($CurrentDeployments) {
                Write-Host ('[CMBuilder-Deploy.Copy] Copying previous deployment settings from: {0}' -f ($CurrentDeployments -join '; ') )
                Deploy.Copy -CMApplication $NewCMApplication -CurrentDeployments $CurrentDeployments
            }
        }

        if ($Configuration.Deploy) {
            Write-Host '[CMBuilder-Deploy.Configuration] Deploying to specified collections.'
            Deploy.Configuration -CMApplication $NewCMApplication
        }

    }
}
