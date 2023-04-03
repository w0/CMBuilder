function Detection.Directory {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Detection
    )

    Process {
        $NewCMDetectionClauseDirectory = @{
            DirectoryName = $Detection.DirectoryName
            Path          = $Detection.Path
        }

        if ($Detection.PropertyType) {
            Write-Host '[CMBuilder-Detection.Directory] Detecting specific value'
            if ($Detection.PropertyType) {
                $NewCMDetectionClauseDirectory.Add('PropertyType', $Detection.PropertyType)
            } else {
                $NewCMDetectionClauseDirectory.Add('PropertyType', 'DateCreated')
            }

            $NewCMDetectionClauseDirectory.Add('ExpectedValue', $Detection.ExpectedValue)
        } else {
            Write-Host '[CMBuilder-Detection.Directory] Detecting Existence'
            $NewCMDetectionClauseDirectory.Add('Existence', $true)
        }

        Write-Host ('[CMBuilder-Detection.Directory] New-CMDetectionClauseDirectory: {0}' -f ($NewCMDetectionClauseDirectory | Out-String))
        $CMDetectionClauseDirectory = New-CMDetectionClauseDirectory @NewCMDetectionClauseDirectory

        Write-Output $CMDetectionClauseDirectory
    }
}