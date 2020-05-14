function Add-AWSSTSCred{
    [CmdletBinding()]
    param(
        $STS
    )

    $ENV:AWS_ACCESS_KEY_ID = $STS.Credentials.AccessKeyId
    $ENV:AWS_SECRET_ACCESS_KEY = $STS.Credentials.SecretAccessKey
    $ENV:AWS_SESSION_TOKEN = $STS.Credentials.SessionToken
}

function Get-SAMLRole{
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    param(
        $Assertion,
        $AccountID,
        $Role
    )

    # Convert Assertion to XML
    $saml = [xml][System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Assertion))

    # Create XML Namespace
    $xmlNamespace = @{saml2 = 'urn:oasis:names:tc:SAML:2.0:assertion'}

    # Get Roles
    $rolesXML = Select-Xml -Xml $saml -XPath "//saml2:Attribute[@Name='https://aws.amazon.com/SAML/Attributes/Role']" -Namespace $xmlNamespace | Select-Object -ExpandProperty Node
    $roles = $rolesXML.AttributeValue.'#text'

    # Get Role ARN's
    $arns = ($roles | Select-String "$AccountID`:role/$Role") -split ','

    if($arns){
        return [ordered]@{
            PrincipalArn = $arns[1]
            RoleArn = $arns[0]
        }
    }else{
        Write-Warning "No Role: <$Role> found for Account: <$AccountID>"
        return $null
    }
}

Function Push-StringArrayValue{
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter','')] # False Positive
    param(
        [Array]$Array,
        [String]$Match,
        [String]$Value
    )
    $index = [array]::indexof($Array, ($Array | Where-Object {$_ -match $Match}))

    if($index -ge 0){
        $Array[$index] = $Value
    }else{
        $Array += $Value
    }

    return $Array
}