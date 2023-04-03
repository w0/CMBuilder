function PkgSrc {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [IO.DirectoryInfo]
        $SourceDirectory,

        # Root folder where content will be stored.
        [Parameter(Mandatory = $true)]
        [IO.DirectoryInfo]
        $ContentRoot
    )

    Write-Host ('[Move-ToPkgSrc] Current Location: {0}' -f (Get-Location))
    Write-Host ('[Move-ToPkgSrc] Content Root: {0}' -f $ContentRoot)
    $ContentSubDir = '{0}\{1}\{2}' -f $Configuration.Publisher, $Configuration.Name, $Version

    Write-Host ('[Move-ToPkgSrc]  Subdir: {0}' -f $ContentSubDir)
    [IO.DirectoryInfo] $ContentDirectory = Join-Path $ContentRoot $ContentSubDir
    
    Write-Host ('[Move-ToPkgSrc] PkgSrc directory: [{0}]' -f $ContentDirectory.FullName)

    if (-not ($ContentDirectory.Exists)) {
        Write-Host '[Move-ToPkgSrc] PkgSrc directory does not exist. Creating...'
        $ContentDirectory = New-Item -Path $ContentDirectory.FullName -ItemType Directory -Force -Verbose
    }

    if ($Configuration.WimDeployment) {
        try {
            $SourceDirectory = Wim -Directory $SourceDirectory
        } catch {
            Write-Warning "Failed to create the Application WIM: $_"
            continue Project
        }
    } else {
        Write-Host '[Move-ToPkgSrc] Checking for a template directory'
        if (($Configuration.TemplateDirectory) -and (Test-Path $Configuration.TemplateDirectory)) {
            Write-Host '[Move-ToPkgSrc] Template directory exists! Copying...'
            Copy-Item -Path "$($Configuration.TemplateDirectory)\*" -Destination $ContentDirectory.FullName -Recurse -Force -PassThru | Out-Null
        }
    }

    Write-Host ('[Move-ToPkgSrc] Copying Source Directory: {0}' -f $SourceDirectory.FullName)
    Copy-Item -Path "$($SourceDirectory.FullName)\*" -Destination $ContentDirectory.FullName -Recurse -Force -PassThru | Out-Null

    if ($Configuration.WimDeployment) {
        Write-Host '[Move-ToPkgSrc] Cleaning up Source Directory after copy...'
        Remove-Item $SourceDirectory.FullName -Recurse -Force
    }
}