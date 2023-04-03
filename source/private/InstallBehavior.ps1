function InstallBehavior {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        $CMApplication,

        [Parameter(Mandatory = $true, Position = 1)]
        $DeploymentType,

        [Parameter(Mandatory = $true, Position = 2)]
        $InstallBehaviorRules
    )

    process {
        Write-Host '[CMBuilder-Install Behavior] Adding Install Behavior'

        $Application = Get-CMApplication -Name $CMApplication.LocalizedDisplayName | ConvertTo-CMApplication
        $DeploymentTypeIndex = $Application.DeploymentTypes.Title.IndexOf($DeploymentType.DeploymentTypeName)

        foreach ($Process in $InstallBehaviorRules) {
            Write-Host ('[CMBuilder-Install Behavior] Adding "{0}" to DeploymentType "{1}"' -f $Process.DisplayName, $DeploymentType.DeploymentTypeName)

            # Create the process detection
            $ProcessInfo = [Microsoft.ConfigurationManagement.ApplicationManagement.ProcessInformation]::new()
            $ProcessInfo.DisplayInfo.Add(@{'DisplayName' = $Process.DisplayName; Language = $NULL })
            $ProcessInfo.Name = $Process.Executable

            # Add the process to the DeploymentType
            $Application.DeploymentTypes[$DeploymentTypeIndex].Installer.InstallProcessDetection.ProcessList.Add($ProcessInfo)
        }

        Write-Host '[CMBuilder-Install Behavior] Commiting Changes'
        $Application = $Application | ConvertFrom-CMApplication
        $Application.Put()
    }
}