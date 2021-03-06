using module .\AWS.SAML.Settings.psm1

function Get-ChromeDriverNeeded{
    [CmdletBinding()]
    [OutputType([String])]
    param(
    )

    $version = Get-ChromeVersion
    return Get-ChromeDriverPathByVersion -ChromeVersion $version
}

function Get-ChromeVersion {
    [CmdletBinding()]
    [OutputType([String])]
    param(
    )
    switch ($true) {
        $IsMacOS {
            # Example response: Google Chrome 80.0.3987.163
            $response = & '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' --version
            return $response.trim(' ').split(' ')[-1]
        }
        $IsLinux {
            throw 'Chrome Driver Management Not Implemented for Linux Yet!'
        }
        $IsWindows {
            # Get File Path
            $ChromeFile = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe').'(Default)'

            return (Get-Item $ChromeFile).VersionInfo.ProductVersion
        }
        Default {
            Throw 'Not able to detect the platform being used.  Make sure you are using an updated version of PowerShell.'
        }
    }
}

function Get-ChromeDriverPathByVersion {
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory=$true)]
        [String]$ChromeVersion
    )

    $neededDriverVersion = Get-ChromeDriverVersionByChromeVersion -ChromeVersion $ChromeVersion
    $versionsAvailable = Get-ChromeDriverVersions
    $DriverFolder = Get-ChromeDriverFolder

    # Check for the driver and download if needed
    if($neededDriverVersion -notin $versionsAvailable){
        Install-ChromeDriver -ChromeVersion $ChromeVersion
    }

    # Get Driver Details
    $file = (Get-ChildItem "$DriverFolder\$neededDriverVersion\").Name
    return "$DriverFolder\$neededDriverVersion\$file"
}

function Get-ChromeDriverVersions {
    [CmdletBinding()]
    param(
    )

    # Get Driver Details
    $DriverFolder = Get-ChromeDriverFolder
    Return (Get-ChildItem $DriverFolder).Name
}

function Install-ChromeDriver{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [String]$ChromeVersion
    )

    # Get Driver Details
    $DriverFolder = Get-ChromeDriverFolder
    $DriverVersion = Get-ChromeDriverVersionByChromeVersion -ChromeVersion $ChromeVersion

    # Download File
    $DownloadFile = Invoke-ChromeDriverDownload -DriverFolder $DriverFolder -DriverVersion $DriverVersion
    Expand-Archive -LiteralPath $DownloadFile -DestinationPath "$DriverFolder\$DriverVersion"

    # Additional File Prep
    if($IsMacOS){
        # Mark as Executable
        Push-Location "$DriverFolder\$DriverVersion"
        & 'chmod' 755 chromedriver
        Pop-Location
    }

    Remove-Item $DownloadFile
}

function Invoke-ChromeDriverDownload {
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory=$true)]
        [String]$DriverFolder,
        [Parameter(Mandatory=$true)]
        [String]$DriverVersion
    )

    $DriverName = Get-ChromeDriverName

    $DownloadURI = "https://chromedriver.storage.googleapis.com/$DriverVersion/$DriverName"
    $DownloadFile = "$($DriverFolder)\$DriverVersion`_$DriverName"

    Invoke-WebRequest -Uri $DownloadURI -OutFile $DownloadFile
    return $DownloadFile
}

function Get-ChromeDriverVersionByChromeVersion {
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory=$true)]
        [String]$ChromeVersion
    )
    $version = Select-ChromeVersionForDriver -ChromeVersion $ChromeVersion

    $URL = "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$version"
    return Invoke-RestMethod -Method Get -Uri $URL
}

function Get-ChromeDriverFolder {
    [CmdletBinding()]
    [OutputType([String])]
    param(
    )
    $directory = "$(Get-SaveDir)\ChromeDrivers"

    # Create the folder if it doesn't exist
    if(!(Test-Path $directory)){
        New-Item -ItemType Directory $directory
    }

    return $directory
}

function Select-ChromeVersionForDriver {
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory=$true)]
        [String]$ChromeVersion
    )
    $versions = $ChromeVersion.Split('.')

    return "$($versions[0]).$($versions[1]).$($versions[2])"
}

function Get-ChromeDriverName {
    [CmdletBinding()]
    [OutputType([String])]
    param(
    )

    switch ($true) {
        $IsMacOS { return 'chromedriver_mac64.zip' }
        $IsLinux { return 'chromedriver_linux64.zip' }
        $IsWindows { return 'chromedriver_win32.zip' }
        Default { Throw 'Not able to detect the platform being used.  Make sure you are using an updated version of PowerShell.' }
    }
}