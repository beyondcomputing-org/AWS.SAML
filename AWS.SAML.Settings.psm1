function Save-AWSSAMLURL {
    [CmdletBinding()]
    param(
    )

    $SaveDir = Get-SaveDir

    $URL = Read-Host -Prompt 'Enter the SSO Initiation URL'

    # Save the settings to the local system
    if(!(Test-Path($SaveDir))){
        New-Item -Type Directory -Path $SaveDir | Out-Null
    }

    $URL | Export-CliXml -Path ("$SaveDir\Settings.xml")  -Encoding 'utf8' -Force

    return $URL
}

function Get-AWSSAMLURL {
    [OutputType([String])]
    [CmdletBinding()]
    param(
    )

    $SavePath = "$(Get-SaveDir)\Settings.xml"

    if(Test-Path($SavePath)){
        return Import-CliXml -Path ($SavePath)
    }else{
        Return Save-AWSSAMLURL
    }
}

function Get-SaveDir {
    [OutputType([String])]
    [CmdletBinding()]
    param(
    )

    if($IsMacOS){
        return "${env:\HOME}/.AWS.SAML"
    }else{
        return "${env:\userprofile}\.AWS.SAML"
    }
}

function Get-AWSDirectory{
    [OutputType([String])]
    [CmdletBinding()]
    param(
    )

    if($IsMacOS){
        return "${env:\HOME}/.aws/"
    }else{
        return "${env:\userprofile}\.aws\"
    }
}

function Get-AWSCredentialFile{
    [OutputType([Array])]
    [CmdletBinding()]
    param(
    )
    $directory = Get-AWSDirectory

    # Return the credential file or a blank string if it doesn't yet exist
    if(Test-Path $directory){
        if(Test-Path "$directory`credentials"){
            return Get-Content -Path "$directory`credentials"
        }else{
            return $null
        }
    }else{
        return $null
    }
}

function Save-AWSCredentialFile{
    [CmdletBinding()]
    param(
        $FileContent
    )
    $directory = Get-AWSDirectory

    # Create the folder if it doesn't exist
    if(!(Test-Path $directory)){
        New-Item -ItemType Directory $directory
    }

    if(!(Test-Path "$directory`credentials")){
        New-Item -ItemType File "$directory`credentials"
    }

    $FileContent | Set-Content -Path "$directory`credentials" -Encoding UTF8
}