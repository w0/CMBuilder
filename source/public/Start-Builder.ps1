function Start-Builder {
    [CmdletBinding()]
    param (
        # Valid path to the configuration file. Currently supported xml and yaml
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript({ $_.Exists })]
        [IO.FileInfo]
        $ConfigFile,

        # Directory containing files needed for the Application to install.
        [Parameter(Mandatory = $true)]
        [IO.DirectoryInfo]
        $SourceDirectory,

        # Configuration Manager FQDN ex: configmgr.contoso.com
        [Parameter(Mandatory = $true)]
        [string]
        $SiteServerFQDN,

        # Configuration manager site code ex: CON
        [Parameter(Mandatory)]
        [string]
        $SiteCode,

        # Network share accessable by configmgr to store content.
        [Parameter(Mandatory)]
        [IO.DirectoryInfo]
        $ContentShare,

        # Optional array of distribution points to distribute content too. 
        [Parameter()]
        [string[]]
        $DistributionPoints,

        # Optional array of distribution point groups to distribute too.
        [Parameter()]
        [string[]]
        $DistributionPointGroups,

        # Specify a child directory to store applications in. 
        [Parameter()]
        [string]
        $ApplicationFolder,

        # Specify a child directory to create collections under.
        [Parameter()]
        [string]
        $CollectionFolder,
        
        # Update old application referenced in a task sequence
        [Parameter()]
        [switch]
        $UpdateTaskSequences,

        # List of Task sequence that will be excluded from having the old application updated. 
        [Parameter()]
        [string[]]
        $TaskSequenceSkipList,

        # Copy the deployment from the old application to the new application.
        [Parameter()]
        [switch]
        $CopyDeployment
    )

    Begin {
        $ErrorActionPreference = 'Stop'

        try {
            Import-Module (Join-Path (Split-Path $env:SMS_ADMIN_UI_PATH -Parent) 'ConfigurationManager.psd1')
        } catch {
            throw 'The specified module ''ConfigurationManager'' was not loaded because no valid module file was found. Is the admin console installed?'
        }

        # Read ConfigFile
        switch ($ConfigFile.Extension) {
            '.xml' {
                $XML = New-Object xml
                $XML.PreserveWhitespace = $true
                $XML.Load($ConfigFile.FullName)
        
                $Script:Configuration = $XML.package
            }
            '.yaml' {
                $Script:Configuration = Get-Content $ConfigFile.FullName | ConvertFrom-Yaml
            }
            Default { throw 'Invalid configuration file. '}
        }

        $Script:Version = $Configuration.SoftwareVersion

        Write-Verbose ('[CMBuilder] Configuration: {0}' -f ($Configuration | Out-String))

        Write-Host '[CMBuilder] Importing Configuration Manager PSModule'

        Write-Host '[CMBuilder] Ensuring Configuration Manager Drive is mapped'

        if (-not (Get-PSDrive -Name $SiteCode -ErrorAction SilentlyContinue)) {
            New-PSDrive -Name $SiteCode -PSProvider "CMSite" -Root $SiteServerFQDN -Description "SCCM Site" | Out-Null
        }
    }

    Process {
        Write-Host '[CMBuilder] Moving '
        Write-Host ('[CMBuilder] Source Directory: {0}' -f $SourceDirectory)

        PkgSrc -SourceDirectory $SourceDirectory -ContentRoot $ContentShare

        Push-Location ('{0}:' -f $SiteCode)


        Write-Host '[CMBuilder] Creating/Detecting application folder'

        if ($ApplicationFolder) {
            $Folder = Folder -FolderType 'Application' -RootOverride $ApplicationFolder
        } else {
            $Folder = Folder -FolderType 'Application'
        }


        $ContainerNodeID = (Get-Item $Folder).ContainerNodeID

        Write-Host ('[CMBuilder] Folder: {0}' -f $Folder)
        Write-Host ('[CMBuilder] Folder ContainerNodeId: {0}' -f $ContainerNodeID)


        Write-Host '[CMBuilder] Creating application'

        $CMApplication  = Application -Folder $Folder

        $DeploymentType = DeploymentType -CMApplication $CMApplication

        Write-Host '[CMBuilder] Distributing Application to DPs'
        
        Distribute -CMApplication $CMApplication

        Write-Host '[CMBuilder] Detecting older versions'

        $instanceKeys = (Invoke-CMWmiQuery -Query "select InstanceKey from SMS_ObjectContainerItem where ObjectType='6000' and ContainerNodeID='$ContainerNodeID'").instanceKey
        $ExistingApplications = foreach ($Key in $instanceKeys) {
            Get-CMApplication -ModelName $Key
        }

        Write-Host ('[CMBuilder] Detected {0} applications' -f $ExistingApplications.Count)

        if ($ExistingApplications) {
            $Applications = $ExistingApplications | Where-Object { ($_.SoftwareVersion -ne $Script:Version) -and ($_.SoftwareVersion -notmatch '[a-z]') }

            foreach ($Application in $Applications) {
                if (-not ($Application.SoftwareVersion)) {
                    continue
                }

                $VersionInfo = [Version]$Application.SoftwareVersion

                if (($Null -eq $LatestApplication) -or ($VersionInfo -ge [Version]$LatestApplication.SoftwareVersion)) {
                    $LatestApplication = $Application
                }
            }

            if ($LatestApplication) {
                Write-Host '[CMBuilder] Found a previous version. Superseding it!'
                Write-Host ('[CMBuilder] Old version: {0}; New Version: {1}' -f $LatestApplication.SoftwareVersion, $Script:Version)
                Supersede -NewCMApplication $CMApplication -OldCMApplication $LatestApplication

                if ((-not $Configuration.NoDeploy) -and ($UpdateTaskSequences)) {
                    Write-Host '[CMBuilder] Updating Task Sequences'
                    TaskSequence -NewCMApplication $CMApplication -OldCMApplication $LatestApplication

                    ApplicationGroup -NewCMApplication $CMApplication -OldCMApplication $LatestApplication
                }
            }
        }

        if (-not ($Configuration.NoDeploy)) {
            Write-Host '[CMBuilder] Deploying Application'
            Deploy -NewCMApplication $CMApplication -OldCMApplication $LatestApplication
        } else {
            Write-Warning '[CMBuilder] Configuration has NoDeploy key set. This application will not be automatically deployed.'
        }

        if ($Configuration.SoftwareMetering) {
            $MeteringFolder = Folder -FolderType 'SoftwareMetering'
            Metering -Folder $MeteringFolder
        }
    }

    End {
        #We leave after as to not cause any trouble, perhaps unnecessary
        Pop-Location
    }
}
