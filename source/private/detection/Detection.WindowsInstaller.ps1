function Detection.WindowsInstaller {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Detection
    )

    Process {
        $NewCMDetectionClauseWindowsInstaller = @{}

        if ($ProductCode) {
            $NewCMDetectionClauseWindowsInstaller.Add('ProductCode', $ProductCode)
        } elseif ($Detection.ProductCode) {
            $NewCMDetectionClauseWindowsInstaller.Add('ProductCode', $Detection.ProductCode)
        } else {
            Throw '[CMBuilder-Detection.WindowsInstaller] Failed to find the product code'
        }

        if ($Detection.PropertyType) {
            Write-Host '[CMBuilder-Detection.WindowsInstaller] Detecting specific value'

            $NewCMDetectionClauseWindowsInstaller.Add('Value', $true)
            $NewCMDetectionClauseWindowsInstaller.Add('ExpectedValue', $Detection.ExpectedValue)

            if ($Detection.PropertyType) {
                $NewCMDetectionClauseWindowsInstaller.Add('PropertyType', $Detection.PropertyType)
            } else {
                $NewCMDetectionClauseWindowsInstaller.Add('PropertyType', 'ProductVersion') # Doesn't really matter here, right now it only accepts this single value.
            }

            if ($Detection.ExpressionOperator) {
                $NewCMDetectionClauseWindowsInstaller.Add('ExpressionOperator', $Detection.ExpressionOperator)
            } else {
                $NewCMDetectionClauseWindowsInstaller.Add('ExpressionOperator', 'IsEquals')
            }
        } else {
            Write-Host '[CMBuilder-Detection.WindowsInstaller] Detecting Existence'

            $NewCMDetectionClauseWindowsInstaller.Add('Existence', $Detection.Existence)
        }

        Write-Host ('[CMBuilder-Detection.WindowsInstaller] New-CMDetectionClauseWindowsInstaller: {0}' -f ($NewCMDetectionClauseWindowsInstaller | Out-String))
        $CMDetectionClauseWindowsInstaller = New-CMDetectionClauseWindowsInstaller @NewCMDetectionClauseWindowsInstaller

        Write-Output $CMDetectionClauseWindowsInstaller
    }
}