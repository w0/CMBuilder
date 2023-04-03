function Wim {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [IO.DirectoryInfo]
        $Directory
    )

    Write-Host '[Wim] Creating a new source directory'

    <#
        New Source Directory will be used to house the Invoke-WimAppDeploy.ps1 and the Application.wim files.
        $Directory and all of it's contents, which may include template directory contents, will be deleted at the completion of this function to clean up space on servers
    #>

    [IO.DirectoryInfo] $NewSourceDirectory = Join-Path $env:Temp (New-Guid).Guid

    if (-not ($NewSourceDirectory.Exists)) {
        Write-Host '[Wim] New source directory directory does not exist. Creating...'
        $NewSourceDirectory = New-Item $NewSourceDirectory.FullName -ItemType Directory -Force
    }

    [IO.DirectoryInfo] $ApplicationFiles = Join-Path $Directory.FullName 'Application Files'

    if (-not ($ApplicationFiles.Exists)) {
        Write-Host '[Wim] New Application Files directory directory does not exist. Creating...'
        $ApplicationFiles = New-Item $ApplicationFiles.FullName -ItemType Directory -Force
    }

    if (($Configuration.TemplateDirectory) -and (Test-Path $Configuration.TemplateDirectory)) {
        Copy-Item -Path "$($Configuration.TemplateDirectory)\*" -Destination $ApplicationFiles.FullName -Recurse -Force | Out-Null
    }

    Write-Host '[Wim] Moving files from Source Directory to the Application Files directory...'
    foreach ($File in (Get-ChildItem $Directory.FullName -Exclude 'Invoke-WimAppDeploy.ps1', 'Settings.json', 'WimAppDeploy', 'Source Files', 'Application Files')) {
        Write-Host ('[Wim] Moving item: {0}' -f $File.Name)
        Move-Item -Path $File.FullName -Destination $ApplicationFiles.FullName -Force -ErrorAction Stop
    }

    Write-Host '[Wim] Setting up all of the WimAppDeploy files'

    $GLWimAppDeploy = Join-Path $Directory.FullName 'Invoke-WimAppDeploy.ps1'
    Write-Host ('[Wim] GLWimAppDeploy potential path: {0}' -f $GLWimAppDeploy)
    if (Test-Path $GLWimAppDeploy) {
        Copy-Item $GLWimAppDeploy -Destination $NewSourceDirectory.FullName -Force
    }

    $GLSettingsFile = Join-Path $Directory.FullName 'Settings.json'
    Write-Host ('[Wim] GLSettingsFile potential path: {0}' -f $GLSettingsFile)
    if (Test-Path $GLSettingsFile) {
        Copy-Item $GLSettingsFile -Destination $NewSourceDirectory.FullName -Force
    }

    $GLWimAppDeployDir = Join-Path $Directory.FullName 'WimAppDeploy'
    Write-Host ('[Wim] GLWimAppDeployDir potential path: {0}' -f $GLWimAppDeployDir)
    if (Test-Path $GLWimAppDeployDir) {
        Copy-Item $GLWimAppDeployDir -Destination $NewSourceDirectory.FullName -Force -Recurse
    }

    $GLSourceFilesDirectory = Join-Path $Directory.FullName 'Source Files'
    Write-Host ('[Wim] GLSourceFilesDirectory potential path: {0}' -f $GLSourceFilesDirectory)
    if (Test-Path $GLSourceFilesDirectory) {
        Copy-Item $GLSourceFilesDirectory -Destination $NewSourceDirectory.FullName -Force -Recurse
    }



    Write-Host '[Wim] Generating the WIM file'

    [IO.FileInfo] $ImageFile = Join-Path $NewSourceDirectory.FullName 'Application.wim'
    Start-Process 'dism.exe' -ArgumentList "/Capture-Image /ImageFile:""$($ImageFile.FullName)"" /CaptureDir:""$($ApplicationFiles.FullName)"" /Name:""$($Configuration.Name)"" /Description:""$($Configuration.Name)"" /Compress:fast" -Wait -NoNewWindow -ErrorAction 'Stop'

    Write-Host ('[Wim] WIM file filepath: {0}' -f ($ImageFile.FullName))
    Write-Host ('[Wim] WIM file created: {0}' -f ($ImageFile.Exists))

    if (-not ($ImageFile.Exists)) {
        Throw '[Wim] Failed to locate the Application.wim file'
    }

    return $NewSourceDirectory
}
