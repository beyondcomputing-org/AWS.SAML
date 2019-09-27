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