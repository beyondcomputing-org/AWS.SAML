using module .\AWS.SAML.Browser.psm1
using module .\AWS.SAML.Settings.psm1
using module .\AWS.SAML.Utils.psm1
using module .\AWS.SAML.Profile.psm1

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
        Choose the browser to handle the login process.  Options: Chrome, Firefox, Edge, IE  Default: Chrome
#>
function New-AWSSAMLLogin {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    [Alias('Login-AWSSAML','las')]
    param(
        [String]$InitURL,
        [ValidateSet('Chrome', 'Firefox', 'Edge', 'IE')]
        [String]$Browser = 'Chrome',
        [Switch]$NoBrowserProfile,
        [Alias('Profile')]
        [String]$ProfileName
    )
    if ($pscmdlet.ShouldProcess('AWS SAML', 'login'))
    {
        if([String]::IsNullOrWhiteSpace($InitURL)){
            $InitURL = Get-AWSSAMLURL
        }

        # Start Browser for Login
        $driver = Start-Browser -InitURL $InitURL -Browser $Browser -NoProfile:$NoBrowserProfile

        # Get SAML Assertion
        $samlAssertion = Get-SAMLAssertion -Driver $driver

        # Get Selected Role
        $consoleData = Get-ConsoleData -Driver $driver

        # Close Browser
        $Driver.quit()

        # Get Role Details from SAML
        $arns = Get-SAMLRole -Assertion $samlAssertion -AccountID $consoleData.AccountID -Role $consoleData.Role

        # Get STS Credentials with SAML
        $sts = Use-STSRoleWithSAML -PrincipalArn $arns.PrincipalArn -RoleArn $arns.RoleArn -SAMLAssertion $samlAssertion

        # Store Credentials for use
        if($ProfileName){
            # Store in Profile
            Set-AWSProfile -ProfileName $ProfileName -AccessKeyId $sts.Credentials.AccessKeyId -SecretAccessKey $sts.Credentials.SecretAccessKey -SessionToken $sts.Credentials.SessionToken
        }else{
            # Store in Environment Variable
            Add-AWSSTSCred -STS $sts -ProfileName $ProfileName
        }

        # Output Console Data
        Write-Output "Logged into account: $($consoleData.Alias)"
        Write-Output "ID: $($consoleData.AccountID)"
        Write-Output "Logged in as: $($consoleData.Name)"
        Write-Output "With Role: $($consoleData.Role)"
        Write-Output "Your session is now good until: $($sts.Credentials.Expiration)"
    }
}