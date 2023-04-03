<#
.SYNOPSIS
    Creates a device collection.
.DESCRIPTION
    Create a device collection on the ConfigMgr Site.
    
#>

function Collection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        $CollectionName,

        [Parameter(Mandatory = $true, Position = 1)]
        $LimitingCollectionName,

        [Parameter(Mandatory = $true, Position = 2)]
        $SitePath
    )

    Process {

        $NewColl = @{
            LimitingCollectionName = $LimitingCollectionName
            Name                   = $CollectionName
            Comment                = 'Collection created by CMBuilder'
            RefreshSchedule        = New-CMSchedule -Start (Get-Date) -DayOfWeek Sunday -RecurCount 1
        }
        Write-Host ('[Collection] Creating collection with args: {0}' -f ($NewColl | Out-String))
        $Collection = New-CMDeviceCollection @NewColl

        $FolderPath = ('{0}:\DeviceCollection\{1}' -f $SiteCode, $SitePath)

        Write-Host ('[Collection] Moving to: {0}' -f $FolderPath)
        Move-CMObject -FolderPath $FolderPath -InputObject $Collection

        $Collection

    }
}
