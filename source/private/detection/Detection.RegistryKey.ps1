function Detection.RegistryKey {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Detection
    )

    Process {
        $NewCMDetectionClauseRegistryKey = @{
            Hive      = $Detection.Hive
            KeyName   = $Detection.KeyName
            Existence = $true
        }

        if ($Detection.Is32BitApplicationOn64BitSystem) {
            $NewCMDetectionClauseRegistryKey.Add('Is64Bit', $false)
        } else {
            $NewCMDetectionClauseRegistryKey.Add('Is64Bit', $true)
        }

        Write-Host ('[CMBuilder-Detection.RegistryKey] New-CMDetectionClauseRegistryKey: {0}' -f ($NewCMDetectionClauseRegistryKey | Out-String))
        $CMDetectionClauseRegistryKey = New-CMDetectionClauseRegistryKey @NewCMDetectionClauseRegistryKey

        Write-Output $CMDetectionClauseRegistryKey
    }
}