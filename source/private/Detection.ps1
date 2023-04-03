function Detection {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        $Detection
    )

    Process {
        foreach ($Detect in $Detection) {
            & "Detection.$($Detect.Type)" -Detection $Detect
        }
    }
}