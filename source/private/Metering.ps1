function Metering {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]
        $Folder
    )

    process {
        foreach ($Meter in $Configuration.SoftwareMetering) {
            if ($Rule = Get-CMSoftwareMeteringRule -ProductName $Meter.ProductName) {
                Write-Host ('[Metering] Software Metering rule exists: {0}' -f ($Rule.ProductName -join ', '))
            } else {
                Write-Host '[Metering] Software Metering rule does not exist yet'
                $NewCMSoftwareMeteringRule = @{
                    ProductName      = $Meter.ProductName
                    SiteCode         = $SiteCode
                    FileName         = $Meter.FileName
                    OriginalFileName = $Meter.FileName
                    FileVersion      = if ($Meter.FileVersion) { $Meter.FileVersion } else { '*' }
                }

                Write-Host ('[Metering] New-CMSoftwareMeteringRule: {0}' -f ($NewCMSoftwareMeteringRule | Out-String))

                $Rule = New-CMSoftwareMeteringRule @NewCMSoftwareMeteringRule
                Move-CMObject -FolderPath $Folder -InputObject $Rule
            }
        }
    }
}