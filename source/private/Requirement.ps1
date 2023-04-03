function Requirement {
    [CmdletBinding()]

    param (
        [Parameter(Position = 0, Mandatory = $true)]
        $AddRequirement
    )

    Process {
        foreach ($Requirement in $AddRequirement) {
            & "Requirement.$($Requirement.Type)" -Requirement $Requirement
        }
    }
}