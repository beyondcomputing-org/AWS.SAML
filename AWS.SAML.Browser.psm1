using module .\AWS.SAML.Settings.psm1

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
        [String]$Browser,
        [Switch]$NoProfile
    )

    if ($pscmdlet.ShouldProcess($Browser, 'start'))
    {
        # Open Browser and launch login page
        switch ($Browser) {
            'Firefox' {
                Write-Warning 'FireFox functionality has not been tested!'
                $Driver = Start-SeFirefox -StartURL $InitURL
            }
            'Edge' {
                Write-Warning 'Edge functionality has not been tested!'
                $Driver = Start-SeEdge -StartURL $InitURL
            }
            'IE' {
                Write-Warning 'IE functionality has not been tested!'
                $Driver = Start-SeInternetExplorer -StartURL $InitURL
            }
            Default {
                if($NoProfile){
                    $Driver = Start-SeChrome -Arguments @("--app=$InitURL")
                }else{
                    $Driver = Start-SeChrome -ProfileDirectoryPath "$(Get-SaveDir)\Chrome" -Arguments @("--app=$InitURL")
                }
            }
        }

        Return $Driver
    }
}