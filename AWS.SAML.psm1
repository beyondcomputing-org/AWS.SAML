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
        [ValidateSet('Chrome', 'Firefox', 'Edge', 'IE')]
        [String]$Browser = 'Chrome'
    )
    if ($pscmdlet.ShouldProcess('AWS SAML', 'login'))
    {
        if([String]::IsNullOrWhiteSpace($InitURL)){
            $InitURL = Get-AWSSAMLURL
        }

        # Start Browser for Login
        $driver = Start-Browser -InitURL $InitURL -Browser $Browser

        # Get SAML Assertion
        $samlAssertion = Get-SAMLAssertion -Driver $driver

        # Get Selected Role
        $consoleData = Get-ConsoleData -Driver $driver

        # Get Role Details from SAML
        $arns = Get-SAMLRole -Assertion $samlAssertion -AccountID $consoleData.AccountID -Role $consoleData.Role

        # Get STS Credentials with SAML
        $sts = Use-STSRoleWithSAML -PrincipalArn $arns.PrincipalArn -RoleArn $arns.RoleArn -SAMLAssertion $samlAssertion

        # Store Credentials for use
        Add-AWSSTSCred -STS $sts

        # Close Browser
        $Driver.Close()

        # Output Console Data
        Write-Output "Logged into account: $($consoleData.Alias)"
        Write-Output "ID: $($consoleData.AccountID)"
        Write-Output "Logged in as: $($consoleData.Name)"
        Write-Output "With Role: $($consoleData.Role)"
        Write-Output "Your session is now good until: $($sts.Credentials.Expiration)"
    }
}

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

    return [ordered]@{
        PrincipalArn = $arns[1]
        RoleArn = $arns[0]
    }
}

function Get-ConsoleData{
    [CmdletBinding()]
    param(
        $Driver
    )
    # Wait for user to complete login process
    Write-Progress 'Please select the role that you would like to use and login to the console.'
    do {
        Start-Sleep -Milliseconds 100
    } until ($Driver.Title -eq 'AWS Management Console')

    # Getting Data from Cookies
    Write-Progress 'Detected Console Login!  Getting details and closing browser.'
    $cookies = $Driver.Manage().Cookies.AllCookies

    Return Get-CookieData -Cookies $cookies
}

function Get-CookieData{
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    param(
        $Cookies
    )
    $userInfo = $Cookies | Where-Object Name -eq 'aws-userInfo'
    $info = [System.Web.HttpUtility]::UrlDecode($userInfo.Value) | ConvertFrom-Json

    return [ordered]@{
        AccountID = ($info.arn -split ':')[4]
        Alias = $info.alias
        Role = (($info.arn -split ':')[5] -split '/')[1]
        Name = ($info.arn -split '/')[-1]
    }
}

function Get-SAMLAssertion {
    [CmdletBinding()]
    param(
        $Driver
    )

    # Wait for SAML Form
    Write-Progress 'Please login to the console.  Once you login we will pull the SAML Assertion.'
    do {
        Start-Sleep -Milliseconds 100
    } until ($Driver.url -eq 'https://signin.aws.amazon.com/saml')

    Write-Progress 'Extracting SAML Assertion'
    $Element = Find-SeElement -name 'SAMLResponse' -Driver $Driver
    return Get-SeElementAttribute -Element $Element -Attribute 'Value'
}

function Start-Browser {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [String]$InitURL,
        [ValidateSet('Chrome', 'Firefox', 'Edge', 'IE')]
        [String]$Browser
    )

    if ($pscmdlet.ShouldProcess($Browser, 'start'))
    {
        # Open Browser and launch login page
        switch ($Browser) {
            'Firefox' {
                $Driver = Start-SeFirefox
            }
            'Edge' {
                $Driver = Start-SeEdge
            }
            'IE' {
                $Driver = Start-SeInternetExplorer
            }
            Default {
                $Driver = Start-SeChrome
            }
        }

        Enter-SeUrl $InitURL -Driver $Driver

        Return $Driver
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