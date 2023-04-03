function Detection.RegistryKeyValue {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Detection
    )

    Process {
        $NewCMDetectionClauseRegistryKeyValue = @{
            Hive         = $Detection.Hive
            KeyName      = $Detection.KeyName
            ValueName    = $Detection.ValueName
            PropertyType = $Detection.PropertyType
        }

        if ($Detection.ExpectedValue) {
            Write-Host '[CMBuilder-Detection.RegistryKeyValue] Detecting specific value'
            $NewCMDetectionClauseRegistryKeyValue.Add('Value', $true)
            $NewCMDetectionClauseRegistryKeyValue.Add('ExpectedValue', $Detection.ExpectedValue)
            if ($Detection.ExpressionOperator) {
                $NewCMDetectionClauseRegistryKeyValue.Add('ExpressionOperator', $Detection.ExpressionOperator)
            } else {
                $NewCMDetectionClauseRegistryKeyValue.Add('ExpressionOperator', 'IsEquals')
            }
        } else {
            Write-Host '[CMBuilder-Detection.RegistryKeyValue] Detecting Existence'
            $NewCMDetectionClauseRegistryKeyValue.Add('Existence', $Detection.Existence)
        }

        if ($Detection.Is32BitApplicationOn64BitSystem) {
            $NewCMDetectionClauseRegistryKeyValue.Add('Is64Bit', $false)
        } else {
            $NewCMDetectionClauseRegistryKeyValue.Add('Is64Bit', $true)
        }

        Write-Host ('[CMBuilder-Detection.RegistryKeyValue] New-CMDetectionClauseRegistryKeyValue: {0}' -f ($NewCMDetectionClauseRegistryKeyValue | Out-String))
        $CMDetectionClauseRegistryKeyValue = New-CMDetectionClauseRegistryKeyValue @NewCMDetectionClauseRegistryKeyValue

        Write-Output $CMDetectionClauseRegistryKeyValue
    }
}
