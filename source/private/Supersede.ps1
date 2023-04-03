function Supersede {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        $NewCMApplication,

        [Parameter(Mandatory = $true, Position = 1)]
        $OldCMApplication
    )

    Process {
        if ($Configuration.DeploymentTypes.Count -gt 1) {
            foreach ($DeploymentType in $Configuration.DeploymentTypes) {
                $NewDeploymentType = Get-CMDeploymentType -InputObject $NewCMApplication -DeploymentTypeName $DeploymentType.Name
                $OldDeploymentType = Get-CMDeploymentType -InputObject $OldCMApplication -DeploymentTypeName $DeploymentType.Name

                if ($OldDeploymentType) {
                    $AddCMDeploymentTypeSupersedence = @{
                        SupersedingDeploymentType = $NewDeploymentType
                        SupersededDeploymentType  = $OldDeploymentType
                    }

                    if ($Configuration.SupersedeUninstall) {
                        Write-Host '[CMBuilder-Supersede] Supersede uninstall flag set'
                        $AddCMDeploymentTypeSupersedence.Add('IsUninstall', $true)
                    }

                    Write-Host ('[CMBuilder-Supersede] Add-CMDeploymentTypeSupersedence: {0}' -f ($AddCMDeploymentTypeSupersedence | Out-String))
                    Add-CMDeploymentTypeSupersedence @AddCMDeploymentTypeSupersedence

                } else {
                    Write-Host ('[CMBuilder-Supersede] Unable to find a Old DeploymentType to supersede. Possible new deploymenttype added.')
                }
            }
        } else {
            $NewDeploymentType = Get-CMDeploymentType -InputObject $NewCMApplication
            $OldDeploymentType = Get-CMDeploymentType -InputObject $OldCMApplication

            $AddCMDeploymentTypeSupersedence = @{
                SupersedingDeploymentType = $NewDeploymentType
                SupersededDeploymentType  = $OldDeploymentType
            }

            if ($Configuration.SupersedeUninstall) {
                Write-Host '[CMBuilder-Supersede] Supersede uninstall flag set'
                $AddCMDeploymentTypeSupersedence.Add('IsUninstall', $true)
            }

            Write-Host ('[CMBuilder-Supersede] Add-CMDeploymentTypeSupersedence: {0}' -f ($AddCMDeploymentTypeSupersedence | Out-String))
            Add-CMDeploymentTypeSupersedence @AddCMDeploymentTypeSupersedence
        }
    }
}