function TaskSequence {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        $NewCMApplication,

        [Parameter(Mandatory = $true, Position = 1)]
        $OldCMApplication
    )

    # Get the task sequence package ids that reference the old application
    $ApplicationQuery = ('select PackageID from SMS_TaskSequenceAppReferencesInfo where RefAppModelName like "{0}"' -f $OldCMApplication.ModelName)
    $TaskSequenceIDs = (Invoke-CMWmiQuery -Query $ApplicationQuery).PackageID

    :TaskSequence foreach ($PackageID in $TaskSequenceIDs) {

        $TaskSequence = Get-CMTaskSequence -TaskSequencePackageId $PackageID -Fast

        Write-Host ('[TaskSequence] Processing Task Sequence: {0}' -f $TaskSequence.Name)
        if (-not ($TaskSequence.TsEnabled)) {
            Write-Verbose 'Task sequence is disabled. Skipping...'
            continue TaskSequence
        }

        if ($TaskSequence.Name -in $TaskSequenceSkipList) {
            Write-Host 'Task sequence is in the opt out list. Skipping...'
            continue TaskSequence
        }

        $InstallApplicationSteps = Get-CMTSStepInstallApplication -InputObject $TaskSequence

        foreach ($TaskSequenceStep in $InstallApplicationSteps) {
            $ApplicationList = $TaskSequenceStep.ApplicationName.Split(",")

            if ($OldCMApplication.ModelName -in $ApplicationList) {
                Write-Host '[TaskSequence] Old application is in this task sequence'
                $ModelNames = $ApplicationList.Replace($OldCMApplication.ModelName, $NewCMApplication.ModelName)

                if (-not (Get-CMObjectLockDetails -InputObject $TaskSequence).LockState) {
                    Set-CMTSStepInstallApplication -InputObject $TaskSequence -StepName $TaskSequenceStep.Name -Application ($ModelNames | ForEach-Object { Get-CMApplication -ModelName $_ })
                } else {
                    Write-Host '[TaskSequence] CMObject locked. Skipping.'
                    continue TaskSequence
                }

                if (Get-Variable -Name 'ModifiedTaskSequences' -Scope 'Global' -ErrorAction SilentlyContinue) {
                    Write-Host '[TaskSequence] ModifiedTaskSequences variable exists. Adding some info...'

                    $ModifiedTaskSequences.Add([PSCustomObject] @{
                        TSName = $TaskSequence.Name
                        TSStep = $TaskSequenceStep.Name
                    }) | Out-Null
                }
            }
        }
    }
}