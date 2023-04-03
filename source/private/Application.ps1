<#

    .SYNOPSIS

        Creates an SCCM Application

    .DESCRIPTION

        With a provided (required) configuration file, we can automatically create applications in SCCM, superseeding previous versions

#>

function Application {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]
        $Folder
    )

    Process {
        Write-Host '[CMBuilder-Application] Creating Application'

        $NewCMApplication = @{
            Name                     = ('{0} {1} {2}' -f $Configuration.Publisher, $Configuration.Name, $Script:Version)
            LocalizedApplicationName = if ($Configuration.LocalizedApplicationName) {
                $Configuration.LocalizedApplicationName
            } else {
                ('{0} {1}' -f $Configuration.Publisher, $Configuration.Name)
            }
            SoftwareVersion          = $Script:Version
            Publisher                = $Configuration.Publisher
            Description              = ('Created by CMBuilder -- {0}' -f $Configuration.Description)
            ReleaseDate              = (Get-Date)
            AutoInstall              = $true # Allow install from Task Sequence
        }

        if ($Configuration.AppCatalog) {
            $NewCMApplication.Add('AppCatalog', $Configuration.AppCatalog)
        }

        if ($Configuration.DefaultLanguageId) {
            $NewCMApplication.Add('DefaultLanguageId', $Configuration.DefaultLanguageId)
        }

        if ($Configuration.DisplaySupersedenceInApplicationCatalog) {
            $NewCMApplication.Add('DisplaySupersedenceInApplicationCatalog', $Configuration.DisplaySupersedenceInApplicationCatalog)
        }

        if ($Configuration.IconLocationFile) {
            $NewCMApplication.Add('IconLocationFile', $Configuration.IconLocationFile)
        }

        if ($Configuration.IsFeatured) {
            $NewCMApplication.Add('IsFeatured', $Configuration.IsFeatured)
        }

        if ($Configuration.Keyword) {
            $NewCMApplication.Add('Keyword', $Configuration.Keyword)
        }

        if ($Configuration.LinkText) {
            $NewCMApplication.Add('LinkText', $Configuration.LinkText)
        }

        if ($Configuration.LocalizedDescription) {
            $NewCMApplication.Add('LocalizedDescription', $Configuration.LocalizedDescription)
        }

        if ($Configuration.LocalizedName) {
            $NewCMApplication.Add('LocalizedName', $Configuration.LocalizedName)
        }

        if ($Configuration.OptionalReference) {
            $NewCMApplication.Add('OptionalReference', $Configuration.OptionalReference)
        }

        if ($Configuration.Owner) {
            $NewCMApplication.Add('Owner', $Configuration.Owner)
        }

        if ($Configuration.PrivacyUrl) {
            $NewCMApplication.Add('PrivacyUrl', $Configuration.PrivacyUrl)
        }

        if ($Configuration.SupportContact) {
            $NewCMApplication.Add('SupportContact', $Configuration.SupportContact)
        }

        if ($Configuration.UserDocumentation) {
            $NewCMApplication.Add('UserDocumentation', $Configuration.UserDocumentation)
        }

        Write-Host ('[CMBuilder-Application] New-CMApplication: {0}' -f ($NewCMApplication | Out-String))
        $CMApplication = New-CMApplication @NewCMApplication
        Move-CMObject -FolderPath $Folder -InputObject $CMApplication

        Write-Output $CMApplication
    }
}
