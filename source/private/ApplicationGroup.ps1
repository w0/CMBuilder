function ApplicationGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        $NewCMApplication,

        [Parameter(Mandatory = $true, Position = 1)]
        $OldCMApplication
    )

    # Get appgroups that contain the old application
    $ApplicationGroups = Get-CMApplicationGroup | Where-Object SDMPackageXML -Match ($OldCMApplication.ModelName -split '/')[1]

    :ApplicationGroup foreach ($Group in $ApplicationGroups) {
        Write-Host ('[ApplicationGroup] Processing Application Group: {0}' -f $Group.LocalizedDisplayName)

        $SDKObject = $Group | ConvertTo-CMApplicationGroup

        Write-Host '[ApplicationGroup] Get names of applications currently in the group'

        [System.Collections.ArrayList] $ApplicationNames = foreach ($Application in $SDKObject.GroupItems) {
            $AppNameQuery = "SELECT LocalizedDisplayName FROM SMS_Application WHERE ModelName = '$($Application.ObjectId.Scope)/$($Application.ObjectId.Name)'"

            Write-Output (Invoke-CMWmiQuery -Query $AppNameQuery).LocalizedDisplayName | Select-Object -Last 1
        }

        # Create an array with the updated application
        $NewList = $ApplicationNames.Replace($OldCMApplication.LocalizedDisplayName, $NewCMApplication.LocalizedDisplayName)

        Write-Host '[ApplicationGroup] Updating Application Group'
        if (-not (Get-CMObjectLockDetails -InputObject $Group).LockState) {
            Set-CMApplicationGroup -Name $Group.LocalizedDisplayName -RemoveApplication $ApplicationNames -AddApplication $NewList
        } else {
            Write-Host ('[ApplicationGroup] CMObject is locked. Skipping.')
            continue ApplicationGroup
        }

        if (Get-Variable -Name 'ModifiedApplicationGroups' -Scope 'Global' -ErrorAction SilentlyContinue) {
            Write-Host '[ApplicationGroup] ModifiedApplicationGroups variable exists. Adding some info...'
            $ModifiedApplicationGroups.Add([PSCustomObject] @{
                GroupName = $Group.LocalizedDisplayName
            }) | Out-Null
        }
    }
}
