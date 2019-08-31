$SAVE_DIR = "${env:\userprofile}\.AWS.SAML"
$SAVE_FILE = 'Settings.xml'
$SAVE_PATH = $SAVE_DIR + '/' + $SAVE_FILE

<#
    .SYNOPSIS
        Get AWS STS credentials for using in the CLI from a SAML based login.

    .DESCRIPTION
        Get AWS STS credentials for using in the CLI from a SAML based login.

    .EXAMPLE
        C:\PS> Login-AWSSAML

    .PARAMETER InitURL
        The SAML Login Initiation URL.  If not passed you will be prompted and it will be saved for future use.

    .PARAMETER Browser
        Choose the browser to handle the login process.  Options: Chrome, Firefox, Edge  Default: Chrome
#>
function New-AWSSAMLLogin {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    [Alias('Login-AWSSAML')]
    param(
        [String]$InitURL,
        [ValidateSet('Chrome', 'Firefox', 'Edge')]
        [String]$Browser
    )
    if ($pscmdlet.ShouldProcess('AWS SAML', 'login'))
    {
        if([String]::IsNullOrWhiteSpace($InitURL)){
            $InitURL = Get-AWSSAMLURL
        }

        # Open Chrome and launch login page
        switch ($Browser) {
            'Firefox' {
                $Driver = Start-SeFirefox
            }
            'Edge' {
                $Driver = Start-SeEdge
            }
            Default {
                $Driver = Start-SeChrome
            }
        }

        Enter-SeUrl $InitURL -Driver $Driver

        # Wait for SAML Form
        Write-Progress 'Please login to the console.  Once you login we will extract the STS token.'
        do {
            Start-Sleep 1
        } until ($Driver.url -eq 'https://signin.aws.amazon.com/saml')

        Write-Progress 'Extracting SAML Assertion'
        $Element = Find-SeElement -name 'SAMLResponse' -Driver $Driver
        $SAML_Encoded = Get-SeElementAttribute -Element $Element -Attribute 'Value'
        $SAML = [xml][System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($SAML_Encoded))

        # Create XML Namespace
        $XMLNamespace = @{saml2 = 'urn:oasis:names:tc:SAML:2.0:assertion'}

        # Get Roles
        $RolesXML = Select-Xml -Xml $SAML -XPath "//saml2:Attribute[@Name='https://aws.amazon.com/SAML/Attributes/Role']" -Namespace $XMLNamespace | Select-Object -ExpandProperty Node
        $Roles = $RolesXML.AttributeValue.'#text'

        # Wait for user to complete login process
        Write-Progress 'Please select the role that you would like to use'
        do {
            Start-Sleep 1
        } until ($Driver.Title -eq 'AWS Management Console')

        # Getting Data from Cookies
        Write-Progress 'Detected Console Login!  Getting details and closing browser.'
        $cookies = $Driver.Manage().Cookies.AllCookies
        $userInfo = $cookies | Where-Object Name -eq 'aws-userInfo'
        $userInfo = [System.Web.HttpUtility]::UrlDecode($userInfo.Value) | ConvertFrom-Json
        $accountID = ($UserInfo.arn -split ':')[4]
        $role = (($UserInfo.arn -split ':')[5] -split '/')[1]
        $name = ($userInfo.arn -split '/')[-1]

        # Output data to Console
        Write-Output "Logged into account: " $userInfo.alias
        Write-Output "ID: " $accountID
        Write-Output "Logged in as: " $name
        Write-Output "With Role: " $role

        # Get Role ARN's
        $RoleArns = ($Roles | Select-String "$accountID`:role/$role") -split ','

        # Attempt Login
        $STS = Use-STSRoleWithSAML -PrincipalArn $RoleArns[1] -RoleArn $RoleArns[0] -SAMLAssertion $SAML_Encoded

        $ENV:AWS_ACCESS_KEY_ID = $STS.Credentials.AccessKeyId
        $ENV:AWS_SECRET_ACCESS_KEY = $STS.Credentials.SecretAccessKey
        $ENV:AWS_SESSION_TOKEN = $STS.Credentials.SessionToken

        Write-Output "Your session is now good until $($STS.Credentials.Expiration)"

        # Close Browser
        $Driver.Close()
    }
}


function Save-AWSSAMLURL {
    [CmdletBinding()]
    param(
    )

    $URL = Read-Host -Prompt 'Enter the SSO Initiation URL'

    # Save the settings to the local system
    if(!(Test-Path($SAVE_DIR))){
        New-Item -Type Directory -Path $SAVE_DIR | Out-Null
    }

    $URL | Export-CliXml -Path ($SAVE_PATH)  -Encoding 'utf8' -Force

    return $URL
}

function Get-AWSSAMLURL {
    if(Test-Path($SAVE_PATH)){
        return Import-CliXml -Path ($SAVE_PATH)
    }else{
        Return Save-AWSSAMLURL
    }
}