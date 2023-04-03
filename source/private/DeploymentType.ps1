<#

    .SYNOPSIS

        Create an SCCM Application

    .DESCRIPTION

        With a provided (required) configuration file, we can automatically create applications in SCCM, superseeding previous versions

#>

function DeploymentType {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true, Position = 0)]
        $CMApplication
    )

    Process {
        foreach ($DeploymentType in $Configuration.DeploymentTypes) {
            Write-Host '[CMBuilder-Deployment Type] Creating Deployment Type'

            $AddCMScriptDeploymentType = @{
                DeploymentTypeName       = $DeploymentType.Name
                InputObject              = $CMApplication
                Force                    = $true
                InstallCommand           = $DeploymentType.InstallCommand
                InstallationBehaviorType = if ($DeploymentType.InstallationBehaviorType) {
                    $DeploymentType.InstallationBehaviorType
                } else {
                    'InstallForSystem'
                }
                LogonRequirementType     = if ($DeploymentType.LogonRequirementType) {
                    $DeploymentType.LogonRequirementType
                } else {
                    'WhetherOrNotUserLoggedOn'
                }
                UserInteractionMode      = if ($DeploymentType.UserInteractionMode) {
                    $DeploymentType.UserInteractionMode
                } else {
                    'Hidden'
                }
            }

            if ($DeploymentType.Detection) {
                $AddCMScriptDeploymentType.Add('AddDetectionClause', (Detection $DeploymentType.Detection))
            } elseif ($DeploymentType.DetectionScript) {
                $AddCMScriptDeploymentType.Add('ScriptFile', $DeploymentType.DetectionScript)

                switch -regex ($DeploymentType.DetectionScript) {
                    '(?i)(\.ps1$)' { $AddCMScriptDeploymentType.Add('ScriptLanguage', 'PowerShell'); break}
                    '(?i)(\.vbs$)' { $AddCMScriptDeploymentType.Add('ScriptLanguage', 'VBScript'); break}
                     '(?i)(\.js$)' { $AddCMScriptDeploymentType.Add('ScriptLanguage', 'JavaScript'); break}
                           default { Throw 'Unable to match detection script file to language. '}
                }

            } else {
                Throw 'DeploymentType does not contain Detection or ScriptDetection! Failed to create the DeploymentType!'
            }

            if ($DeploymentType.ContentLocation) {
                $AddCMScriptDeploymentType.Add('ContentLocation', $DeploymentType.ContentLocation)
            } else {   
                $AddCMScriptDeploymentType.Add('ContentLocation', (Join-Path $ContentShare ('{0}\{1}\{2}' -f $Configuration.Publisher, $Configuration.Name, $Script:Version)))
            }

            if ($DeploymentType.CacheContent) {
                $AddCMScriptDeploymentType.Add('CacheContent', $DeploymentType.CacheContent)
            }

            if ($DeploymentType.ContentFallback) {
                $AddCMScriptDeploymentType.Add('ContentFallback', $DeploymentType.ContentFallback)
            }

            if ($DeploymentType.DetectionClauseConnector) {
                $AddCMScriptDeploymentType.Add('DetectionClauseConnector', $DeploymentType.DetectionClauseConnector)
            }

            if ($DeploymentType.EnableBranchCache) {
                $AddCMScriptDeploymentType.Add('EnableBranchCache', $DeploymentType.EnableBranchCache)
            }

            if ($DeploymentType.EstimatedRuntimeMins) {
                $AddCMScriptDeploymentType.Add('EstimatedRuntimeMins', $DeploymentType.EstimatedRuntimeMins)
            }

            if ($DeploymentType.Force32Bit) {
                $AddCMScriptDeploymentType.Add('Force32Bit', $DeploymentType.Force32Bit)
            }

            if ($DeploymentType.GroupDetectionClauses) {
                $AddCMScriptDeploymentType.Add('GroupDetectionClauses', $DeploymentType.GroupDetectionClauses)
            }

            if ($DeploymentType.InstallWorkingDirectory) {
                $AddCMScriptDeploymentType.Add('InstallWorkingDirectory', $DeploymentType.InstallWorkingDirectory)
            }

            if ($DeploymentType.LogonRequirementType) {
                $AddCMScriptDeploymentType.Add('LogonRequirementType', $DeploymentType.LogonRequirementType)
            }

            if ($DeploymentType.MaximumRuntimeMins) {
                $AddCMScriptDeploymentType.Add('MaximumRuntimeMins', $DeploymentType.MaximumRuntimeMins)
            }

            if ($DeploymentType.RebootBehavior) {
                $AddCMScriptDeploymentType.Add('RebootBehavior', $DeploymentType.RebootBehavior)
            }

            if ($DeploymentType.RepairCommand) {
                $AddCMScriptDeploymentType.Add('RepairCommand', $DeploymentType.RepairCommand)
            }

            if ($DeploymentType.RepairWorkingDirectory) {
                $AddCMScriptDeploymentType.Add('RepairWorkingDirectory', $DeploymentType.RepairWorkingDirectory)
            }

            if ($DeploymentType.RequireUserInteraction) {
                $AddCMScriptDeploymentType.Add('RequireUserInteraction', $DeploymentType.RequireUserInteraction)
            }

            if ($DeploymentType.SlowNetworkDeploymentMode) {
                $AddCMScriptDeploymentType.Add('SlowNetworkDeploymentMode', $DeploymentType.SlowNetworkDeploymentMode)
            }

            if ($DeploymentType.SourceUpdateProductCode) {
                $AddCMScriptDeploymentType.Add('SourceUpdateProductCode', $DeploymentType.SourceUpdateProductCode)
            }

            if ($DeploymentType.UninstallContentLocation) {
                $AddCMScriptDeploymentType.Add('UninstallContentLocation', $DeploymentType.UninstallContentLocation)
            }

            if ($DeploymentType.UninstallOption) {
                $AddCMScriptDeploymentType.Add('UninstallOption', $DeploymentType.UninstallOption)
            }

            if ($DeploymentType.UninstallWorkingDirectory) {
                $AddCMScriptDeploymentType.Add('UninstallWorkingDirectory', $DeploymentType.UninstallWorkingDirectory)
            }

            if ($DeploymentType.AddRequirement) {
                $AddCMScriptDeploymentType.Add('AddRequirement', (Requirement $DeploymentType.AddRequirement))
            }

            if ($DeploymentType.RemoveLanguage) {
                $AddCMScriptDeploymentType.Add('RemoveLanguage', $DeploymentType.RemoveLanguage)
            }

            if ($DeploymentType.RemoveRequirement) {
                $AddCMScriptDeploymentType.Add('RemoveRequirement', $DeploymentType.RemoveRequirement)
            }

            if ($DeploymentType.AddLanguage) {
                $AddCMScriptDeploymentType.Add('AddLanguage', $DeploymentType.AddLanguage)
            }

            if ($DeploymentType.Comment) {
                $AddCMScriptDeploymentType.Add('Comment', $DeploymentType.Comment)
            }

            if ($DeploymentType.UninstallCommand) {
                $AddCMScriptDeploymentType.Add('UninstallCommand', $DeploymentType.UninstallCommand)
            }

            Write-Host ('[CMBuilder-Deployment Type] Add-CMScriptDeploymentType: {0}' -f ($AddCMScriptDeploymentType | Out-String))
            $NewDeploymentType = Add-CMScriptDeploymentType @AddCMScriptDeploymentType

            if ($DeploymentType.InstallBehavior) {
                InstallBehavior -CMApplication $CMApplication -DeploymentType $NewDeploymentType -InstallBehaviorRules $DeploymentType.InstallBehavior
            }
        }
    }
}
