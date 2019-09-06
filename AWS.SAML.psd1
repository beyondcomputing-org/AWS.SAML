#
# Module manifest for module 'AWS.SAML'
#
# Generated by: Mark Studer
#
# Generated on: 8/31/2019
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule        = 'AWS.SAML.psm1'

    # Version number of this module.
    ModuleVersion     = '0.5.1'

    # Supported PSEditions
    # CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID              = '555700b8-4e59-4c81-aca6-52b7e51a76ac'

    # Author of this module
    Author            = 'Mark Studer'

    # Company or vendor of this module
    CompanyName       = 'BeyondComputing'

    # Copyright statement for this module
    Copyright         = '(c) BeyondComputing. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'Provides CLI Access to AWS using SAML authentication in a browser.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @(
        @{ModuleName="Selenium"; ModuleVersion="2.0"; Guid="a3bdb8c3-c150-48a8-b56d-cd4d43f46a26"},
        @{ModuleName="AWS.Tools.SecurityToken"; ModuleVersion="3.3.563.1"; Guid="b760f2e8-291f-4df4-bd69-3a615b47c8d4"}
    )
    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules     = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'New-AWSSAMLLogin'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = @('Login-AWSSAML')

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @(
                'AWS',
                'SAML',
                'STS',
                'Login',
                'Authentication'
            )

            # A URL to the license for this module.
            LicenseUri   = 'https://raw.githubusercontent.com/beyondcomputing-org/AWS.SAML/master/LICENSE.md'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/beyondcomputing-org/AWS.SAML'

            # A URL to an icon representing this module.
            # IconUri      = 'https://raw.githubusercontent.com/beyondcomputing-org/AWS.SAML/master/Icon/icon-small.png'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://raw.githubusercontent.com/beyondcomputing-org/AWS.SAML/master/CHANGELOG.md'

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    HelpInfoURI       = 'https://github.com/beyondcomputing-org/AWS.SAML'

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}