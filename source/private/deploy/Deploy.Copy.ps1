function Deploy.Copy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        $CMApplication,

        [Parameter(Mandatory = $true, Position = 2)]
        $CurrentDeployments
    )

    Process {

        foreach ($Deployment in $CurrentDeployments) {
            $NewCMApplicationDeployment = @{
                InputObject                = $CMApplication
                ApprovalRequired           = $Deployment.RequireApproval
                CollectionID               = $Deployment.TargetCollectionID
                Comment                    = ('Deployment created by CMBuilder')
                DeployAction               = $Deployment.AssignmentName.Split('_')[-1]
                EnableMomAlert             = $Deployment.DisableMomAlerts
                EnableSoftDeadline         = $Deployment.SoftDeadlineEnabled
                GenerateScomAlertOnFailure = $Deployment.RaiseMomAlertsOnFailure
                OverrideServiceWindow      = $Deployment.OverrideServiceWindows
                PersistOnWriteFilterDevice = $Deployment.PersistOnWriteFilterDevices
                RebootOutsideServiceWindow = $Deployment.RebootOutsideOfServiceWindows
                SendWakeupPacket           = $Deployment.WoLEnabled
                TimeBaseOn                 = if ($Deployment.UseGMTTimes) { 'UTC' } else { 'LocalTime' }
                UpdateSupersedence         = $Deployment.UpdateSupersedence
                UserNotification           = if (($Deployment.NotifyUser -eq $true) -and ($Deployment.UserUIExperience -eq $true)) {
                                                    'DisplayAll'
                                                } elseif (($Deployment.NotifyUser -eq $false) -and ($Deployment.UserUIExperience -eq $true)) {
                                                    'DisplaySoftwareCenterOnly'
                                                } elseif (($Deployment.NotifyUser -eq $false) -and ($Deployment.UserUIExperience -eq $false)) {
                                                    'HideAll'
                                                }
            }

            switch ($Deployment.OfferTypeID) {
                0 { $NewCMApplicationDeployment.Add('DeployPurpose', 'Required') }
                2 { $NewCMApplicationDeployment.Add('DeployPurpose', 'Available')}
                3 { $NewCMApplicationDeployment.Add('Simulation', $true) }
                Default { Write-Error ('[CMBuilder-Deploy.Copy] Failed to determine DeployPurpose. Got OfferTypeID of {0}' -f $Deployment.OfferTypeID) }
            }

            if ($NewCMApplicationDeployment.DeployPurpose -eq 'Required') {
                $NewCMApplicationDeployment.Add('AvailableDateTime', (Get-Date -Hour 8 -Minute 0 -Second 0).AddDays((8 - ((Get-Date).DayOfWeek.value__)) % 7))
                $NewCMApplicationDeployment.Add('DeadlineDateTime', (Get-Date -Hour 8 -Minute 0 -Second 0).AddDays(((8 - ((Get-Date).DayOfWeek.value__)) % 7) + 7))
            }

            <#
                OfferFlags are stored as an UINT32 in the SMS_ApplicationAssignment WMI Class. This value is incremented by the value of each OfferFlag turned on.
                By enumerating over the available flags we find by name which are turned on.
            #>
            $OfferFlags = [enum]::GetValues([Microsoft.ConfigurationManagement.ManagementProvider.OfferFlags]) | Where-Object { $_.value__ -band $Deployment.OfferFlags }

            Write-Output ('[CMBuilder-Deploy.Copy] The following OfferFlags were enumerated: {0}' -f ($OfferFlags -join ' '))

            switch ($OfferFlags) {
                'Predeploy' { $NewCMApplicationDeployment.Add('PreDeploy', $true) }
                #'OnDemand'  { }
                'EnableProcessTermination' { $NewCMApplicationDeployment.Add('AutoCloseExecutable', $true) }
                'AllowUsersToRepairApp' { $NewCMApplicationDeployment.Add('AllowRepairApp', $true) }
                #'RelativeSchedule' { }
                'HighImpactDeployment' { $NewCMApplicationDeployment.Add('ReplaceToastNotificationWithDialog', $true) }
                #'ImplicitUninstall' { }
                Default { }
            }

            Write-Host ('[CMBuilder-Deploy.Copy] New-CMApplicationDeployment: {0}' -f ($NewCMApplicationDeployment | Out-String))
            New-CMApplicationDeployment @NewCMApplicationDeployment

            if (Get-Variable -Name 'NewDeployments' -Scope 'Global' -ErrorAction SilentlyContinue) {
                Write-Host '[CMBuilder-Deploy.Copy] NewDeployments variable exists. Adding some info...'
                $NewDeployments.Add([PSCustomObject] @{
                    CollectionName = $Deployment.CollectionName
                    Action         = $NewCMApplicationDeployment.DeployPurpose
                }) | Out-Null
            }

        }
    }
}