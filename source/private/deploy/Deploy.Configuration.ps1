function Deploy.Configuration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        $CMApplication
    )

    Process {

        foreach ($Deployment in $Configuration.Deploy) {
            if (-not ($Collection = Get-CMDeviceCollection -Name $Deployment.CollectionName )) {
                Write-Verbose ('[CMBuilder-Deploy.Configuration] Creating collection: {0}' -f $Deployment.CollectionName)
                $Collection = Collection -CollectionName $Deployment.CollectionName -LimitingCollectionName $Deployment.LimitingCollectionName -SitePath $CollectionPath
            }

            Write-Host ('[CMBuilder-Deploy.Configuration] Deploying to collection: {0}' -f $Collection.Name)

            $NewCMApplicationDeployment = @{
                InputObject   = $CMApplication
                Collection    = $Collection
                DeployAction  = if ($Deployment.DeployAction) { $Deployment.DeployAction } else { 'Install' }
                DeployPurpose = if ($Deployment.DeployPurpose) { $Deployment.DeployPurpose } else { 'Required' }
                TimeBaseOn    = 'LocalTime'
            }

            if ($Deployment.AppCatalog) {
                $NewCMApplicationDeployment.Add('AppCatalog', $Deployment.AppCatalog)
            }

            <#
                Applies to version 2002 and later. Use this parameter to configure the repair application option when creating a deployment for an application
            #>
            if ($Deployment.AllowRepairApp) {
                $NewCMApplicationDeployment.Add('AllowRepairApp', $Deployment.AllowRepairApp)
            }

            <#
                If you set this parameter to $true, an administrator must approve a request for this application on the device.
            #>
            if ($Deployment.ApprovalRequired) {
                $NewCMApplicationDeployment.Add('ApprovalRequired', $Deployment.ApprovalRequired)
            }

            <#
                Starting in version 2107, set this parameter to $true to enable the application deployment setting for install behaviors.

                Then use the Add-CMDeploymentTypeInstallBehavior cmdlet to add an executable file to check isn't running for the install to succeed.
            #>
            if ($Deployment.AutoCloseExecutable) {
                $NewCMApplicationDeployment.Add('AutoCloseExecutable', $Deployment.AutoCloseExecutable)
            }

            <#
                Specify a DateTime object for when this deployment is available. To get this object, use the Get-Date built-in cmdlet.

                Use DeadlineDateTime to specify the deployment assignment, or deadline
            #>
            if ($NewCMApplicationDeployment.DeployPurpose -eq 'Required') {
                if ($Deployment.ImmediateDeployment) {
                    # Become available right now
                    $NewCMApplicationDeployment.Add('AvailableDateTime', (Get-Date))
                } else {
                    # Become available at 8AM Monday morning
                    $NewCMApplicationDeployment.Add('AvailableDateTime', (Get-Date -Hour 8 -Minute 0 -Second 0).AddDays((8 - ((Get-Date).DayOfWeek.value__)) % 7))
                }
            }

            <#
                Specify an optional comment for this deployment.
            #>
            if ($Deployment.Comment) {
                $NewCMApplicationDeployment.Add('Comment', $Deployment.Comment)
            }

            <#
                Specify a DateTime object for when this deployment is assigned, also known as the deadline. To get this object, use the Get-Date built-in cmdlet.

                Use -AvailableDateTime to specify when the deployment is available
            #>
            if ($NewCMApplicationDeployment.DeployPurpose -eq 'Required') {
                if ($Deployment.ImmediateDeployment) {
                    # 1 week deadline
                    $NewCMApplicationDeployment.Add('DeadlineDateTime', (Get-Date).AddDays(7))
                } else {
                    # 8AM next Monday morning
                    $NewCMApplicationDeployment.Add('DeadlineDateTime', (Get-Date -Hour 8 -Minute 0 -Second 0).AddDays(((8 - ((Get-Date).DayOfWeek.value__)) % 7) + 7))
                }
            }

            <#
                Set this parameter to $true to enable delayed enforcement.
            #>
            if ($NewCMApplicationDeployment.DeployPurpose -eq 'Required') {
                if (-not ($Deployment.ImmediateDeployment)) {
                    $NewCMApplicationDeployment.Add('EnableSoftDeadline', $true)
                }
            }

            <#
                Specifies the percentage of failed application installation that causes an alert. Specify an integer from 1 through 100. To enable this alert, set the CreatAlertBaseOnPercentFailure parameter to $true.
            #>
            if ($Deployment.FailParameterValue) {
                $NewCMApplicationDeployment.Add('FailParameterValue', $Deployment.FailParameterValue)
            }

            <#
                Indicates whether to create an Operations Manager alert if a client fails to install the application.
            #>
            if ($Deployment.GenerateScomAlertOnFailure) {
                $NewCMApplicationDeployment.Add('GenerateScomAlertOnFailure', $Deployment.GenerateScomAlertOnFailure)
            }

            <#
                Indicates whether the deployment takes place even if scheduled outside of a maintenance window.
                A maintenance window is a specified period of time used for computer maintenance and updates.
                If this value is $true, Configuration Manager deploys the application even if the scheduled time falls outside the maintenance window.
                If this value is $false, Configuration Manager doesn't deploy the application outside the window. It waits until it can deploy in an available window.
            #>
            if ($Deployment.OverrideServiceWindow) {
                $NewCMApplicationDeployment.Add('OverrideServiceWindow', $Deployment.OverrideServiceWindow)
            }

            <#
                Indicates whether to enable write filters for embedded devices. For a value of $true, the device commits changes during a maintenance window.
                This action requires a restart. For a value of $false, the device saves changes in an overlay and commits them later.
            #>
            if ($Deployment.PersistOnWriteFilterDevice) {
                $NewCMApplicationDeployment.Add('PersistOnWriteFilterDevice', $Deployment.PersistOnWriteFilterDevice)
            }

            <#
                When you set CreateAlertBaseOnPercentSuccess to $true, use this parameter to specify a DateTime object.
                Configuration Manager creates a deployment alert when the threshold is lower than the SuccessParameterValue after this date.
            #>
            if ($Deployment.PostponeDateTime) {
                $NewCMApplicationDeployment.Add('PostponeDateTime', $Deployment.PostponeDateTime)
            }

            <#
                Indicates whether to pre-deploy the application to the primary device of the user.
            #>
            if ($Deployment.PreDeploy) {
                $NewCMApplicationDeployment.Add('PreDeploy', $Deployment.PreDeploy)
            }

            <#
                Indicates whether a computer restarts outside a maintenance window. A maintenance window is a specified period of time used for computer maintenance and updates.
                If this value is $true, any required restart takes place without regard to maintenance windows.
                If this value is $false, the computer doesn't restart outside a maintenance window.
            #>
            if ($Deployment.RebootOutsideServiceWindow) {
                $NewCMApplicationDeployment.Add('RebootOutsideServiceWindow', $Deployment.RebootOutsideServiceWindow)
            }

            <#
                When required software is available on the client, set this parameter to $true to replace the default toast notifications with a dialog window.
                It's false by default.
            #>
            if ($Deployment.ReplaceToastNotificationWithDialog) {
                $NewCMApplicationDeployment.Add('ReplaceToastNotificationWithDialog', $Deployment.ReplaceToastNotificationWithDialog)
            }

            <#
                Indicates whether to send a wake-up packet to computers before the deployment begins.
                If this value is $true, Configuration Manager attempts to wake a computer from sleep.
                If this value is $false, it doesn't wake computers from sleep. For computers to wake, you must first configure Wake On LAN.
            #>
            if ($Deployment.SendWakeupPacket) {
                $NewCMApplicationDeployment.Add('SendWakeupPacket', $Deployment.SendWakeupPacket)
            }

            <#
                Specifies the percentage of successful application installation that causes an alert. Specify an integer from 0 through 99.
                To enable this alert, set the CreateAlertBaseOnPercentSuccess parameter as $true.
            #>
            if ($Deployment.SuccessParameterValue) {
                $NewCMApplicationDeployment.Add('SuccessParameterValue', $Deployment.SuccessParameterValue)
            }

            <#
                For an available deployment, use this parameter to specify the installation deadline to upgrade users or devices that have the superseded application installed.
                Use DeadlineDateTime to specify a specific time, otherwise it's as soon as possible after the AvailableDateTime.
            #>
            if ($Deployment.UpdateSupersedence) {
                $NewCMApplicationDeployment.Add('UpdateSupersedence', $Deployment.UpdateSupersedence)
            }

            <#
                Indicates whether to allow clients to download content over a metered internet connection after the deadline, which may incur extra expense.
            #>
            if ($Deployment.UseMeteredNetwork) {
                $NewCMApplicationDeployment.Add('UseMeteredNetwork', $Deployment.UseMeteredNetwork)
            }

            <#
                Specifies the type of user notification.

                DisplayAll: Display in Software Center and show all notifications.
                DisplaySoftwareCenterOnly: Display in Software Center, and only show notifications of computer restarts.
                HideAll: Hide in Software Center and all notifications
            #>
            if ($Deployment.UserNotification) {
                $NewCMApplicationDeployment.Add('UserNotification', $Deployment.UserNotification)
            }

            Write-Host ('[CMBuilder-Deploy.Configuration] New-CMApplicationDeployment: {0}' -f ($NewCMApplicationDeployment | Out-String))
            New-CMApplicationDeployment @NewCMApplicationDeployment

            if (Get-Variable -Name 'NewDeployments' -Scope 'Global' -ErrorAction SilentlyContinue) {
                Write-Host '[CMBuilder-Deploy.Configuration] NewDeployments variable exists. Adding some info...'
                $NewDeployments.Add([PSCustomObject] @{
                    CollectionName = $Collection.Name
                    Action         = $NewCMApplicationDeployment.DeployPurpose
                }) | Out-Null
            }
        }
    }
}
