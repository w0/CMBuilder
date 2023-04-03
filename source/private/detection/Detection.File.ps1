function Detection.File {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Detection
    )

    Process {
        $NewCMDetectionClauseFile = @{
            FileName = $Detection.FileName
            Path     = $Detection.Path
        }

        if ($Detection.PropertyType) {
            Write-Host '[CMBuilder-Detection.File] Detecting specific value'

            $NewCMDetectionClauseFile.Add('PropertyType', $Detection.PropertyType)
            $NewCMDetectionClauseFile.Add('ExpectedValue', $Detection.ExpectedValue)
            $NewCMDetectionClauseFile.Add('Value', $true)

            if ($Detection.ExpressionOperator) {
                $NewCMDetectionClauseFile.Add('ExpressionOperator', $Detection.ExpressionOperator)
            } else {
                $NewCMDetectionClauseFile.Add('ExpressionOperator', 'IsEquals')
            }
        } else {
            Write-Host '[CMBuilder-Detection.File] Detecting Existence'
            $NewCMDetectionClauseFile.Add('Existence', $true)
        }

        if ($Detection.Is32BitApplicationOn64BitSystem) {
            $NewCMDetectionClauseFile.Add('Is64Bit', $false)
        } else {
            $NewCMDetectionClauseFile.Add('Is64Bit', $true)
        }

        Write-Host ('[CMBuilder-Detection.File] New-CMDetectionClauseFile: {0}' -f ($NewCMDetectionClauseFile | Out-String))
        $CMDetectionClauseFile = New-CMDetectionClauseFile @NewCMDetectionClauseFile

        Write-Output $CMDetectionClauseFile
    }
}