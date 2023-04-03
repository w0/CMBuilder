function Folder {
    [CmdletBinding()]
    param (
        [Parameter (Mandatory = $true, Position = 0)]
        [System.String]
        [ValidateSet('Application', 'SoftwareMetering', 'Package')]
        $FolderType,

        [Parameter(Mandatory = $false, Position = 1)]
        [System.String]
        $RootOverride
    )

    Process {
        Write-Progress 'Ensuring Folder Exists'

        if ($RootOverride) {
            $FolderPath = '{0}:\{1}\{2}\{3}\{4}' -f $SiteCode, $FolderType, $RootOverride, $Configuration.Publisher, $Configuration.Name
        } else {
            $FolderPath = '{0}:\{1}\{2}\{3}' -f $SiteCode, $FolderType, $Configuration.Publisher, $Configuration.Name
        }

        Write-Host ('[CMBuilder-Folder] Expected folder path: {0}' -f $FolderPath)

        if (-not (Test-Path $FolderPath)) {
            $WorkingVar = $FolderPath # FolderPath needs to be returned complete

            # Loop until a valid parent is found
            $MissingParents = do {
                Write-Output $WorkingVar
                $WorkingVar = Split-Path $WorkingVar -Parent
            } While (-not (Test-Path $WorkingVar))

            [array]::Reverse($MissingParents)

            # Create the missing folders
            foreach ($Parent in $MissingParents) {
                Write-Host ('[CMPackaer-Folder] Creating Missing Folders: {0}' -f $Parent)
                New-Item -Path $Parent -ItemType Directory -Force
            }
        }

        Write-Output $FolderPath
    }
}